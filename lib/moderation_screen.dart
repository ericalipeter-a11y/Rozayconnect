import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModerationScreen extends StatefulWidget {
  const ModerationScreen({super.key});

  @override
  State<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends State<ModerationScreen> {
  final _client = Supabase.instance.client;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _sellers = [];
  List<Map<String, dynamic>> _products = {};
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _client.functions.invoke(
        'moderate-marketplace',
        body: {'action': 'list'},
      );
      if (response.status != 200) {
        final message = response.data is Map
            ? response.data['error']?.toString()
            : null;
        throw Exception(message ?? 'Could not load review queue.');
      }
      final data = Map<String, dynamic>.from(response.data as Map);
      if (!mounted) return;
      setState(() {
        _sellers = (data['sellers'] as List? ?? [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        _products = (data['products'] as List? ?? [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _review({
    required String entity,
    required String id,
    required String decision,
  }) async {
    setState(() => _working = true);
    try {
      final response = await _client.functions.invoke(
        'moderate-marketplace',
        body: {
          'action': 'review',
          'entity': entity,
          'id': id,
          'decision': decision,
        },
      );
      if (response.status != 200) {
        final message = response.data is Map
            ? response.data['error']?.toString()
            : null;
        throw Exception(message ?? 'The review could not be saved.');
      }
      await _loadQueue();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            decision == 'approve' ? 'Submission approved.' : 'Submission rejected.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.toString().replaceFirst('Exception: ', ''),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Widget _reviewButtons(String entity, String id) => Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _working
                  ? null
                  : () => _review(
                        entity: entity,
                        id: id,
                        decision: 'reject',
                      ),
              child: const Text('Reject'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: _working
                  ? null
                  : () => _review(
                        entity: entity,
                        id: id,
                        decision: 'approve',
                      ),
              child: const Text('Approve'),
            ),
          ),
        ],
      );

  Widget _sellerCard(Map<String, dynamic> seller) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                seller['business_name']?.toString() ?? 'Seller',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text('Location: ${seller['location'] ?? 'Not provided'}'),
              Text('WhatsApp: ${seller['whatsapp_phone'] ?? 'Not provided'}'),
              const SizedBox(height: 12),
              _reviewButtons('seller', seller['id'].toString()),
            ],
          ),
        ),
      );

  Widget _productCard(Map<String, dynamic> product) {
    final seller = product['seller_profiles'] is Map
        ? Map<String, dynamic>.from(product['seller_profiles'] as Map)
        : <String, dynamic>{};
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product['name']?.toString() ?? 'Product',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text('Seller: ${seller['business_name'] ?? 'Unknown'}'),
            Text('Category: ${product['category'] ?? 'Not provided'}'),
            Text('Price: ₦${product['price_ngn'] ?? ''}'),
            const SizedBox(height: 8),
            Text(product['description']?.toString() ?? ''),
            if (seller['verification_status'] != 'verified')
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Verify the seller before approving this product.',
                  style: TextStyle(color: Colors.deepOrange),
                ),
              ),
            const SizedBox(height: 12),
            _reviewButtons('product', product['id'].toString()),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Marketplace review'),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              onPressed: _loading ? null : _loadQueue,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_outline, size: 42),
                          const SizedBox(height: 12),
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _loadQueue,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadQueue,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          'Seller profiles (${_sellers.length})',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (_sellers.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('No seller profiles waiting for review.'),
                          ),
                        ..._sellers.map(_sellerCard),
                        const SizedBox(height: 20),
                        Text(
                          'Products (${_products.length})',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (_products.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('No products waiting for review.'),
                          ),
                        ..._products.map(_productCard),
                      ],
                    ),
                  ),
      );
}
