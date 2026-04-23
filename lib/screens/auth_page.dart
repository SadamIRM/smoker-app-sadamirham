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

                    const Text(
                      "SMOKER SHOP",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 30),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          width: 340,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                isLogin ? "Login" : "Register",
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 20),

                              _buildField("Email", emailController, false),
                              const SizedBox(height: 15),
                              _buildField("Password", passwordController, true),

                              const SizedBox(height: 20),

                              // ERROR
                              if (auth.error != null)
                                Text(
                                  auth.error!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                ),

                              // SUCCESS MESSAGE
                              if (successMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    successMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.greenAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 10),

                              // BUTTON
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orangeAccent,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 10,
                                  shadowColor: Colors.orange,
                                ),
                                onPressed: () async {
                                  if (isLogin) {
                                    await auth.login(
                                      emailController.text,
                                      passwordController.text,
                                    );
                                  } else {
                                    await auth.register(
                                      emailController.text,
                                      passwordController.text,
                                    );

                                    setState(() {
                                      successMessage =
                                          "Sign up berhasil. Cek email untuk verifikasi.";
                                      isLogin = true;
                                    });
                                  }
                                },
                                child: auth.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        isLogin ? "Login" : "Register",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),

                              const SizedBox(height: 10),

                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    isLogin = !isLogin;
                                    successMessage = null;
                                  });
                                },
                                child: Text(
                                  isLogin
                                      ? "Belum punya akun? Register"
                                      : "Sudah punya akun? Login",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
