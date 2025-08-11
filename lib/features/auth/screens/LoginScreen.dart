// import 'dart:developer';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:kleanitapp/core/constants/Constant.dart';
// import 'package:kleanitapp/core/theme/color_data.dart';
// import 'package:kleanitapp/core/theme/resizer/fetch_pixels.dart';
// import 'package:kleanitapp/core/theme/widget_utils.dart';
// import 'package:kleanitapp/features/auth/bloc/auth/auth_bloc.dart';
// import 'package:kleanitapp/features/auth/bloc/auth/auth_event.dart';
// import 'package:kleanitapp/features/auth/bloc/auth/auth_state.dart';
// import 'package:kleanitapp/routes/app_routes..dart';
// import 'package:kleanitapp/services/auth_service.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   void finishView() {
//     Constant.closeApp();
//   }
//
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   bool isPass = true;
//   bool _isLoading = false;
//   final AuthService _authService = AuthService();
//
//   @override
//   Widget build(BuildContext context) {
//     // Initialize the resizer.
//     FetchPixels(context);
//     return WillPopScope(
//       onWillPop: () async {
//         finishView();
//         return false; // Prevent default pop behavior.
//       },
//       child: Scaffold(
//         resizeToAvoidBottomInset: false,
//         backgroundColor: backGroundColor,
//         body: SafeArea(
//           child: BlocConsumer<AuthBloc, AuthState>(
//             listener: (context, state) {
//               if (state is AuthLoading) {
//                 showDialog(context: context, builder: (_) => Center(child: CircularProgressIndicator()));
//               } else if (state is AuthFailure) {
//                 Navigator.pop(context);
//
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text("Login failed: ${state.error}")),
//                 );
//               } else if (state is AuthSuccess) {
//                 Navigator.pop(context);
//
//                 // Navigate to HomeScreen on successful login.
//                 Constant.sendToNext(context, Routes.homeScreenRoute);
//               }
//             },
//             builder: (context, state) {
//               return Container(
//                 width: double.infinity,
//                 height: double.infinity,
//                 padding: EdgeInsets.symmetric(
//                   horizontal: FetchPixels.getDefaultHorSpace(context),
//                 ),
//                 child: ListView(
//                   primary: true,
//                   shrinkWrap: true,
//                   children: [
//                     getVerSpace(FetchPixels.getPixelHeight(70)),
//                     Align(
//                       alignment: Alignment.topCenter,
//                       child: getCustomFont("Login", 24, Colors.black, 1, fontWeight: FontWeight.w800),
//                     ),
//                     getVerSpace(FetchPixels.getPixelHeight(10)),
//                     Align(
//                       alignment: Alignment.topCenter,
//                       child: getCustomFont(
//                         "Glad to meet you again!",
//                         16,
//                         Colors.black,
//                         1,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                     getVerSpace(FetchPixels.getPixelHeight(30)),
//                     getVerSpace(FetchPixels.getPixelHeight(50)),
//                     // Google Login Button integrated with BLoC.
//                     getButton(
//                       context,
//                       Colors.white,
//                       "Login with Google",
//                       Colors.black,
//                       () async {
//                         if (_isLoading) return;
//                         setState(() {
//                           _isLoading = true;
//                         });
//                         try {
//                           UserCredential userCredential = await _authService.signInWithGoogle();
//                           final idToken = await userCredential.user!.getIdToken();
//                           log("idToken: $idToken");
//                           context.read<AuthBloc>().add(
//                                 GoogleLoginRequested(
//                                   idToken: idToken.toString(),
//                                 ),
//                               );
//                         } on PlatformException catch (e) {
//                           print(e.message);
//                           print(e.code);
//                           print(e.details);
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text("Google Sign-In failed: $e")),
//                           );
//                         } catch (e) {
//                           print(e);
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text("Google Sign-In failed: $e")),
//                           );
//                         } finally {
//                           setState(() {
//                             _isLoading = false;
//                           });
//                         }
//                       },
//                       18,
//                       weight: FontWeight.w600,
//                       isIcon: true,
//                       image: "google.svg",
//                       buttonHeight: FetchPixels.getPixelHeight(60),
//                       borderRadius: BorderRadius.circular(
//                         FetchPixels.getPixelHeight(15),
//                       ),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 10,
//                           offset: Offset(0.0, 4.0),
//                         ),
//                       ],
//                     ),
//                     getVerSpace(FetchPixels.getPixelHeight(20)),
//                     // Phone OTP Login Button: Navigate to OTP Login Screen.
//                     getButton(
//                       context,
//                       Colors.white,
//                       "Login with Phone OTP",
//                       Colors.black,
//                       () {
//                         Constant.sendToNext(context, Routes.otpLoginRoute);
//                       },
//                       18,
//                       weight: FontWeight.w600,
//                       isIcon: true,
//                       image: "phone.svg",
//                       buttonHeight: FetchPixels.getPixelHeight(60),
//                       borderRadius: BorderRadius.circular(
//                         FetchPixels.getPixelHeight(15),
//                       ),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 10,
//                           offset: Offset(0.0, 4.0),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
// lib/presentation/screens/login_screen.dart

import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kleanitapp/core/constants/Constant.dart';
import 'package:kleanitapp/core/theme/color_data.dart';
import 'package:kleanitapp/core/theme/resizer/fetch_pixels.dart';
import 'package:kleanitapp/features/auth/bloc/auth/auth_bloc.dart';
import 'package:kleanitapp/features/auth/bloc/auth/auth_event.dart';
import 'package:kleanitapp/features/auth/bloc/auth/auth_state.dart';
import 'package:kleanitapp/routes/app_routes..dart';
import 'package:kleanitapp/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  void finishView() {
    Constant.closeApp();
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isPass = true;
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize the resizer.
    FetchPixels(context);
    return WillPopScope(
      onWillPop: () async {
        finishView();
        return false; // Prevent default pop behavior.
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthLoading) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (_) => Center(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, spreadRadius: 5)],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)),
                              SizedBox(height: 15),
                              Text("Logging in...", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
                            ],
                          ),
                        ),
                      ),
                );
              } else if (state is AuthFailure) {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Login failed: ${state.error}"),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
              // else if (state is AuthSuccess) {
              //   Navigator.pop(context);
              //
              //   // Navigate to HomeScreen on successful login.
              //   // Constant.sendToNext(context, Routes.homeScreenRoute);
              //   Constant.sendToNextAndClear(context, Routes.homeScreenRoute);
              // }
              else if (state is AuthSuccess) {
                Navigator.pop(context);

                final customer = state.customer;
                final mobile = customer['mobile'];

                if (mobile == null || mobile.toString().isEmpty) {
                  // If mobile is missing, go to EditProfileScreen with flag
                  Constant.sendToNextAndClear(context, Routes.editProfileScreenRoute, arguments: {"isFirstTimeGoogleLogin": true});
                } else {
                  // Else go to HomeScreen
                  Constant.sendToNextAndClear(context, Routes.homeScreenRoute);
                }
              }
            },
            builder: (context, state) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white, Color(0xFFF5F9FF)])),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: FetchPixels.getDefaultHorSpace(context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: FetchPixels.getPixelHeight(80)),

                        // App Logo
                        Center(
                          child: Image.asset(
                            'assets/icon/logo_light.png', // Make sure this asset exists
                            height: FetchPixels.getPixelHeight(100),
                            width: FetchPixels.getPixelHeight(220),
                          ),
                        ),

                        SizedBox(height: FetchPixels.getPixelHeight(10)),

                        // Title and Subtitle
                        Text("Welcome to Kleanit", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: 0.5)),
                        SizedBox(height: FetchPixels.getPixelHeight(10)),
                        Text("Glad to meet you again!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black54)),
                        SizedBox(height: 10),

                        Image.asset(
                          'assets/icon/loginpng.png', // Make sure this asset exists
                          height: FetchPixels.getPixelHeight(276),
                          width: FetchPixels.getPixelHeight(276),
                        ),
                        Spacer(),
                        // Google Login Button with enhanced styling
                        // _buildLoginButton(
                        //   text: "Continue with Google",
                        //   icon: "google.svg",
                        //   onPressed: () async {
                        //     if (_isLoading) return;
                        //     setState(() {
                        //       _isLoading = true;
                        //     });
                        //     try {
                        //       UserCredential userCredential =
                        //           await _authService.signInWithGoogle();
                        //       final idToken =
                        //           await userCredential.user!.getIdToken();
                        //       log("idToken: $idToken");
                        //       context.read<AuthBloc>().add(
                        //             GoogleLoginRequested(
                        //               idToken: idToken.toString(),
                        //             ),
                        //           );
                        //     } on PlatformException catch (e) {
                        //       print(e.message);
                        //       print(e.code);
                        //       print(e.details);
                        //       ScaffoldMessenger.of(context).showSnackBar(
                        //         SnackBar(
                        //           content: Text("Google Sign-In failed: $e"),
                        //           backgroundColor: Colors.redAccent,
                        //           behavior: SnackBarBehavior.floating,
                        //           shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(10),
                        //           ),
                        //         ),
                        //       );
                        //     } catch (e) {
                        //       print(e);
                        //       ScaffoldMessenger.of(context).showSnackBar(
                        //         SnackBar(
                        //           content: Text("Google Sign-In failed: $e"),
                        //           backgroundColor: Colors.redAccent,
                        //           behavior: SnackBarBehavior.floating,
                        //           shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(10),
                        //           ),
                        //         ),
                        //       );
                        //     } finally {
                        //       setState(() {
                        //         _isLoading = false;
                        //       });
                        //     }
                        //   },
                        //   backgroundColor: Colors.white,
                        //   textColor: Colors.black87,
                        // ),
                        if (Platform.isAndroid)
                          _buildLoginButton(
                            text: "Continue with Google",
                            icon: "google.svg",
                            onPressed: () async {
                              if (_isLoading) return;
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                UserCredential userCredential = await _authService.signInWithGoogle();
                                final idToken = await userCredential.user!.getIdToken();
                                log("idToken: $idToken");
                                context.read<AuthBloc>().add(GoogleLoginRequested(idToken: idToken.toString()));
                              } on PlatformException catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Google Sign-In failed: ${e.message}"),
                                    backgroundColor: Colors.redAccent,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Google Sign-In failed: $e"),
                                    backgroundColor: Colors.redAccent,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                            backgroundColor: Colors.white,
                            textColor: Colors.black87,
                          ),

                        SizedBox(height: FetchPixels.getPixelHeight(20)),
                        // Phone OTP Login Button with enhanced styling
                        _buildLoginButton(
                          text: "Continue with Phone",
                          icon: "phone.svg",
                          onPressed: () {
                            Constant.sendToNext(context, Routes.otpLoginRoute);
                          },
                          backgroundColor: primaryColor,
                          textColor: Colors.white,
                        ),

                        SizedBox(height: FetchPixels.getPixelHeight(40)),

                        // Terms of Service text
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "By continuing, you agree to our Terms of Service and Privacy Policy",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.black45, height: 1.5),
                          ),
                        ),

                        SizedBox(height: FetchPixels.getPixelHeight(20)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton({required String text, required String icon, required VoidCallback onPressed, required Color backgroundColor, required Color textColor}) {
    return Container(
      width: double.infinity,
      height: FetchPixels.getPixelHeight(60),
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 0, offset: Offset(0, 5))]),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(15))),
          padding: EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/images/$icon', height: 24, width: 24),
            SizedBox(width: 12),
            Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
          ],
        ),
      ),
    );
  }
}
