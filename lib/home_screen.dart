import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'seller_portal_screen.dart';
import 'auth_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MarketplaceProduct {
  const MarketplaceProduct({
    required this.name,
    required this.price,
    required this.category,
    required this.seller,
    required this.description,
    required this.emoji,
    this.phone,
  });

  final String name;
  final String price;
  final String category;
  final String seller;
  final String description;
  final String emoji;
  final String? phone;

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'category': category,
        'seller': seller,
        'description': description,
        'emoji': emoji,
        'phone': phone,
      };

  factory MarketplaceProduct.fromJson(Map<String, dynamic> json) =>
      MarketplaceProduct(
        name: json['name'] as String,
        price: json['price'] as String,
        category: json['category'] as String,
        seller: json['seller'] as String,
        description: json['description'] as String,
        emoji: json['emoji'] as String? ?? '🛍️',
        phone: json['phone'] as String?,
      );
}

const demoProducts = <MarketplaceProduct>[
  MarketplaceProduct(name: 'Classic Leather Sneakers', price: '₦30,000', category: 'Fashion', seller: 'Rozay Demo Store', description: 'Comfortable everyday sneakers. This is a sample listing for demonstration.', emoji: '👟'),
  MarketplaceProduct(name: 'Ladies Everyday Handbag', price: '₦18,000', category: 'Fashion', seller: 'Rozay Demo Store', description: 'A stylish everyday handbag. This is a sample listing for demonstration.', emoji: '👜'),
  MarketplaceProduct(name: 'Smart Watch', price: '₦35,000', category: 'Electronics', seller: 'Rozay Demo Store', description: 'A modern smart watch. This is a sample listing for demonstration.', emoji: '⌚'),
  MarketplaceProduct(name: 'Android Smartphone', price: '₦150,000', category: 'Phones', seller: 'Rozay Demo Store', description: 'A sample smartphone listing. Confirm specifications with a real seller before purchase.', emoji: '📱'),
  MarketplaceProduct(name: 'Home Decor Set', price: '₦22,000', category: 'Home', seller: 'Rozay Demo Store', description: 'A decorative home accessory set. This is a sample listing.', emoji: '🪴'),
  MarketplaceProduct(name: 'Beauty Care Kit', price: '₦12,500', category: 'Beauty', seller: 'Rozay Demo Store', description: 'A sample beauty product listing.', emoji: '🧴'),
];

const marketplaceCategories = <String>[
  'All', 'Fashion', 'Electronics', 'Phones', 'Home', 'Food', 'Beauty',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<MarketplaceProduct> _products = [...demoProducts];
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  static const _savedProductsKey = 'rozay_connect_seller_products_v1';

  @override
  void initState() {
    super.initState();
    _loadSavedProducts();
    _loadRemoteProducts();
  }

  Future<void> _loadRemoteProducts() async {
    try {
      final rows = await Supabase.instance.client
          .from('products')
          .select('id,name,description,price_ngn,category,seller_profiles!inner(business_name,whatsapp_phone)')
          .eq('status', 'active')
          .order('created_at', ascending: false);
      final online = rows.map((row) {
        final seller = Map<String, dynamic>.from(row['seller_profiles'] as Map);
        final price = (row['price_ngn'] as num).toStringAsFixed(0);
        return MarketplaceProduct(
          name: row['name'] as String,
          price: '₦$price',
          category: row['category'] as String,
          seller: seller['business_name'] as String? ?? 'Verified seller',
          description: row['description'] as String,
          emoji: '🛍️',
          phone: seller['whatsapp_phone'] as String?,
        );
      }).toList();
      if (!mounted) return;
      setState(() {
        _products.removeWhere((product) => product.seller != 'Rozay Demo Store');
        _products.insertAll(0, online);
      });
    } catch (_) {
      // Keep sample listings visible when offline or before approved listings exist.
    }
  }

  Future<void> _loadSavedProducts() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getString(_savedProductsKey);
      if (saved == null || saved.isEmpty) return;
      final decoded = jsonDecode(saved) as List<dynamic>;
      final products = decoded
          .map((item) => MarketplaceProduct.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
      if (!mounted) return;
      setState(() => _products.addAll(products));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved listings could not be loaded.')),
      );
    }
  }

  Future<bool> _saveSellerProducts() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final sellerProducts = _products
          .where((product) => product.seller != 'Rozay Demo Store')
          .map((product) => product.toJson())
          .toList();
      return await preferences.setString(
        _savedProductsKey,
        jsonEncode(sellerProducts),
      );
    } catch (_) {
      return false;
    }
  }

  List<MarketplaceProduct> get _visibleProducts {
    return _products.where((product) {
      final matchesCategory = _selectedCategory == 'All' ||
          product.category == _selectedCategory;
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.seller.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _contactSeller(MarketplaceProduct product) async {
    final phone = product.phone?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seller contact is not available for this sample listing.')),
      );
      return;
    }
    final message = Uri.encodeComponent(
      'Hello, I saw ${product.name} on Rozay Connect. Is it available?',
    );
    final uri = Uri.parse('https://wa.me/$phone?text=$message');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp. Please try again.')),
      );
    }
  }

  void _showProductDetails(MarketplaceProduct product) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text(product.emoji, style: const TextStyle(fontSize: 64))),
            const SizedBox(height: 16),
            Text(product.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(product.price, style: const TextStyle(color: Color(0xFF16834A), fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(product.description),
            const SizedBox(height: 12),
            Text('Category: ${product.category}'),
            Text('Seller: ${product.seller}'),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _contactSeller(product);
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Contact seller on WhatsApp'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSellerPortal() async {
    var needsSignIn = false;
    try {
      needsSignIn = Supabase.instance.client.auth.currentUser == null;
    } catch (_) {
      // Allows isolated widget previews/tests without initializing Supabase.
    }
    if (needsSignIn) {
      final signedIn = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const AuthScreen()));
      if (signedIn != true || !mounted) return;
    }
    final product = await Navigator.of(context).push<MarketplaceProduct>(
      MaterialPageRoute(builder: (_) => const SellerPortalScreen()),
    );
    if (product != null && mounted) {
      setState(() {
        _products.insert(0, product);
        _selectedCategory = 'All';
        _searchQuery = '';
        _searchController.clear();
      });
      final saved = await _saveSellerProducts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(saved
              ? 'Your product is saved on this device.'
              : 'Product added for this session, but could not be saved.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = _visibleProducts;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: _openSellerPortal,
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Sell'),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: const Color(0xFFE6F4EB), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF16834A)),
            ),
            const SizedBox(width: 10),
            const Text('Rozay Connect', style: TextStyle(color: Color(0xFF173B2A), fontWeight: FontWeight.w800, fontSize: 20)),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF12683B), Color(0xFF239657)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('YOUR MARKETPLACE,\nCONNECTED.', style: TextStyle(color: Colors.white, fontSize: 23, height: 1.15, fontWeight: FontWeight.w900)),
                  SizedBox(height: 8),
                  Text('Discover products and connect with sellers.', style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search products or sellers',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF16834A)),
                suffixIcon: _searchQuery.isEmpty ? null : IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  icon: const Icon(Icons.close),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 22),
            const Text('Browse categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF193B2A))),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: marketplaceCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = marketplaceCategories[index];
                  final selected = category == _selectedCategory;
                  return ChoiceChip(
                    label: Text(category),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = category),
                    selectedColor: const Color(0xFFDDF1E4),
                    labelStyle: TextStyle(color: selected ? const Color(0xFF12683B) : const Color(0xFF53645A), fontWeight: FontWeight.w600),
                    side: BorderSide(color: selected ? const Color(0xFF16834A) : const Color(0xFFE1E9E3)),
                    backgroundColor: Colors.white,
                    showCheckmark: false,
                  );
                },
              ),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Featured products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF193B2A))),
                Text('${products.length} items', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            if (products.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                child: const Column(
                  children: [
                    Icon(Icons.search_off, size: 42, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('No products found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('Try another search or choose a different category.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 600 ? 3 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _showProductDetails(product),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(color: const Color(0xFFEAF4ED), borderRadius: BorderRadius.circular(13)),
                                    child: Center(child: Text(product.emoji, style: const TextStyle(fontSize: 48))),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                const SizedBox(height: 5),
                                Text(product.price, style: const TextStyle(color: Color(0xFF16834A), fontWeight: FontWeight.w800, fontSize: 15)),
                                const SizedBox(height: 4),
                                Text(product.seller == 'Rozay Demo Store' ? 'Sample listing' : 'Seller listing', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            const SizedBox(height: 20),
            const Text('Demo catalogue: replace sample listings with verified seller products before launch.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
