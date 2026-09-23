import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pos_nlh/app.dart';
import 'package:pos_nlh/firebase_options.dart';
import 'package:pos_nlh/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase ကို Initialize လုပ်ခြင်း
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final preferences = await SharedPreferences.getInstance();
  runApp(PosApp(preferencesService: PreferencesService(preferences)));
}
