import 'package:flutter/material.dart';
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
  String _category = 'Fashion';
  bool _profileSaved = false;
  bool _busy = false;
  final _client = Supabase.instance.client;

  @override
  void dispose() {
    _business.dispose(); _phone.dispose(); _location.dispose();
    _name.dispose(); _price.dispose(); _description.dispose();
    super.dispose();
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'This field is required' : null;
  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label, prefixIcon: Icon(icon), filled: true,
    fillColor: const Color(0xFFF5F8F6),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
  );

  Future<void> _saveProfile() async {
    if (_business.text.trim().length < 2 || _phone.text.trim().length < 7 || _location.text.trim().length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a business name, phone number and location.')));
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
      if (mounted) setState(() => _profileSaved = true);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save seller profile: $error')));
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
      await _client.from('products').insert({
        'seller_id': user.id,
        'name': _name.text.trim(),
        'description': _description.text.trim(),
        'price_ngn': double.parse(_price.text.trim()),
        'category': _category,
        'status': 'pending',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product submitted for review. It will appear after verification.')));
      Navigator.of(context).pop();
    } on PostgrestException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not submit product: $error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F8F6),
    appBar: AppBar(title: const Text('Seller centre')),
    body: SafeArea(child: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Start selling on Rozay Connect', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Color(0xFF193B2A))),
      const SizedBox(height: 6),
      const Text('Your seller profile and product submissions are saved online.'),
      const SizedBox(height: 22),
      const Text('1. Seller details', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      TextFormField(controller: _business, decoration: _decoration('Business or seller name', Icons.storefront_outlined), validator: _required, enabled: !_profileSaved),
      const SizedBox(height: 12),
      TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: _decoration('WhatsApp number with country code', Icons.phone_outlined), validator: _required, enabled: !_profileSaved),
      const SizedBox(height: 12),
      TextFormField(controller: _location, decoration: _decoration('Business location / city', Icons.location_on_outlined), validator: _required, enabled: !_profileSaved),
      const SizedBox(height: 12),
      if (!_profileSaved) FilledButton(onPressed: _busy ? null : _saveProfile, child: Text(_busy ? 'Saving…' : 'Save seller profile'))
      else const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.check_circle, color: Color(0xFF16834A)), title: Text('Seller profile submitted'), subtitle: Text('Verification status: pending')),
      const SizedBox(height: 22),
      const Text('2. Add a product', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      TextFormField(controller: _name, decoration: _decoration('Product name', Icons.inventory_2_outlined), validator: _profileSaved ? _required : null, enabled: _profileSaved),
      const SizedBox(height: 12),
      TextFormField(controller: _price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _decoration('Price in naira (numbers only)', Icons.payments_outlined), validator: _profileSaved ? (v) => v == null || double.tryParse(v.trim()) == null || double.parse(v.trim()) <= 0 ? 'Enter a valid price' : null : null, enabled: _profileSaved),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(initialValue: _category, decoration: _decoration('Category', Icons.category_outlined), items: const ['Fashion','Electronics','Phones','Home','Food','Beauty'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: _profileSaved ? (v) => setState(() => _category = v!) : null),
      const SizedBox(height: 12),
      TextFormField(controller: _description, maxLines: 3, decoration: _decoration('Product description', Icons.notes_outlined), validator: _profileSaved ? _required : null, enabled: _profileSaved),
      const SizedBox(height: 18),
      FilledButton(onPressed: _profileSaved && !_busy ? _submitProduct : null, child: Text(_busy ? 'Submitting…' : 'Submit product for review')),
      const SizedBox(height: 12),
      const Text('New seller profiles and products stay pending until an authorised reviewer verifies them. Product photos will be added in a later update.', style: TextStyle(color: Colors.black54, fontSize: 12)),
    ]))),
  );
}
