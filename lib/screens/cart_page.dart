import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

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
     
          
