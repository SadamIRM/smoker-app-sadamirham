import 'package:flutter/material.dart';
import 'package:smoker_app/core/constants/app_colors.dart';
import 'package:smoker_app/features/cart/presentation/pages/cart_page.dart';
import 'package:smoker_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:smoker_app/features/dashboard/presentation/providers/product_provider.dart';
import 'package:smoker_app/core/services/notification_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
      context.read<CartProvider>().fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Home Belanja',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Keranjang',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
        ],
      ),
      body: switch (product.status) {
        ProductStatus.loading || ProductStatus.initial => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat produk...'),
            ],
          ),
        ),

        ProductStatus.error => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(product.error ?? 'Terjadi kesalahan'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                onPressed: () => product.fetchProducts(),
              ),
            ],
          ),
        ),

        ProductStatus.loaded => RefreshIndicator(
          onRefresh: () => product.fetchProducts(),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.48, // More vertical space to avoid overflows
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: product.products.length,
            itemBuilder: (context, i) {
              final p = product.products[i];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        p.imageUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 120,
                          color: AppColors.primaryLight.withOpacity(0.1),
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rp ${p.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              p.category,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ElevatedButton(
                            onPressed: () {
                              context.read<CartProvider>().addItem(
                                p.id.toString(),
                                p.name,
                                p.price,
                                imageUrl: p.imageUrl,
                              );
                              NotificationService().showCartNotification(
                                title: 'Keranjang Belanja',
                                body: '${p.name} berhasil ditambahkan ke keranjang.',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              minimumSize: const Size(double.infinity, 36),
                            ),
                            child: const Text(
                              'Tambah ke Keranjang',
                              style: TextStyle(fontSize: 12),
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
        ),
      },
    );
  }
}
