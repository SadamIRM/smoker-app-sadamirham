import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthPage extends StatefulWidget {
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? successMessage;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.6,
            colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
          ),
        ),
        child: Stack(
          children: [
            // glow kiri atas
            Positioned(
              top: -100,
              left: -80,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(
                  height: 220,
                  width: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.withOpacity(0.18),
                  ),
                ),
              ),
            ),

            // glow kanan bawah
            Positioned(
              bottom: -120,
              right: -100,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  height: 260,
                  width: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.deepOrange.withOpacity(0.12),
                  ),
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 90,
                      color: Colors.orangeAccent,
                    ),

                    const SizedBox(height: 10),

             
               
  }
