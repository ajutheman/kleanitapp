
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for rootBundle
import 'package:kleanitapp/core/constants/Spydo_pref_resources.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/Sypdo_Constant.dart';
import '../../core/theme/resizer/sypdo_fetch_pixels.dart';
import '../../routes/app_routes..dart';

class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({Key? key}) : super(key: key);

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen> {
  String loadingMessage = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadLoadingMessage();
    _checkLoginStatus();
  }

  Future<void> _loadLoadingMessage() async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/data/loading_message.json',
      );
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      setState(() {
        loadingMessage = jsonData['message'] ?? "Loading...";
      });
    } catch (e) {
      setState(() {
        loadingMessage = "Loading...";
      });
    }
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // /// add this code avoid login screen
    // await prefs.setString(PrefResources.USER_ACCESS_TOCKEN, '76|C9JAQzDboXqn2h4jzAug4LJZvS3QjihNC0K7gDiT79a951c1');
    // var result = await prefs.remove(PrefResources.USER_ACCESS_TOCKEN);

    final token = prefs.getString(AppPrefResources.USER_ACCESS_TOCKEN);
    print(token);
    // Wait 2 seconds then navigate based on login status.
    Timer(const Duration(seconds: 2), () {
      if (token != null && token.isNotEmpty) {
        AppConstant.sendToNextAndClear(context, AppRoutes.homeScreenRoute);
      } else {
        AppConstant.sendToNextAndClear(context, AppRoutes.loginRoute);
      }
    });
  }

  void backClick() {
    AppConstant.backToPrev(context);
  }

  @override
  Widget build(BuildContext context) {
    FetchPixels(context);
    return WillPopScope(
      onWillPop: () async {
        backClick();
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(0, 58, 69, 1),
            // Color(0xFF077975),
          ),
          child: Center(
            child: Container(
              color: Color.fromRGBO(0, 58, 69, 1),
              // Color(0xFF077975),
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: FetchPixels.getPixelHeight(30)),
                  // Splash logo.
                  const Spacer(),
                  Image.asset(
                    "assets/icon/logo_dark.png",
                    // "assets/icon/logo_light.png",
                    width: FetchPixels.getPixelWidth(200),
                    height: FetchPixels.getPixelHeight(200),
                  ),
                  SizedBox(height: FetchPixels.getPixelHeight(40)),

                  // Welcome text.
                  // Text(
                  //   "Welcome to Kleanit",
                  //   style: TextStyle(
                  //     fontSize: FetchPixels.getPixelHeight(24),
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.white,
                  //   ),
                  // ),
                  // SizedBox(height: FetchPixels.getPixelHeight(150)),
                  const Spacer(),
                  Text(
                    loadingMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: FetchPixels.getPixelHeight(16),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: FetchPixels.getPixelHeight(30)),

                  // Progress indicator.
                  // CircularProgressIndicator(
                  //   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
