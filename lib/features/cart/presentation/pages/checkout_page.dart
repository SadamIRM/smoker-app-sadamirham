import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:matrial_1123150086_uts/core/constants/app_colors.dart';
import 'package:matrial_1123150086_uts/core/constants/app_constants.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import 'payment_success_page.dart';
import 'awaiting_payment_page.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'Wallet Ku';

  void _processCheckout() async {
    setState(() {
      _isProcessing = true;
    });

    final checkoutProvider = context.read<CheckoutProvider>();
    final totalAmount = context.read<CartProvider>().totalPrice;
    final success = await checkoutProvider.processCheckout(_selectedPaymentMethod);

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      if (success) {
        final txNumber = checkoutProvider.orderId ?? 'TRX-${DateTime.now().millisecondsSinceEpoch}';

        // Refresh local cart state in provider (since it was cleared in backend)
        context.read<CartProvider>().clearLocalCart();

        if (_selectedPaymentMethod == 'Wallet Ku') {
          final uri = Uri(
            scheme: 'dompetkampus',
            host: 'pay',
            queryParameters: {
              'merchant_id': 'merchant_uts_1123150086',
              'merchant_name': 'Toko Material Felan',
              'amount': totalAmount.toStringAsFixed(0),
              'description': 'Pembayaran Order $txNumber',
              'reference': txNumber,
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

          // Arahkan ke AwaitingPaymentPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AwaitingPaymentPage(
                transactionNumber: txNumber,
                totalAmount: totalAmount,
              ),
            ),
          );
        } else {
          // Arahkan ke PaymentSuccessPage untuk metode lainnya
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
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran gagal. Silakan coba lagi.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isProcessing,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Checkout Belanja',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          elevation: 0,
          automaticallyImplyLeading: !_isProcessing,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body: Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            if (cartProvider.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Keranjang Kosong',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // Step Indicator
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                        child: Row(
                          children: [
                            _buildStepIndicator(1, true),
                            Expanded(
                              child: Container(
                                height: 2,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            _buildStepIndicator(2, true),
                            Expanded(
                              child: Container(
                                height: 2,
                                color: AppColors.primaryLight.withOpacity(0.3),
                              ),
                            ),
                            _buildStepIndicator(3, false),
                          ],
                        ),
                      ),
                      // Order Summary Header
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryLight.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ringkasan Pesanan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Jumlah Item',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${cartProvider.itemCount} Item',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Items List
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cartProvider.items.length,
                          itemBuilder: (context, index) {
                            final item = cartProvider.items[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primaryLight.withOpacity(0.15),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AppColors.primaryLight.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: item.imageUrl != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.network(
                                                item.imageUrl!,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Icon(
                                              Icons.image,
                                              color: AppColors.primaryLight,
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.productName,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Qty: ${item.quantity}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Rp ${item.price.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Rp ${item.totalPrice.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Payment Method Section
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryLight.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Metode Pembayaran',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildPaymentMethodOption(
                              id: 'Wallet Ku',
                              title: 'Wallet Ku (E-Money)',
                              subtitle: 'Bayar instan menggunakan saldo Wallet Ku Anda',
                              icon: Icons.account_balance_wallet_outlined,
                            ),
                            const Divider(height: 16),
                            _buildPaymentMethodOption(
                              id: 'Bank Transfer',
                              title: 'Transfer Bank (VA)',
                              subtitle: 'Bayar via BCA, Mandiri, BRI, dll.',
                              icon: Icons.account_balance_outlined,
                            ),
                            const Divider(height: 16),
                            _buildPaymentMethodOption(
                              id: 'QRIS',
                              title: 'QRIS / E-Wallet',
                              subtitle: 'Gopay, OVO, ShopeePay, LinkAja',
                              icon: Icons.qr_code_2_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Price Breakdown
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildPriceRow('Subtotal', 'Rp ${cartProvider.totalPrice.toStringAsFixed(0)}'),
                            const SizedBox(height: 8),
                            Divider(color: AppColors.divider, thickness: 1),
                            const SizedBox(height: 8),
                            _buildPriceRow('Ongkir', 'Gratis', isDiscount: true),
                            const SizedBox(height: 8),
                            Divider(color: AppColors.divider, thickness: 1),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Pembayaran',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Rp ${cartProvider.totalPrice.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                // Bottom Checkout Button
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Lanjutkan ke Pembayaran',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, bool isActive) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.background,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryLight,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String price, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          price,
          style: TextStyle(
            fontSize: 14,
            color: isDiscount ? AppColors.primary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethod == id;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: id,
              groupValue: _selectedPaymentMethod,
              activeColor: AppColors.primary,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedPaymentMethod = val;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

