import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? get currentUser => _auth.currentUser;

  // Login Function
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _setLoading(false);
      return true; // Login အောင်မြင်သည်
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _setLoading(false);
      return false; // Login မအောင်မြင်ပါ
    } catch (e) {
      _errorMessage = 'အမှားတစ်ခု ဖြစ်ပွားခဲ့ပါသည်: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'ဒီ Email ဖြင့် အကောင့်ရှာမတွေ့ပါ။';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email သို့မဟုတ် Password မှားယွင်းနေပါသည်။';
      case 'invalid-email':
        return 'Email ပုံစံ မမှန်ကန်ပါ။';
      case 'user-disabled':
        return 'ဤအကောင့်ကို ပိတ်ထားပါသည်။';
      default:
        return 'Login ဝင်၍ မရပါ၊ ပြန်လည် ကြိုးစားကြည့်ပါ။';
    }
  }
}
