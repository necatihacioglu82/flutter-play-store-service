import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'store_service.dart';

class StoreExample extends StatefulWidget {
  const StoreExample({super.key});

  @override
  State<StoreExample> createState() => _StoreExampleState();
}

class _StoreExampleState extends State<StoreExample> {
  final StoreService _storeService = StoreService();
  List<ProductDetails> _products = [];
  bool _isLoading = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeStore();
  }

  Future<void> _initializeStore() async {
    setState(() {
      _isLoading = true;
    });

    // Store'a bağlan
    _isConnected = await _storeService.connectToStore();

    if (_isConnected) {
      // Ürün listesini çek
      await _loadProducts();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadProducts() async {
    // Ürün ID'lerinizi buraya ekleyin
    List<String> productIds = [
      'premium_monthly',
      'premium_yearly',
      'coins_100',
      'coins_500',
      'remove_ads',
    ];

    _products = await _storeService.getProducts(productIds);
    //_products.forEach((e) {});
    //_storeService.purchaseProduct(_products[0]);
    setState(() {});
  }

  Future<void> _purchaseProduct(ProductDetails product) async {
    bool success = await _storeService.purchaseProduct(product);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${product.title} satın alma işlemi başlatıldı')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Satın alma işlemi başlatılamadı')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Örneği'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isConnected ? _loadProducts : null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_isConnected
              ? const Center(
                  child: Text('Store bağlantısı kurulamadı'),
                )
              : _products.isEmpty
                  ? const Center(
                      child: Text('Ürün bulunamadı'),
                    )
                  : ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(product.title),
                            subtitle: Text(product.description),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  product.price,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => _purchaseProduct(product),
                                  child: const Text('Satın Al'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  @override
  void dispose() {
    _storeService.dispose();
    super.dispose();
  }
}
