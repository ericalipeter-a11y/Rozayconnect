import 'package:flutter/material.dart';
import 'home_screen.dart';

class SellerPortalScreen extends StatefulWidget {
  const SellerPortalScreen({super.key});

  @override
  State<SellerPortalScreen> createState() => _SellerPortalScreenState();
}

class _SellerPortalScreenState extends State<SellerPortalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sellerName = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _productName = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  String _category = 'Fashion';
  bool _registered = false;

  @override
  void dispose() {
    _sellerName.dispose();
    _phone.dispose();
    _location.dispose();
    _productName.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  void _registerSeller() {
    if (_sellerName.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _location.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete your seller details first.')),
      );
      return;
    }
    setState(() => _registered = true);
  }

  void _publishProduct() {
    if (!_formKey.currentState!.validate()) return;
    final digits = _phone.text.replaceAll(RegExp(r'[^0-9]'), '');
    final product = MarketplaceProduct(
      name: _productName.text.trim(),
      price: '₦${_price.text.trim()}',
      category: _category,
      seller: _sellerName.text.trim(),
      description: _description.text.trim(),
      emoji: '🛍️',
      phone: digits,
    );
    Navigator.of(context).pop(product);
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF5F8F6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),
      appBar: AppBar(title: const Text('Seller centre')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Start selling on Rozay Connect', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Color(0xFF193B2A))),
              const SizedBox(height: 6),
              const Text('Enter your details, then add your first product.'),
              const SizedBox(height: 22),
              _sectionTitle('1. Seller details'),
              const SizedBox(height: 12),
              TextFormField(controller: _sellerName, decoration: _decoration('Business or seller name', Icons.storefront_outlined), validator: _required, enabled: !_registered),
              const SizedBox(height: 12),
              TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: _decoration('WhatsApp phone number (include country code)', Icons.phone_outlined), validator: _required, enabled: !_registered),
              const SizedBox(height: 12),
              TextFormField(controller: _location, decoration: _decoration('Business location / city', Icons.location_on_outlined), validator: _required, enabled: !_registered),
              const SizedBox(height: 12),
              if (!_registered)
                FilledButton.icon(onPressed: _registerSeller, icon: const Icon(Icons.verified_user_outlined), label: const Text('Continue to product details'))
              else
                const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.check_circle, color: Color(0xFF16834A)), title: Text('Seller details completed'), subtitle: Text('Demo only — details are not sent to a server.')),
              const SizedBox(height: 22),
              _sectionTitle('2. Add a product'),
              const SizedBox(height: 12),
              TextFormField(controller: _productName, decoration: _decoration('Product name', Icons.inventory_2_outlined), validator: _registered ? _required : null, enabled: _registered),
              const SizedBox(height: 12),
              TextFormField(controller: _price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _decoration('Price in naira (numbers only)', Icons.payments_outlined), validator: _registered ? (value) { if (value == null || double.tryParse(value.trim()) == null || double.parse(value.trim()) <= 0) return 'Enter a valid price'; return null; } : null, enabled: _registered),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(initialValue: _category, decoration: _decoration('Category', Icons.category_outlined), items: const ['Fashion', 'Electronics', 'Phones', 'Home', 'Food', 'Beauty'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: _registered ? (value) => setState(() => _category = value!) : null),
              const SizedBox(height: 12),
              TextFormField(controller: _description, maxLines: 3, decoration: _decoration('Product description', Icons.notes_outlined), validator: _registered ? _required : null, enabled: _registered),
              const SizedBox(height: 18),
              FilledButton.icon(onPressed: _registered ? _publishProduct : null, icon: const Icon(Icons.add_shopping_cart), label: const Text('Add product to marketplace')),
              const SizedBox(height: 12),
              const Text('Prototype notice: seller and product details stay in app memory only and disappear when the app is closed. No account is created, no verification is performed, and product photos are not uploaded yet.', style: TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF193B2A)));
}
