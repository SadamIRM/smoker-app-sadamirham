import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:smoker_app/core/constants/app_strings.dart';
import 'package:smoker_app/core/constants/app_constants.dart';
import 'package:smoker_app/core/routes/app_router.dart';
import 'package:smoker_app/core/services/secure_storage.dart';
import 'package:smoker_app/core/services/dio_client.dart';
import 'package:smoker_app/core/theme/app_theme.dart';
import 'package:smoker_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:smoker_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:smoker_app/features/cart/presentation/providers/checkout_provider.dart';
import 'package:smoker_app/features/cart/presentation/pages/payment_success_page.dart';
import 'package:smoker_app/features/dashboard/presentation/providers/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:smoker_app/core/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDeepLinkListener();
    });
  }

  void _initDeepLinkListener() {
    try {
      _appLinks.uriLinkStream.listen(
        (uri) {
          debugPrint('[StoreSmoke] Deep link masuk: $uri');
          if (uri.scheme == 'smokestore' && uri.host == 'callback') {
            _handleCallback(uri);
          }
        },
        onError: (e) {
          debugPrint('[StoreSmoke] Error deep link stream: $e');
        },
      );
    } catch (e) {
      debugPrint('[StoreSmoke] Gagal mendaftarkan deep link listener: $e');
    }
  }

  String? _lastProcessedKey;

  Future<void> _handleCallback(Uri uri) async {
    final status = uri.queryParameters['status'];
    final reference = uri.queryParameters['reference'];

    debugPrint(
      '[StoreSmoke] Callback status: $status, reference: $reference',
    );

    if (reference == null ||
        reference.isEmpty ||
        status == null ||
        status.isEmpty)
      return;

    final callbackKey = '${reference}_$status';

    // Cegah pemrosesan ganda untuk kunci referensi + status yang sama dalam waktu singkat
    if (_lastProcessedKey == callbackKey) {
      debugPrint(
        '[StoreSmoke] Kunci callback $callbackKey sudah diproses, diabaikan.',
      );
      return;
    }
    _lastProcessedKey = callbackKey;

    // Bersihkan last processed setelah beberapa detik
    Future.delayed(const Duration(seconds: 5), () {
      if (_lastProcessedKey == callbackKey) {
        _lastProcessedKey = null;
      }
    });

    // TUNDA 600ms agar Flutter selesai memulihkan UI setelah resume dari background
    await Future.delayed(const Duration(milliseconds: 600));

    if (status == 'success') {
      try {
        final response = await DioClient.instance.get(
          '${AppConstants.baseUrl}/transactions/callback?status=success&reference=$reference',
        );
        debugPrint(
          '[StoreSmoke] Callback backend response: ${response.statusCode}',
        );
      } catch (e) {
        debugPrint('[StoreSmoke] Gagal update status ke backend: $e');
      }

      // Kirim Notifikasi Latar Belakang (System Notification)
      NotificationService().showPaymentNotification(
        title: 'Pembayaran Berhasil',
        body: 'Transaksi $reference berhasil dibayar via Smoke Money.',
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(
              onSuccess: () {
                _navigatorKey.currentState?.popUntil((route) => route.isFirst);
              },
            ),
          ),
          (route) => route.isFirst,
        );
      });
    } else {
      final message = status == 'cancelled'
          ? 'Pembayaran dibatalkan.'
          : 'Pembayaran gagal. Silakan coba lagi.';

      debugPrint('[StoreSmoke] Pembayaran status $status: $message');

      // Kirim Notifikasi Latar Belakang (System Notification) - Silent (Hanya masuk drawer, tidak pop-up melayang)
      NotificationService().showPaymentNotification(
        title: status == 'cancelled'
            ? 'Pembayaran Dibatalkan'
            : 'Pembayaran Gagal',
        body: status == 'cancelled'
            ? 'Pembayaran untuk transaksi $reference telah dibatalkan.'
            : 'Transaksi $reference gagal diproses.',
        isSilent: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRouter.splash,
      routes: AppRouter.routes,
      onGenerateRoute: (settings) {
        final builder =
            AppRouter.routes[settings.name] ??
            AppRouter.routes[AppRouter.splash]!;
        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2)); // Animasi splash
    if (!mounted) return;

    final token = await SecureStorage.getToken();
    final route = token != null ? AppRouter.dashboard : AppRouter.login;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
