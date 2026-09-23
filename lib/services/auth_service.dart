import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // လက်ရှိ User ရဲ့ State ကို စောင့်ကြည့်ရန် Stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current User ရယူရန်
  User? get currentUser => _auth.currentUser;

  // Sign Up (အကောင့်သစ်ဖွင့်ခြင်း)
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign In / Login (အကောင့်ဝင်ခြင်း)
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign Out (အကောင့်ထွက်ခြင်း)
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Error Message များကို မြန်မာလို/ရှင်းရှင်းလင်းလင်း ပြောင်းပေးခြင်း
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'ဒီ Email နဲ့ အကောင့်ရှာမတွေ့ပါ။';
      case 'wrong-password':
        return 'စကားဝှက် (Password) မှားယွင်းနေပါသည်။';
      case 'email-already-in-use':
        return 'ဒီ Email က အသုံးပြုပြီးသား ဖြစ်နေပါသည်။';
      case 'invalid-email':
        return 'Email ပုံစံ မမှန်ကန်ပါ။';
      case 'weak-password':
        return 'Password သည် အနည်းဆုံး ၆ လုံး ရှိရပါမည်။';
      default:
        return e.message ?? 'အမှားတစ်ခု ဖြစ်ပွားခဲ့ပါသည်။';
    }
  }
}
