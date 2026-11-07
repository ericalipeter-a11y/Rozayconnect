-- Rozay Connect initial Supabase marketplace schema.
-- Apply only after creating a Supabase project and reviewing the setup guide.

create table if not exists public.seller_profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  business_name text not null check (char_length(trim(business_name)) between 2 and 100),
  whatsapp_phone text not null check (char_length(trim(whatsapp_phone)) between 7 and 20),
  location text not null check (char_length(trim(location)) between 2 and 120),
  verification_status text not null default 'pending'
    check (verification_status in ('pending', 'verified', 'rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references public.seller_profiles (id) on delete cascade,
  name text not null check (char_length(trim(name)) between 2 and 120),
  description text not null check (char_length(trim(description)) between 2 and 2000),
  price_ngn numeric(14, 2) not null check (price_ngn > 0),
  category text not null check (char_length(trim(category)) between 2 and 60),
  image_path text,
  status text not null default 'pending'
    check (status in ('pending', 'active', 'rejected', 'archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists products_public_browse_idx
  on public.products (status, category, created_at desc);
create index if not exists products_seller_idx
  on public.products (seller_id, created_at desc);

alter table public.seller_profiles enable row level security;
alter table public.products enable row level security;

create policy "Verified seller profiles are public"
  on public.seller_profiles for select
  using (verification_status = 'verified');

create policy "Sellers can read their own profile"
  on public.seller_profiles for select to authenticated
  using (id = (select auth.uid()));

create policy "Users can create their own pending seller profile"
  on public.seller_profiles for insert to authenticated
  with check (id = (select auth.uid()) and verification_status = 'pending');

create policy "Sellers can update their own pending profile"
  on public.seller_profiles for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()) and verification_status = 'pending');

create policy "Verified active products are public"
  on public.products for select
  using (
    status = 'active'
    and exists (
      select 1 from public.seller_profiles
      where seller_profiles.id = products.seller_id
        and seller_profiles.verification_status = 'verified'
    )
  );

create policy "Sellers can read their own products"
  on public.products for select to authenticated
  using (seller_id = (select auth.uid()));

create policy "Sellers can create pending products"
  on public.products for insert to authenticated
  with check (seller_id = (select auth.uid()) and status = 'pending');

create policy "Sellers can update their own products without publishing"
  on public.products for update to authenticated
  using (seller_id = (select auth.uid()))
  with check (seller_id = (select auth.uid()) and status in ('pending', 'archived'));

create policy "Sellers can delete their own products"
  on public.products for delete to authenticated
  using (seller_id = (select auth.uid()));

-- Publishing and seller verification must be performed by a trusted moderator
-- or protected server-side workflow, never by the public client app.
