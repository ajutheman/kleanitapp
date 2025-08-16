import 'package:flutter/material.dart';
import 'package:kleanitapp/features/auth/screens/AppEditProfileScreen.dart';
import 'package:kleanitapp/features/home/Apphome_main.dart';

import '../features/auth/screens/AppLoginScreen.dart';
import '../features/auth/screens/Appotp_login_screen.dart';
import '../features/auth/screens/Appotp_verification_screen.dart';
import '../features/categories/screen/AppCategoryDetailScreen.dart';
// import '../features/home/category_detail_screen.dart';  // Import the category detail screen.
import '../features/categories/screen/Appcategorydeatilscreenforadd.dart';
import '../presentation/screens/AppSplashScreen.dart';

class AppRouteBuilder {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AppSplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const AppLoginScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => AppHomeMainView());
      case '/otp_login':
        return MaterialPageRoute(builder: (_) => const AppOTPLoginScreen());
      case '/otp_verification':
        final mobile = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => AppOTPVerificationScreen(mobile: mobile));
      case '/edit_profile':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => AppEditProfileScreen(isFirstTimeGoogleLogin: args?['isFirstTimeGoogleLogin'] ?? false));

      case '/categoryDetail':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => AppCategoryDetailScreen(type: args["type"], category: args["category"]));
      case 'CategoryDetailScreenforadd':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => AppCategoryDetailScreenforadd(mainCategoryId: args["main_category_id"], type: args["type"], category: args["category"]));
      default:
        return MaterialPageRoute(builder: (_) => Scaffold(body: Center(child: Text("No route defined for ${settings.name}"))));
    }
  }
}
