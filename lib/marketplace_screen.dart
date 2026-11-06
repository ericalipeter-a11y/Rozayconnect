
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  final List<Map<String, String>> products = const [
    {
      'name': 'Men Fashion Shoes',
      'price': '₦25,000',
      'category': 'Fashion',
      'emoji': '👞',
      'phone': '2348012345678',
    },
    {
      'name': 'Ladies Handbag',
      'price': '₦18,000',
      'category': 'Fashion',
      'emoji': '👜',
      'phone': '2348012345678',
    },
    {
      'name': 'Smart Watch',
      'price': '₦35,000',
      'category': 'Electronics',
      'emoji': '⌚',
      'phone': '2348012345678',
    },
    {
      'name': 'Quality Sneakers',
      'price': '₦30,000',
      'category': 'Fashion',
      'emoji': '👟',
      'phone': '2348012345678',
    },
  ];

  Future<void> contactSeller(String phone, String product) async {
    final message = Uri.encodeComponent(
      'Hello, I saw $product on Rozay Connect. Is it available?'
    );

    final url = Uri.parse('https://wa.me/$phone?text=$message');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF123B70),
        foregroundColor: Colors.white,
        title: const Text(
          'Rozay Connect',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          Icon(Icons.notifications_none),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find what you need!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Shop directly from trusted sellers.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                Chip(label: Text('All')),
                Chip(label: Text('Fashion')),
                Chip(label: Text('Electronics')),
                Chip(label: Text('Phones')),
                Chip(label: Text('Home')),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Featured Products',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) {
                final product = products[index];

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EDF5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              product['emoji']!,
                              style: const TextStyle(fontSize: 65),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name']!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              product['price']!,
                              style: const TextStyle(
                                color: Color(0xFF123B70),
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 9),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => contactSeller(
                                  product['phone']!,
                                  product['name']!,
                                ),
                                icon: const Icon(
                                  Icons.chat,
                                  size: 16,
                                ),
                                label: const Text('WhatsApp Seller'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF25D366),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 9,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
