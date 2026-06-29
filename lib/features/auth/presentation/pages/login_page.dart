
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:matrial_1123150086_uts/core/constants/app_colors.dart';
import 'package:matrial_1123150086_uts/core/routes/app_router.dart';
import 'package:matrial_1123150086_uts/core/shared/widgets/auth_header.dart';
import 'package:matrial_1123150086_uts/core/shared/widgets/custom_button.dart';
import 'package:matrial_1123150086_uts/core/shared/widgets/custom_text_field.dart';
import 'package:matrial_1123150086_uts/core/shared/widgets/divider_with_text.dart';
import 'package:matrial_1123150086_uts/core/shared/widgets/google_sign_in_button.dart';
import 'package:matrial_1123150086_uts/core/shared/widgets/loading_overlay.dart';
import 'package:matrial_1123150086_uts/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:matrial_1123150086_uts/core/services/secure_storage.dart';
import 'package:matrial_1123150086_uts/core/services/biometric_service.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPass = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricAutoLogin();
    });
  }

  Future<void> _checkBiometricAutoLogin() async {
    final token = await SecureStorage.getToken();
    if (token == null) return;

    final biometricEnabled = await SecureStorage.getBiometricStatus();

    if (biometricEnabled) {
      final biometricService = BiometricService();
      final isAvailable = await biometricService.isBiometricAvailable();
      if (isAvailable) {
        final authenticated = await biometricService.authenticate(
          reason: 'Verifikasi sidik jari Anda untuk masuk kembali ke aplikasi',
        );
        if (authenticated) {
          if (!mounted) return;
          await context.read<AuthProvider>().restoreSession();
          Navigator.pushReplacementNamed(context, AppRouter.dashboard);
        }
      } else {
        // Biometrik tidak tersedia di hardware, tapi ada token
        if (!mounted) return;
        await context.read<AuthProvider>().restoreSession();
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      }
    } else {
      // Biometrik tidak aktif, tapi ada token (langsung masuk)
      if (!mounted) return;
      await context.read<AuthProvider>().restoreSession();
      Navigator.pushReplacementNamed(context, AppRouter.dashboard);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  /// Handler untuk login email/password
  Future<void> _loginEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.loginWithEmail(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    _handleLoginResult(ok, auth);
  }

  /// Handler untuk login Google
  Future<void> _loginGoogle() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginWithGoogle();
    if (!mounted) return;
    _handleLoginResult(ok, auth);
  }

  /// Routing berdasarkan hasil login
  void _handleLoginResult(bool ok, AuthProvider auth) {
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRouter.dashboard);
    } else if (auth.status == AuthStatus.emailNotVerified) {
      Navigator.pushReplacementNamed(context, AppRouter.verifyEmail);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Login gagal'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Password'),
        content: CustomTextField(
          label: 'Email',
          hint: 'Email terdaftar',
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          // ElevatedButton(
          //   onPressed: () async {
          //     await Fire.instance.sendPasswordResetEmail(
          //       email: ctrl.text.trim(),
          //     );
          //     if (context.mounted) Navigator.pop(context);
          //   },
          //   child: const Text('Kirim'),
          // ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Masuk ke akun...',
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  const AuthHeader(
                    icon: Icons.house,
                    title: 'Selamat Datang',
                    subtitle: 'Masuk ke akun Anda untuk melanjutkan',
                    iconColor: AppColors.primary,
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    label: 'Email',
                    hint: 'contoh@email.com',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Email wajib diisi';
                      if (!EmailValidator.validate(v!)) {
                        return 'Format email salah';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Password',
                    hint: 'Masukkan password',
                    controller: _passCtrl,
                    obscureText: !_showPass,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPass ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _showPass = !_showPass),
                    ),
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'Password wajib diisi' : null,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showForgotPasswordDialog(context),
                      child: const Text('Lupa Password?'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    label: 'Masuk',
                    onPressed: _loginEmail,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 20),
                  const DividerWithText(text: 'atau masuk dengan'),
                  const SizedBox(height: 20),
                   GoogleSignInButton(
                    onPressed: _loginGoogle,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<bool>(
                    future: SecureStorage.getBiometricStatus(),
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.fingerprint, size: 56, color: AppColors.primary),
                              onPressed: _checkBiometricAutoLogin,
                              tooltip: 'Masuk dengan Sidik Jari',
                            ),
                            const Text(
                              'Masuk dengan Sidik Jari',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Belum punya akun? '),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                          context,
                          AppRouter.register,
                        ),
                        child: Text(
                          'Daftar',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
