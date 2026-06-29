import 'package:flutter/material.dart';
import 'package:matrial_1123150086_uts/core/constants/app_colors.dart';
import 'package:matrial_1123150086_uts/core/constants/app_constants.dart';
import 'package:matrial_1123150086_uts/core/services/dio_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'payment_success_page.dart';

class AwaitingPaymentPage extends StatefulWidget {
  final String transactionNumber;
  final double totalAmount;

  const AwaitingPaymentPage({
    Key? key,
    required this.transactionNumber,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<AwaitingPaymentPage> createState() => _AwaitingPaymentPageState();
}

class _AwaitingPaymentPageState extends State<AwaitingPaymentPage> {
  bool _isChecking = false;

  Future<void> _checkPaymentStatus() async {
    setState(() {
      _isChecking = true;
    });

    try {
      final response = await DioClient.instance.get(AppConstants.transactions);
      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        // Cari transaksi berdasarkan nomor transaksi
        final tx = data.firstWhere(
          (json) => json['transaction_number'] == widget.transactionNumber,
          orElse: () => null,
        );

        if (tx != null && tx['status'] == 'Selesai') {
          if (!mounted) return;
          // Pembayaran berhasil! Arahkan ke Halaman Sukses
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessPage(
                onSuccess: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ),
          );
          return;
        }
      }
      
      // Jika belum dibayar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran belum diterima. Silakan selesaikan di aplikasi Wallet Ku.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengecek status pembayaran: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _relaunchWalletKu() async {
    final uri = Uri(
      scheme: 'dompetkampus',
      host: 'pay',
      queryParameters: {
        'merchant_id': 'merchant_uts_1123150086',
        'merchant_name': 'Toko Material Felan',
        'amount': widget.totalAmount.toStringAsFixed(0),
        'description': 'Pembayaran Order ${widget.transactionNumber}',
        'reference': widget.transactionNumber,
        'callback': 'tokomaterial://callback',
      },
    );

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aplikasi Wallet Ku tidak ditemukan/terinstall.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka Wallet Ku: Aplikasi tidak terinstall.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Jangan biarkan back gesture
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Menunggu Pembayaran'),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Warning / Pending Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.orange.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(
                    Icons.hourglass_empty_rounded,
                    color: Colors.orange,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Menunggu Pembayaran',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan selesaikan pembayaran Anda di aplikasi Wallet Ku',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Detail Box
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryLight.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildRow('Nomor Transaksi', widget.transactionNumber),
                      const Divider(height: 24),
                      _buildRow('Jumlah Bayar', 'Rp ${widget.totalAmount.toStringAsFixed(0)}'),
                      const Divider(height: 24),
                      _buildRow('Metode Pembayaran', 'Wallet Ku (E-Money)'),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Action Buttons
                ElevatedButton.icon(
                  icon: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: const Text('Cek Status Pembayaran'),
                  onPressed: _isChecking ? null : _checkPaymentStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Buka Ulang Wallet Ku'),
                  onPressed: _relaunchWalletKu,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Text(
                    'Kembali ke Beranda (Bayar Nanti)',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
