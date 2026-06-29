import 'package:flutter/material.dart';
import 'package:smoker_app/core/constants/app_colors.dart';
import 'package:smoker_app/core/routes/app_router.dart';
import 'package:smoker_app/core/services/biometric_service.dart';
import 'package:smoker_app/core/services/secure_storage.dart';
import 'package:smoker_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isBiometricEnabled = false;
  bool _isBiometricSupported = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
    final isSupported = await BiometricService().isBiometricAvailable();
    final isEnabled = await SecureStorage.getBiometricStatus();
    if (mounted) {
      setState(() {
        _isBiometricSupported = isSupported;
        _isBiometricEnabled = isEnabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.firebaseUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primaryLight.withOpacity(0.15),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.displayName != null && user!.displayName!.isNotEmpty
                          ? user.displayName![0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? 'User Toko',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user?.email ?? 'email@example.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings/Options Section
            Text(
              'Pengaturan Akun',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryLight.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.person_outline,
                    title: 'Detail Informasi Profil',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildProfileTile(
                    icon: Icons.security_outlined,
                    title: 'Keamanan & Sandi',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildProfileTile(
                    icon: Icons.notifications_none_outlined,
                    title: 'Pengaturan Notifikasi',
                    onTap: () {},
                  ),
                  
                  // Biometric Toggle Switch
                  if (_isBiometricSupported) ...[
                    const Divider(height: 1, indent: 56),
                    SwitchListTile(
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.fingerprint, color: AppColors.primary, size: 20),
                      ),
                      title: Text(
                        'Login Biometrik / Sidik Jari',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      activeColor: AppColors.primary,
                      value: _isBiometricEnabled,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      onChanged: (bool value) async {
                        if (value) {
                          // Authenticate to confirm enabling biometrics
                          final authenticated = await BiometricService().authenticate(
                            reason: 'Konfirmasi sidik jari Anda untuk mengaktifkan login biometrik',
                          );
                          if (authenticated) {
                            await SecureStorage.saveBiometricStatus(true);
                            setState(() {
                              _isBiometricEnabled = true;
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Login sidik jari berhasil diaktifkan')),
                              );
                            }
                          }
                        } else {
                          await SecureStorage.saveBiometricStatus(false);
                          setState(() {
                            _isBiometricEnabled = false;
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Login sidik jari dinonaktifkan')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryLight.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.help_outline_outlined,
                    title: 'Pusat Bantuan',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildProfileTile(
                    icon: Icons.info_outline,
                    title: 'Tentang Aplikasi',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Logout Button
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Keluar dari Akun'),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Konfirmasi'),
                    content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Keluar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await auth.logout();
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, AppRouter.login);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary.withOpacity(0.8),
        size: 18,
      ),
      onTap: onTap,
    );
  }
}
