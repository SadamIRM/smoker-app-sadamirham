import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> register(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await result.user!.sendEmailVerification();
    return result.user;
  }

  Future<User?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    await result.user!.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (!user!.emailVerified) {
      await _auth.signOut();
      throw Exception("Email belum diverifikasi");
    }

    return user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
