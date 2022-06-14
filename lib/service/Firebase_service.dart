import 'package:chat_app/service/const.dart';

class FirebaseAuthService {
  static Future<bool> signUp(String? email, String? password) async {
    await kFirebaseAuth.createUserWithEmailAndPassword(
        password: password!, email: email!);

    return true;
  }

  static Future<bool> logIn(String? email, String? password) async {
    await kFirebaseAuth.signInWithEmailAndPassword(
        password: password!, email: email!);

    return true;
  }

  static logOut() async {
    await kFirebaseAuth.signOut();
  }

  static Future<bool> forgetPassword(String? email) async {
    await kFirebaseAuth.sendPasswordResetEmail(email: email!);
    return true;
  }
}
