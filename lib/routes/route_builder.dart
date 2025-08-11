import 'package:flutter/material.dart';
import 'package:kleanitapp/features/auth/screens/EditProfileScreen.dart';
import 'package:kleanitapp/features/home/home_main.dart';

import '../features/auth/screens/LoginScreen.dart';
import '../features/auth/screens/otp_login_screen.dart';
import '../features/auth/screens/otp_verification_screen.dart';
import '../features/categories/screen/CategoryDetailScreen.dart';
// import '../features/home/category_detail_screen.dart';  // Import the category detail screen.
import '../features/categories/screen/categorydeatilscreenforadd.dart';
import '../presentation/screens/SplashScreen.dart';

class RouteBuilder {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => HomeMainView());
      case '/otp_login':
        return MaterialPageRoute(builder: (_) => const OTPLoginScreen());
      case '/otp_verification':
        final mobile = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => OTPVerificationScreen(mobile: mobile));
      case '/edit_profile':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => EditProfileScreen(isFirstTimeGoogleLogin: args?['isFirstTimeGoogleLogin'] ?? false));

      case '/categoryDetail':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => CategoryDetailScreen(type: args["type"], category: args["category"]));
      case 'CategoryDetailScreenforadd':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => CategoryDetailScreenforadd(mainCategoryId: args["main_category_id"], type: args["type"], category: args["category"]));
      default:
        return MaterialPageRoute(builder: (_) => Scaffold(body: Center(child: Text("No route defined for ${settings.name}"))));
    }
  }
}
