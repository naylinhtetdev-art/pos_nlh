import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_nlh/screens/home_screen.dart';
import 'package:pos_nlh/screens/login_screen.dart';
import 'package:pos_nlh/services/auth_service.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Data မလာသေးမီ Loading ပြခြင်း
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User Login ဝင်ထားလျှင် HomeScreen သို့ သွားမည်
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Login မဝင်ရသေးပါက LoginScreen ပြမည်
        return const LoginScreen();
      },
    );
  }
}
