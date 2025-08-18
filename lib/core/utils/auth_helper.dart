// lib/core/utils/auth_helper.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kleanitapp/main.dart' show navigatorKey;
// import 'package:kleanitapp/main.dart';
// import 'package:kleanitapp/presentation/screens/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/screens/AppSplashScreen.dart';
import '../constants/Spydo_pref_resources.dart';

Future<void> handleUnauthorized() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(AppPrefResources.USER_ACCESS_TOCKEN);

  try {
    await GoogleSignIn().signOut();
  } catch (_) {}

  await FirebaseAuth.instance.signOut();

  navigatorKey.currentState?.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => AppSplashScreen()), (route) => false);
}
