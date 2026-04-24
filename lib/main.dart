import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCn5CiyqIuNJaQMy8APJHkWYNady7vb0Gs",
      authDomain: "smoker-app-sadam.firebaseapp.com",
      projectId: "smoker-app-sadam",
      storageBucket: "smoker-app-sadam.firebasestorage.app",
      messagingSenderId: "542694944693",
      appId: "1:542694944693:web:abd7e49e39966b5411f3fc",
      measurementId: "G-8LXZRKW5JL",
    ),
  );

  runApp(ChangeNotifierProvider(create: (_) => AuthProvider(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smoker App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.brown,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: AuthWrapper(),
    );
  }
}
