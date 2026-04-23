import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String generateDummyJWT(String email) {
    final header = base64UrlEncode(
      utf8.encode(jsonEncode({"alg": "HS256", "typ": "JWT"})),
    );

    final payload = base64UrlEncode(
      utf8.encode(
        jsonEncode({
          "email": email,
          "role": "customer",
          "app": "smoker-shop",
          "iat": DateTime.now().millisecondsSinceEpoch,
        }),
      ),
    );

    final secret = "secret_key";

    final signatureRaw = "$header.$payload.$secret";

    final signature = base64UrlEncode(
      sha256.convert(utf8.encode(signatureRaw)).bytes,
    );

    return "$header.$payload.$signature";
  }

  Future<User?> register(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await result.user!.sendEmailVerification();

    return result.user;
  }

  Future<String> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    await result.user!.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || !user.emailVerified) {
      await _auth.signOut();
      throw Exception("Email belum diverifikasi");
    }

    final token = generateDummyJWT(email);

    return token;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
