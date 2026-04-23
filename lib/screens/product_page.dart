import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductPage extends StatelessWidget {
  final CollectionReference productsRef =
      FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Smoker Products"),
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
              )
            ],
          )
        ],
      ),
    
          );
        },
      ),
    );
  }
}