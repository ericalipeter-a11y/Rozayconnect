import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Content-Type": "application/json",
};

function respond(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: corsHeaders });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return respond({ error: "Method not allowed." }, 405);

  const authorization = req.headers.get("Authorization");
  const token = authorization?.match(/^Bearer\s+(.+)$/i)?.[1];
  if (!token) return respond({ error: "Sign in is required." }, 401);

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    return respond({ error: "Moderation service is not configured." }, 500);
  }

  const authClient = createClient(supabaseUrl, anonKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: authData, error: authError } = await authClient.auth.getUser(token);
  if (authError || !authData.user) return respond({ error: "Your session is invalid. Sign in again." }, 401);

  // app_metadata is writable only by trusted Auth administrators, unlike user_metadata.
  const role = authData.user.app_metadata?.role;
  if (role !== "moderator" && role !== "admin") {
    return respond({ error: "You are not authorised to review marketplace submissions." }, 403);
  }

  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  try {
    const body = await req.json();
    if (body.action === "list") {
      const [sellers, products] = await Promise.all([
        admin.from("seller_profiles")
          .select("id,business_name,whatsapp_phone,location,verification_status,created_at")
          .eq("verification_status", "pending")
          .order("created_at", { ascending: true }),
        admin.from("products")
          .select("id,seller_id,name,description,price_ngn,category,image_path,status,created_at,seller_profiles!inner(business_name,verification_status)")
          .eq("status", "pending")
          .order("created_at", { ascending: true }),
      ]);
      if (sellers.error) throw sellers.error;
      if (products.error) throw products.error;
      return respond({ sellers: sellers.data, products: products.data });
    }

    if (body.action !== "review" ||
        !["seller", "product"].includes(body.entity) ||
        !["approve", "reject"].includes(body.decision) ||
        typeof body.id !== "string" ||
        !/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(body.id)) {
      return respond({ error: "Invalid review request." }, 400);
    }

    const approved = body.decision === "approve";
    if (body.entity === "seller") {
      const { data, error } = await admin.from("seller_profiles")
        .update({ verification_status: approved ? "verified" : "rejected" })
        .eq("id", body.id)
        .eq("verification_status", "pending")
        .select("id,verification_status")
        .maybeSingle();
      if (error) throw error;
      if (!data) return respond({ error: "This seller was already reviewed or no longer exists." }, 409);
      return respond({ success: true, entity: "seller", result: data });
    }

    if (approved) {
      const { data: product, error: lookupError } = await admin.from("products")
        .select("id,seller_id,status")
        .eq("id", body.id)
        .eq("status", "pending")
        .maybeSingle();
      if (lookupError) throw lookupError;
      if (!product) return respond({ error: "This product was already reviewed or no longer exists." }, 409);

      const { data: seller, error: sellerError } = await admin.from("seller_profiles")
        .select("verification_status")
        .eq("id", product.seller_id)
        .maybeSingle();
      if (sellerError) throw sellerError;
      if (seller?.verification_status !== "verified") {
        return respond({ error: "Verify the seller before approving this product." }, 409);
      }
    }

    const { data, error } = await admin.from("products")
      .update({ status: approved ? "active" : "rejected" })
      .eq("id", body.id)
      .eq("status", "pending")
      .select("id,status")
      .maybeSingle();
    if (error) throw error;
    if (!data) return respond({ error: "This product was already reviewed or no longer exists." }, 409);
    return respond({ success: true, entity: "product", result: data });
  } catch (error) {
    console.error("Moderation request failed:", error instanceof Error ? error.message : "unknown error");
    return respond({ error: "The moderation request could not be completed." }, 500);
  }
});
