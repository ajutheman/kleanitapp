
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
//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // for rootBundle
// import 'package:kleanitapp/core/constants/Spydo_pref_resources.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../core/constants/Sypdo_Constant.dart';
// import '../../core/theme/resizer/sypdo_fetch_pixels.dart';
// import '../../routes/app_routes..dart';
//
// class AppSplashScreen extends StatefulWidget {
//   const AppSplashScreen({Key? key}) : super(key: key);
//
//   @override
//   State<AppSplashScreen> createState() => _AppSplashScreenState();
// }
//
// class _AppSplashScreenState extends State<AppSplashScreen>
//     with TickerProviderStateMixin {
//   String loadingMessage = "Loading...";
//
//   // Animation controllers
//   late AnimationController _logoController;
//   late AnimationController _bubbleController;
//   late AnimationController _textController;
//   late AnimationController _progressController;
//   late AnimationController _sparkleController;
//
//   // Animations
//   late Animation<double> _logoScale;
//   late Animation<double> _logoRotation;
//   late Animation<double> _textFade;
//   late Animation<double> _textSlide;
//   late Animation<double> _progressValue;
//   late Animation<Offset> _logoSlide;
//   late Animation<double> _sparkleRotation;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _loadLoadingMessage();
//     _startAnimations();
//     _checkLoginStatus();
//   }
//
//   void _initializeAnimations() {
//     // Logo animation controller
//     _logoController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     );
//
//     // Bubble animation controller
//     _bubbleController = AnimationController(
//       duration: const Duration(milliseconds: 3000),
//       vsync: this,
//     )..repeat();
//
//     // Text animation controller
//     _textController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
//
//     // Progress animation controller
//     _progressController = AnimationController(
//       duration: const Duration(milliseconds: 2500),
//       vsync: this,
//     );
//
//     // Sparkle animation controller
//     _sparkleController = AnimationController(
//       duration: const Duration(milliseconds: 4000),
//       vsync: this,
//     )..repeat();
//
//     // Logo animations
//     _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
//       CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
//     );
//
//     _logoRotation = Tween<double>(begin: 0, end: 0.1).animate(
//       CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
//     );
//
//     _logoSlide = Tween<Offset>(
//       begin: const Offset(0, -0.5),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _logoController, curve: Curves.bounceOut));
//
//     // Text animations
//     _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
//     );
//
//     _textSlide = Tween<double>(begin: 30, end: 0).animate(
//       CurvedAnimation(parent: _textController, curve: Curves.easeOut),
//     );
//
//     // Progress animation
//     _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
//     );
//
//     // Sparkle animation
//     _sparkleRotation = Tween<double>(begin: 0, end: 2 * pi).animate(
//       CurvedAnimation(parent: _sparkleController, curve: Curves.linear),
//     );
//   }
//
//   void _startAnimations() {
//     // Start logo animation immediately
//     _logoController.forward();
//
//     // Start text animation after logo
//     Timer(const Duration(milliseconds: 500), () {
//       _textController.forward();
//     });
//
//     // Start progress animation
//     Timer(const Duration(milliseconds: 800), () {
//       _progressController.forward();
//     });
//   }
//
//   Future<void> _loadLoadingMessage() async {
//     try {
//       String jsonString = await rootBundle.loadString(
//         'assets/data/loading_message.json',
//       );
//       final Map<String, dynamic> jsonData = jsonDecode(jsonString);
//       setState(() {
//         loadingMessage = jsonData['message'] ?? "Preparing your cleaning experience...";
//       });
//     } catch (e) {
//       setState(() {
//         loadingMessage = "Preparing your cleaning experience...";
//       });
//     }
//   }
//
//   Future<void> _checkLoginStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString(AppPrefResources.USER_ACCESS_TOCKEN);
//     print(token);
//
//     // Wait 3 seconds for animations to complete
//     Timer(const Duration(seconds: 3), () {
//       if (token != null && token.isNotEmpty) {
//         AppConstant.sendToNextAndClear(context, AppRoutes.homeScreenRoute);
//       } else {
//         AppConstant.sendToNextAndClear(context, AppRoutes.loginRoute);
//       }
//     });
//   }
//
//   void backClick() {
//     AppConstant.backToPrev(context);
//   }
//
//   @override
//   void dispose() {
//     _logoController.dispose();
//     _bubbleController.dispose();
//     _textController.dispose();
//     _progressController.dispose();
//     _sparkleController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     FetchPixels(context);
//     return WillPopScope(
//       onWillPop: () async {
//         backClick();
//         return false;
//       },
//       child: Scaffold(
//         body: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Color.fromRGBO(0, 58, 69, 1),
//                 Color.fromRGBO(0, 88, 99, 1),
//                 Color.fromRGBO(0, 38, 49, 1),
//               ],
//               stops: [0.0, 0.5, 1.0],
//             ),
//           ),
//           child: Stack(
//             children: [
//               // Animated background bubbles
//               _buildFloatingBubbles(),
//
//               // Sparkle effects
//               _buildSparkleEffects(),
//
//               // Main content
//               Center(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 40),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       SizedBox(height: FetchPixels.getPixelHeight(30)),
//                       const Spacer(),
//
//                       // Animated logo with glow effect
//                       AnimatedBuilder(
//                         animation: _logoController,
//                         builder: (context, child) {
//                           return SlideTransition(
//                             position: _logoSlide,
//                             child: Transform.scale(
//                               scale: _logoScale.value,
//                               child: Transform.rotate(
//                                 angle: sin(_logoRotation.value * pi),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(100),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.white.withOpacity(0.3),
//                                         blurRadius: 30,
//                                         spreadRadius: 10,
//                                       ),
//                                     ],
//                                   ),
//                                   child: Image.asset(
//                                     "assets/icon/logo_dark.png",
//                                     width: FetchPixels.getPixelWidth(200),
//                                     height: FetchPixels.getPixelHeight(200),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//
//                       SizedBox(height: FetchPixels.getPixelHeight(60)),
//
//                       // Animated welcome text with shimmer effect
//                       AnimatedBuilder(
//                         animation: _textController,
//                         builder: (context, child) {
//                           return Transform.translate(
//                             offset: Offset(0, _textSlide.value),
//                             child: Opacity(
//                               opacity: _textFade.value,
//                               child: ShaderMask(
//                                 shaderCallback: (bounds) => LinearGradient(
//                                   colors: [
//                                     Colors.white,
//                                     Colors.blue.shade200,
//                                     Colors.white,
//                                   ],
//                                   stops: [0.0, 0.5, 1.0],
//                                 ).createShader(bounds),
//                                 child: Text(
//                                   "Welcome to Kleanit",
//                                   style: TextStyle(
//                                     fontSize: FetchPixels.getPixelHeight(28),
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                     letterSpacing: 1.2,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//
//                       SizedBox(height: FetchPixels.getPixelHeight(10)),
//
//                       // Subtitle
//                       AnimatedBuilder(
//                         animation: _textController,
//                         builder: (context, child) {
//                           return Transform.translate(
//                             offset: Offset(0, _textSlide.value),
//                             child: Opacity(
//                               opacity: _textFade.value * 0.8,
//                               child: Text(
//                                 "Professional Cleaning Services",
//                                 style: TextStyle(
//                                   fontSize: FetchPixels.getPixelHeight(16),
//                                   color: Colors.white.withOpacity(0.9),
//                                   fontWeight: FontWeight.w300,
//                                   letterSpacing: 0.5,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//
//                       const Spacer(),
//
//                       // Loading message with fade animation
//                       AnimatedBuilder(
//                         animation: _textController,
//                         builder: (context, child) {
//                           return Opacity(
//                             opacity: _textFade.value,
//                             child: Text(
//                               loadingMessage,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: FetchPixels.getPixelHeight(16),
//                                 color: Colors.white.withOpacity(0.8),
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//
//                       SizedBox(height: FetchPixels.getPixelHeight(20)),
//
//                       // Animated progress bar
//                       AnimatedBuilder(
//                         animation: _progressController,
//                         builder: (context, child) {
//                           return Container(
//                             width: FetchPixels.getPixelWidth(200),
//                             height: 4,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(2),
//                             ),
//                             child: Stack(
//                               children: [
//                                 Container(
//                                   width: FetchPixels.getPixelWidth(200) * _progressValue.value,
//                                   decoration: BoxDecoration(
//                                     gradient: LinearGradient(
//                                       colors: [
//                                         Colors.blue.shade300,
//                                         Colors.green.shade300,
//                                         Colors.blue.shade300,
//                                       ],
//                                     ),
//                                     borderRadius: BorderRadius.circular(2),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.blue.withOpacity(0.5),
//                                         blurRadius: 10,
//                                         spreadRadius: 1,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//
//                       SizedBox(height: FetchPixels.getPixelHeight(50)),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFloatingBubbles() {
//     return AnimatedBuilder(
//       animation: _bubbleController,
//       builder: (context, child) {
//         return Stack(
//           children: List.generate(6, (index) {
//             final double animationOffset = (index * 0.3) % 1.0;
//             final double bubbleAnimation = (_bubbleController.value + animationOffset) % 1.0;
//
//             return Positioned(
//               left: (index * 60.0 + 50) % MediaQuery.of(context).size.width,
//               top: MediaQuery.of(context).size.height * (0.2 + bubbleAnimation * 0.8),
//               child: Opacity(
//                 opacity: 0.1 + (sin(bubbleAnimation * pi) * 0.15),
//                 child: Container(
//                   width: 20 + (index % 3) * 15,
//                   height: 20 + (index % 3) * 15,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.white.withOpacity(0.3),
//                     border: Border.all(
//                       color: Colors.white.withOpacity(0.2),
//                       width: 1,
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }),
//         );
//       },
//     );
//   }
//
//   Widget _buildSparkleEffects() {
//     return AnimatedBuilder(
//       animation: _sparkleController,
//       builder: (context, child) {
//         return Stack(
//           children: List.generate(8, (index) {
//             final double sparkleOffset = (index * 0.125) % 1.0;
//             final double sparkleAnimation = (_sparkleController.value + sparkleOffset) % 1.0;
//
//             return Positioned(
//               left: (index * 45.0 + 30) % MediaQuery.of(context).size.width,
//               top: (index * 80.0 + 100) % MediaQuery.of(context).size.height,
//               child: Transform.rotate(
//                 angle: _sparkleRotation.value + (index * 0.5),
//                 child: Opacity(
//                   opacity: 0.3 + (sin(sparkleAnimation * 2 * pi) * 0.4),
//                   child: Icon(
//                     Icons.auto_awesome,
//                     size: 12 + (index % 2) * 8,
//                     color: Colors.white.withOpacity(0.6),
//                   ),
//                 ),
//               ),
//             );
//           }),
//         );
//       },
//     );
//   }
// }