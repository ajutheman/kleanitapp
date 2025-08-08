// lib/core/utils/auth_helper.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kleanitapp/main.dart' show navigatorKey;
// import 'package:kleanit/main.dart';
// import 'package:kleanit/presentation/screens/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../presentation/screens/SplashScreen.dart';
import '../constants/pref_resources.dart';
import 'package:flutter/material.dart';

Future<void> handleUnauthorized() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(PrefResources.USER_ACCESS_TOCKEN);

  try {
    await GoogleSignIn().signOut();
  } catch (_) {}

  await FirebaseAuth.instance.signOut();

  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => SplashScreen()),
    (route) => false,
  );
}
