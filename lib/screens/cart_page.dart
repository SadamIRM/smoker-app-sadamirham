import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/auth_provider.dart';

Future<void> checkout(BuildContext context) async {
  final cart = context.read<CartProvider>();
  final auth = context.read<AuthProvider>();

  if (cart.items.isEmpty) return;

  await FirebaseFirestore.instance.collection('orders').add({
    "email": auth.user?.email ?? "unknown",
    "items": cart.items
        .map((e) => {"name": e.name, "price": e.price, "image": e.image})
        .toList(),
    "total": cart.totalPrice,
    "createdAt": FieldValue.serverTimestamp(),

    "jwt": auth.jwtToken ?? "no-token",
  });

  cart.clearCart();

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Checkout berhasil & tersimpan")),
  );
}

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Keranjang"),
        backgroundColor: Colors.brown,
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                "Keranjang kosong",
                style: TextStyle(color: Colors.white70),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orangeAccent),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: item.image.isNotEmpty
                                  ? Image.network(
                                      item.image,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey,
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    "Rp ${item.price}",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                cart.removeFromCart(item);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white10,
                    border: Border(top: BorderSide(color: Colors.white24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total: Rp ${cart.totalPrice}",
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () async {
                            await checkout(context);
                          },
                          child: const Text("Checkout"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
