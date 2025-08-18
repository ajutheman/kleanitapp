import 'dart:async';

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
import '../bloc/token/token_bloc.dart';
import '../bloc/token/token_event.dart';

class AppOTPVerificationScreen extends StatefulWidget {
  final String mobile;

  const AppOTPVerificationScreen({Key? key, required this.mobile}) : super(key: key);

  @override
  State<AppOTPVerificationScreen> createState() => _AppOTPVerificationScreenState();
}


class _AppOTPVerificationScreenState extends State<AppOTPVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  bool _isLoading = false;
  bool _showError = false;
  String _errorMessage = '';
  int _resendCooldown = 0;
  Timer? _resendTimer;

  void _startResendCooldown() {
    setState(() => _resendCooldown = 60);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
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
                Navigator.pop(context);
                setState(() => _isLoading = false);
              }

              if (state is AuthFailure) {
                setState(() {
                  _showError = true;
                  // _errorMessage = state.error?.replaceAll("Exception:", "").trim() ?? "Verification failed.";
                  _errorMessage = "Verification failed.";
                  // state.error ?? "Something went wrong.";
                });
              }

              if (state is OTPVerificationSuccess) {
                context.read<TokenBloc>().add(UpdateToken());
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                AppConstant.sendToNextAndClear(context, AppRoutes.homeScreenRoute);
              }
            },
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: FetchPixels.getDefaultHorSpace(context)),
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    Align(alignment: Alignment.topLeft, child: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.pop(context))),
                    getVerSpace(FetchPixels.getPixelHeight(50)),
                    getVerSpace(FetchPixels.getPixelHeight(70)),
                    Padding(
                      padding: const EdgeInsets.all(38.0),
                      child: Image.asset("assets/icon/logo_light.png", width: FetchPixels.getPixelWidth(100), height: FetchPixels.getPixelHeight(100)),
                    ),
                    Align(alignment: Alignment.center, child: getCustomFont("OTP Verification", 24, Colors.black, 1, fontWeight: FontWeight.w800)),
                    getVerSpace(FetchPixels.getPixelHeight(20)),
                    Align(alignment: Alignment.center, child: getCustomFont("Enter OTP Code sent to +971 ${widget.mobile}", 16, Colors.black, 1, fontWeight: FontWeight.w400)),
                    getVerSpace(FetchPixels.getPixelHeight(30)),
                    // getDefaultTextFiledWithLabel(
                    //   context,
                    //   "OTP",
                    //   otpController,
                    //   Colors.grey,
                    //   height: FetchPixels.getPixelHeight(60),
                    //   isEnable: true,
                    //   withprefix: true,
                    //   image: "otp.svg",
                    // ),
                    getDefaultTextFiledWithLabel(
                      context,
                      "Enter OTP",
                      otpController,
                      Colors.grey,
                      height: FetchPixels.getPixelHeight(60),
                      isEnable: true,
                      withprefix: true,
                      image: "otp.svg",
                      keyboardType: TextInputType.number,
                      // Show number pad
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      // Only digits
                      maxLength: 4, // Limit to 4 digits
                    ),

                    getVerSpace(FetchPixels.getPixelHeight(10)),

                    // ✅ Error message box
                    if (_showError)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade300)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 14))),
                          ],
                        ),
                      ),
                    getVerSpace(FetchPixels.getPixelHeight(20)),

                    // 🔁 Resend OTP
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Row(
                        children: [
                          Align(alignment: Alignment.center, child: getCustomFont("Didn’t Receive OTP ?", 16, Colors.black, 1, fontWeight: FontWeight.w400)),
                          TextButton(
                            onPressed:
                                _resendCooldown == 0
                                    ? () {
                                      context.read<AuthBloc>().add(OTPLoginRequested(mobile: widget.mobile));
                                      _startResendCooldown();
                                      setState(() {
                                        _showError = false;
                                        _errorMessage = '';
                                      });
                                    }
                                    : null,
                            child: Text(
                              _resendCooldown > 0 ? 'Resend OTP in $_resendCooldown sec' : 'Resend OTP',
                              style: TextStyle(color: _resendCooldown == 0 ? primaryColor : Colors.grey, fontWeight: FontWeight.w500, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    getVerSpace(FetchPixels.getPixelHeight(15)),
                    getButton(
                      context,
                      primaryColor,
                      "Verify OTP",
                      Colors.white,
                      () {
                        final otp = otpController.text.trim();
                        if (otp.isEmpty) {
                          setState(() {
                            _showError = true;
                            _errorMessage = "Please enter the OTP.";
                          });
                          return;
                        }

                        setState(() {
                          _showError = false;
                          _isLoading = true;
                        });

                        context.read<AuthBloc>().add(OTPVerificationRequested(mobile: widget.mobile, otp: otp));
                      },
                      18,
                      weight: FontWeight.w600,
                      buttonHeight: FetchPixels.getPixelHeight(60),
                      borderRadius: BorderRadius.circular(FetchPixels.getPixelHeight(15)),
                    ),

                    getVerSpace(FetchPixels.getPixelHeight(20)),
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
