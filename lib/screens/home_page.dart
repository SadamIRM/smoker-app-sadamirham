import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class HomePage extends StatelessWidget {
  final CollectionReference productsRef = FirebaseFirestore.instance.collection(
    'products',
  );

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Smoker Shop"),
        backgroundColor: Colors.brown,
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
                icon: const Icon(Icons.shopping_cart),
              ),
              Positioned(
                right: 5,
                top: 5,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text(
                    cart.items.length.toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Selamat beli rokok",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: productsRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Produk belum ada",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final product = Product.fromFirestore(docs[index]);

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.orangeAccent),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.smoking_rooms,
                            color: Colors.orangeAccent,
                            size: 40,
                          ),

                          const SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  "Rp ${product.price}",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown,
                            ),
                            onPressed: () {
                              context.read<CartProvider>().addToCart(product);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${product.name} ditambahkan"),
                                ),
                              );
                            },
                            child: const Text("Add"),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
