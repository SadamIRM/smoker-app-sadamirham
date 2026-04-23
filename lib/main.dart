import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCSIHfcKw7SiCKQgqoSnEwuIpl1Yz0rpno",
      authDomain: "smoker-apps.firebaseapp.com",
      projectId: "smoker-apps",
      storageBucket: "smoker-apps.firebasestorage.app",
      messagingSenderId: "688428289423",
      appId: "1:688428289423:web:a6eea4c4cd345033830ffa",
      measurementId: "G-DGFG9VWRET",
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smoker App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Auth Page")),
        body: Center(child: Text("tes")),
      ),
    );
  }
}
