import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SellerPortalScreen extends StatefulWidget {
  const SellerPortalScreen({super.key});

  @override
  State<SellerPortalScreen> createState() => _SellerPortalScreenState();
}

class _SellerPortalScreenState extends State<SellerPortalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _business = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  final _picker = ImagePicker();
  final _client = Supabase.instance.client;

  String _category = 'Fashion';
  File? _productImage;
  bool _profileSaved = false;
  bool _busy = false;
  String? _verificationStatus;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    try {
      final profile = await _client
          .from('seller_profiles')
          .select('business_name,whatsapp_phone,location,verification_status')
          .eq('id', user.id)
          .maybeSingle();
      if (!mounted || profile == null) return;
      final status = profile['verification_status'] as String? ?? 'pending';
      setState(() {
        _business.text = profile['business_name'] as String? ?? '';
        _phone.text = profile['whatsapp_phone'] as String? ?? '';
        _location.text = profile['location'] as String? ?? '';
        _verificationStatus = status;
        // Rejected sellers may correct their details and submit again.
        _profileSaved = status != 'rejected';
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load your saved seller profile.')),
      );
    }
  }

  @override
  void dispose() {
    _business.dispose();
    _phone.dispose();
    _location.dispose();
    _name.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF5F8F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  Future<void> _pickProductImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1600,
      );
      if (picked != null && mounted) {
        setState(() => _productImage = File(picked.path));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not select photo: $error')),
        );
      }
    }
  }

  Future<String?> _uploadProductImage(String userId) async {
    final image = _productImage;
    if (image == null) return null;

    final extension = image.path.split('.').last.toLowerCase();
    final contentType = switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
    final path = '$userId/${DateTime.now().microsecondsSinceEpoch}.$extension';

    await _client.storage.from('product-images').upload(
          path,
          image,
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );
    return path;
  }

  Future<void> _saveProfile() async {
    if (_business.text.trim().length < 2 ||
        _phone.text.trim().length < 7 ||
        _location.text.trim().length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a business name, phone number and location.'),
        ),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('Please sign in again.');
      await _client.from('seller_profiles').upsert({
        'id': user.id,
        'business_name': _business.text.trim(),
        'whatsapp_phone': _phone.text.trim(),
        'location': _location.text.trim(),
        'verification_status': 'pending',
      });
      if (mounted) {
        setState(() {
          _profileSaved = true;
          _verificationStatus = 'pending';
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save seller profile: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('Please sign in again.');

      final imagePath = await _uploadProductImage(user.id);
      await _client.from('products').insert({
        'seller_id': user.id,
        'name': _name.text.trim(),
        'description': _description.text.trim(),
        'price_ngn': double.parse(_price.text.trim()),
        'category': _category,
        'image_path': imagePath,
        'status': 'pending',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Product submitted for review. It will appear after verification.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not submit product: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF5F8F6),
        appBar: AppBar(title: const Text('Seller centre')),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Start selling on Rozay Connect',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF193B2A),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your seller profile and product submissions are saved online.',
                ),
                const SizedBox(height: 22),
                const Text(
                  '1. Seller details',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _business,
                  decoration: _decoration(
                    'Business or seller name',
                    Icons.storefront_outlined,
                  ),
                  validator: _required,
                  enabled: !_profileSaved,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: _decoration(
                    'WhatsApp number with country code',
                    Icons.phone_outlined,
                  ),
                  validator: _required,
                  enabled: !_profileSaved,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _location,
                  decoration: _decoration(
                    'Business location / city',
                    Icons.location_on_outlined,
                  ),
                  validator: _required,
                  enabled: !_profileSaved,
                ),
                const SizedBox(height: 12),
                if (!_profileSaved)
                  FilledButton(
                    onPressed: _busy ? null : _saveProfile,
                    child: Text(_busy ? 'Saving…' : 'Save seller profile'),
                  )
                else
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.check_circle,
                      color: Color(0xFF16834A),
                    ),
                    title: Text('Seller profile submitted'),
                    subtitle: Text(
                      'Verification status: ${_verificationStatus ?? 'pending'}',
                    ),
                  ),
                const SizedBox(height: 22),
                const Text(
                  '2. Add a product',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _name,
                  decoration: _decoration(
                    'Product name',
                    Icons.inventory_2_outlined,
                  ),
                  validator: _profileSaved ? _required : null,
                  enabled: _profileSaved,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _price,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: _decoration(
                    'Price in naira (numbers only)',
                    Icons.payments_outlined,
                  ),
                  validator: _profileSaved
                      ? (value) {
                          final price = double.tryParse(value?.trim() ?? '');
                          return price == null || price <= 0
                              ? 'Enter a valid price'
                              : null;
                        }
                      : null,
                  enabled: _profileSaved,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: _decoration(
                    'Category',
                    Icons.category_outlined,
                  ),
                  items: const [
                    'Fashion',
                    'Electronics',
                    'Phones',
                    'Home',
                    'Food',
                    'Beauty',
                  ]
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  onChanged: _profileSaved
                      ? (value) => setState(() => _category = value!)
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  maxLines: 3,
                  decoration: _decoration(
                    'Product description',
                    Icons.notes_outlined,
                  ),
                  validator: _profileSaved ? _required : null,
                  enabled: _profileSaved,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed:
                      _profileSaved && !_busy ? _pickProductImage : null,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(
                    _productImage == null
                        ? 'Choose product photo (optional)'
                        : 'Change product photo',
                  ),
                ),
                if (_productImage != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      _productImage!,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                FilledButton(
                  onPressed:
                      _profileSaved && !_busy ? _submitProduct : null,
                  child: Text(
                    _busy ? 'Submitting…' : 'Submit product for review',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'New seller profiles and products stay pending until an '
                  'authorised reviewer verifies them. Product photos are '
                  'stored in your seller folder.',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
}
