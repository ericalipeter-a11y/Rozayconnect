import 'package:supabase_flutter/supabase_flutter.dart';

class RozayBackend {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> loadPublicProducts() async {
    final rows = await client
        .from('products')
        .select(
            'id,name,description,price_ngn,category,image_path,seller_profiles!inner(business_name,whatsapp_phone)')
        .eq('status', 'active')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<void> saveSellerProfile({
    required String businessName,
    required String whatsappPhone,
    required String location,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw const AuthException('Please sign in first.');
    await client.from('seller_profiles').upsert({
      'id': user.id,
      'business_name': businessName.trim(),
      'whatsapp_phone': whatsappPhone.trim(),
      'location': location.trim(),
      'verification_status': 'pending',
    });
  }

  static Future<void> createProduct({
    required String name,
    required String description,
    required double price,
    required String category,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw const AuthException('Please sign in first.');
    await client.from('products').insert({
      'seller_id': user.id,
      'name': name.trim(),
      'description': description.trim(),
      'price_ngn': price,
      'category': category,
      'status': 'pending',
    });
  }
}
