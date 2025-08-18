// lib/presentation/screens/otp_login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kleanitapp/features/auth/bloc/auth/auth_bloc.dart';
import 'package:kleanitapp/features/auth/bloc/auth/auth_event.dart';
import 'package:kleanitapp/features/auth/bloc/auth/auth_state.dart';

import '../../../core/constants/Sypdo_Constant.dart';
import '../../../core/theme/sypd_color.dart';
import '../../../core/theme/resizer/sypdo_fetch_pixels.dart';
import '../../../core/theme/sypdo_widget_utils.dart';
import '../../../routes/app_routes..dart';

class AppOTPLoginScreen extends StatefulWidget {
  const AppOTPLoginScreen({Key? key}) : super(key: key);

  @override
  State<AppOTPLoginScreen> createState() => _AppOTPLoginScreenState();
}

// class _OTPLoginScreenState extends State<OTPLoginScreen> {
//   final TextEditingController phoneController = TextEditingController();
//   bool _isLoading = false;
//
//   // A simple validation for a 10-digit phone number.
//   bool isValidPhone(String phone) {
//     final RegExp phoneExp = RegExp(r'^\d{10}$');
//     return phoneExp.hasMatch(phone);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     FetchPixels(context);
//     return WillPopScope(
//       onWillPop: () async {
//         Constant.closeApp();
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: backGroundColor,
//         body: SafeArea(
//           child: BlocConsumer<AuthBloc, AuthState>(
//             listener: (context, state) {
//               if (state is AuthLoading) {
//                 showDialog(context: context, builder: (_) => Center(child: CircularProgressIndicator()));
//               } else if (state is AuthFailure) {
//                 Navigator.pop(context);
//
//                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${state.error}")));
//               } else if (state is OTPLoginSuccess) {
//                 Navigator.pop(context);
//
//                 // If OTP is sent successfully, navigate to OTPVerificationScreen with the phone number.
//                 Constant.sendToNext(context, Routes.otpVerificationRoute, arguments: phoneController.text.trim());
//               }
//             },
//             builder: (context, state) {
//               return Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: FetchPixels.getDefaultHorSpace(context),
//                 ),
//                 child: ListView(
//                   children: [
//                     getVerSpace(FetchPixels.getPixelHeight(70)),
//                     Align(
//                       alignment: Alignment.center,
//                       child: getCustomFont(
//                         "Login with Phone OTP",
//                         24,
//                         Colors.black,
//                         1,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                     getVerSpace(FetchPixels.getPixelHeight(30)),
//                     // Phone number field.
//                     getDefaultTextFiledWithLabel(
//                       context,
//                       "Phone Number",
//                       phoneController,
//                       Colors.grey,
//                       height: FetchPixels.getPixelHeight(60),
//                       isEnable: true,
//                       withprefix: true,
//                       image: "phone.svg",
//                       keyboardType: TextInputType.phone,
//                     ),
//                     getVerSpace(FetchPixels.getPixelHeight(30)),
//                     // Send OTP button.
//                     getButton(
//                       context,
//                       primaryColor,
//                       "Send OTP",
//                       Colors.white,
//                       () async {
//                         String phone = phoneController.text.trim();
//                         if (phone.isEmpty) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text("Please enter your phone number.")),
//                           );
//                           return;
//                         }
//                         if (!isValidPhone(phone)) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text("Please enter a valid 10-digit phone number.")),
//                           );
//                           return;
//                         }
//                         if (_isLoading) return;
//                         setState(() {
//                           _isLoading = true;
//                         });
//                         // Dispatch OTP login event.
//                         context.read<AuthBloc>().add(OTPLoginRequested(mobile: phone));
//                       },
//                       18,
//                       weight: FontWeight.w600,
//                       buttonHeight: FetchPixels.getPixelHeight(60),
//                       borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(15)),
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
class _AppOTPLoginScreenState extends State<AppOTPLoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool _isLoading = false;

  bool isValidPhone(String phone) {
    final RegExp phoneExp = RegExp(r'^\d{9}$');
    return phoneExp.hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    FetchPixels(context);
    return WillPopScope(
      onWillPop: () async {
        AppConstant.closeApp();
        return false;
      },
      child: Scaffold(
        backgroundColor: backGroundColor,
        body: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthLoading) {
                showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
              } else {
                Navigator.pop(context); // dismiss loader
                setState(() => _isLoading = false);
              }

              if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ ${state.error}")));
              }

              if (state is OTPLoginSuccess) {
                AppConstant.sendToNext(context, AppRoutes.otpVerificationRoute, arguments: phoneController.text.trim());
              }
            },
            builder: (context, state) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: FetchPixels.getDefaultHorSpace(context)),
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    Align(alignment: Alignment.topLeft, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context))),
                    getVerSpace(FetchPixels.getPixelHeight(70)),
                    Padding(
                      padding: const EdgeInsets.all(38.0),
                      child: Image.asset("assets/icon/logo_light.png", width: FetchPixels.getPixelWidth(100), height: FetchPixels.getPixelHeight(100)),
                    ),
                    Align(alignment: Alignment.center, child: getCustomFont("Enter Your Mobile Number", 18, Colors.black, 1, fontWeight: FontWeight.w800)),
                    getVerSpace(FetchPixels.getPixelHeight(40)),
                    // Row(
                    //   children: [
                    //     Container(
                    //       padding: EdgeInsets.symmetric(horizontal: 12),
                    //       height: FetchPixels.getPixelHeight(60),
                    //       decoration: BoxDecoration(
                    //         color: Colors.grey.shade200,
                    //         borderRadius: BorderRadius.circular(10),
                    //       ),
                    //       alignment: Alignment.center,
                    //       child: Text(
                    //         "+971",
                    //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    //       ),
                    //     ),
                    //     const SizedBox(width: 10),
                    //     getDefaultTextFiledWithLabel(
                    //       context,
                    //       "Phone Number",
                    //       phoneController,
                    //       Colors.grey,
                    //       height: FetchPixels.getPixelHeight(60),
                    //       isEnable: true,
                    //       withprefix: true,
                    //       image: "phone.svg",
                    //       keyboardType: TextInputType.phone,
                    //     ),
                    //   ],
                    // ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          height: FetchPixels.getPixelHeight(60),
                          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                          alignment: Alignment.center,
                          child: const Text("+971", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: getDefaultTextFiledWithLabel(
                            context,
                            "Phone Number",
                            phoneController,
                            Colors.grey,
                            height: FetchPixels.getPixelHeight(60),
                            isEnable: true,
                            withprefix: true,
                            image: "phone.svg",
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            // ✅ Only numbers
                            maxLength: 9, // ✅ Limit to 9 digits
                          ),
                        ),
                      ],
                    ),

                    getVerSpace(FetchPixels.getPixelHeight(30)),

                    Text(
                      "We will send you a one-time password\non this mobile number",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.normal,
                        color: Colors.black,
                        // fontFamily: fontFamily,
                        // height: txtHeight ?? 1.5,
                      ),
                      maxLines: 2,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      textScaleFactor: FetchPixels.getTextScale(),
                    ),

                    getVerSpace(FetchPixels.getPixelHeight(50)),
                    getButton(
                      context,
                      primaryColor,
                      "Send OTP",
                      Colors.white,
                      () async {
                        final phone = phoneController.text.trim();
                        if (phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter your phone number.")));
                          return;
                        }
                        if (!isValidPhone(phone)) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid 9-digit phone number.")));
                          return;
                        }
                        if (_isLoading) return;

                        setState(() => _isLoading = true);
                        context.read<AuthBloc>().add(OTPLoginRequested(mobile: phone));
                      },
                      18,
                      weight: FontWeight.w600,
                      buttonHeight: FetchPixels.getPixelHeight(60),
                      borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(15)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
