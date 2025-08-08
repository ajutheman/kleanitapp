// // lib/logic/blocs/auth/auth_bloc.dart
// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:bloc/bloc.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:kleanit/features/auth/respository/auth_repository.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'auth_event.dart';
// import 'auth_state.dart';
//
// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   final AuthRepository authRepository;
//
//   AuthBloc({required this.authRepository}) : super(AuthInitial()) {
//     on<GoogleLoginRequested>(_onGoogleLoginRequested);
//     on<OTPLoginRequested>(_onOTPLoginRequested);
//     on<OTPVerificationRequested>(_onOTPVerificationRequested);
//   }
//
//   Future<void> _onGoogleLoginRequested(
//     GoogleLoginRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(AuthLoading());
//     try {
//       final authResponse = await authRepository.loginWithGoogle(event.idToken);
//       final token = authResponse.token;
//       final customer = authResponse.customer;
//
//       // Save token and customer data in SharedPreferences.
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString("user_access_token", token);
//       await prefs.setString("customer_data", jsonEncode(customer.toJson()));
//
//       log("Stored customer_data: ${jsonEncode(customer.toJson())}");
//       log("✅ Google Login Success. Token: $token");
//       log("📦 Customer Data: ${jsonEncode(customer.toJson())}");
//       await _updateLocation();
//       // Retrieve the real device location.
//       // try {
//       //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       //   if (!serviceEnabled) {
//       //     throw Exception("Location services are disabled.");
//       //   }
//       //   LocationPermission permission = await Geolocator.checkPermission();
//       //   if (permission == LocationPermission.denied) {
//       //     permission = await Geolocator.requestPermission();
//       //     if (permission == LocationPermission.denied) {
//       //       throw Exception("Location permissions are denied.");
//       //     }
//       //   }
//       //   if (permission == LocationPermission.deniedForever) {
//       //     throw Exception("Location permissions are permanently denied.");
//       //   }
//       //   Position position = await Geolocator.getCurrentPosition(
//       //     desiredAccuracy: LocationAccuracy.high,
//       //   );
//       //   final locationResponse = await authRepository.setLocation(
//       //     position.latitude,
//       //     position.longitude,
//       //   );
//       //   log("Location updated: ${locationResponse.message}, Service available: ${locationResponse.serviceAvailable}");
//       // } catch (locationError) {
//       //   log("Location update failed: $locationError");
//       // }
//
//       emit(AuthSuccess(token: token, customer: customer.toJson()));
//     } catch (e) {
//       emit(AuthFailure(error: e.toString()));
//     }
//   }
//
//   Future<void> _onOTPLoginRequested(
//     OTPLoginRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(AuthLoading());
//     try {
//       final otpResponse = await authRepository.loginWithOtp(event.mobile);
//       log("OTP Login Response: ${otpResponse.message}");
//       emit(OTPLoginSuccess(
//           message: otpResponse.message, mobile: otpResponse.mobile));
//     } catch (e) {
//       emit(AuthFailure(error: e.toString()));
//     }
//   }
//
//   Future<void> _onOTPVerificationRequested(
//     OTPVerificationRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(AuthLoading());
//     try {
//       final verifyResponse =
//           await authRepository.verifyOtp(event.mobile, event.otp);
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString("user_access_token", verifyResponse.token);
//
//       // Retrieve the real device location after OTP verification.
//       try {
//         bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//         if (!serviceEnabled) {
//           throw Exception("Location services are disabled.");
//         }
//         LocationPermission permission = await Geolocator.checkPermission();
//         if (permission == LocationPermission.denied) {
//           permission = await Geolocator.requestPermission();
//           if (permission == LocationPermission.denied) {
//             throw Exception("Location permissions are denied.");
//           }
//         }
//         if (permission == LocationPermission.deniedForever) {
//           throw Exception("Location permissions are permanently denied.");
//         }
//         Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high,
//         );
//         final locationResponse = await authRepository.setLocation(
//           position.latitude,
//           position.longitude,
//         );
//         log("Location updated: ${locationResponse.message}, Service available: ${locationResponse.serviceAvailable}");
//       } catch (locationError) {
//         log("Location update failed: $locationError");
//       }
//
//       emit(OTPVerificationSuccess(
//         message: verifyResponse.message,
//         token: verifyResponse.token,
//         customerId: verifyResponse.customerId,
//       ));
//     } catch (e) {
//       emit(AuthFailure(error: e.toString()));
//     }
//   }
//   /// 🔁 Helper: Fetch and send device location
//   Future<void> _updateLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) throw Exception("Location services are disabled.");
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           throw Exception("Location permissions are denied.");
//         }
//       }
//       if (permission == LocationPermission.deniedForever) {
//         throw Exception("Location permissions are permanently denied.");
//       }
//
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       final locationResponse = await authRepository.setLocation(
//         position.latitude,
//         position.longitude,
//       );
//       log("📍 Location Updated: ${locationResponse.message}, Service Available: ${locationResponse.serviceAvailable}");
//     } catch (locationError) {
//       log("⚠️ Location update skipped: $locationError");
//     }
//   }
//
//   /// 🔁 Helper: Format error for display
//   String _formatError(Object error) {
//     if (error.toString().contains("Exception:")) {
//       return error.toString().replaceAll("Exception:", "").trim();
//     }
//     return "An unexpected error occurred.";
//   }
//
// }
//
//

import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import 'package:kleanit/core/constants/pref_resources.dart';
import 'package:kleanit/features/auth/respository/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<OTPLoginRequested>(_onOTPLoginRequested);
    on<OTPVerificationRequested>(_onOTPVerificationRequested);
  }

  Future<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final authResponse = await authRepository.loginWithGoogle(event.idToken);
      final token = authResponse.token;
      final customer = authResponse.customer;
      log("🧩 Raw customer data: ${jsonEncode(authResponse.customer.toJson())}");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(PrefResources.USER_ACCESS_TOCKEN, token);
      await prefs.setString("customer_data", jsonEncode(customer.toJson()));

      log("✅ Google Login Success. Token: $token");
      log("📦 Customer Data: ${jsonEncode(customer.toJson())}");

      await _updateLocation();

      emit(AuthSuccess(token: token, customer: customer.toJson()));
    } catch (e) {
      final errorMessage = _formatError(e);
      log("❌ Google Login Failed: $errorMessage");
      emit(AuthFailure(error: errorMessage));
    }
  }

  Future<void> _onOTPLoginRequested(
    OTPLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final otpResponse = await authRepository.loginWithOtp(event.mobile);
      log("📨 OTP Sent: ${otpResponse.message} to ${otpResponse.mobile}");
      emit(OTPLoginSuccess(
          message: otpResponse.message, mobile: otpResponse.mobile));
    } catch (e) {
      final errorMessage = _formatError(e);
      log("❌ OTP Login Failed: $errorMessage");
      emit(AuthFailure(error: errorMessage));
    }
  }

  Future<void> _onOTPVerificationRequested(
    OTPVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final verifyResponse =
          await authRepository.verifyOtp(event.mobile, event.otp);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          PrefResources.USER_ACCESS_TOCKEN, verifyResponse.token);

      log("✅ OTP Verified. Token: ${verifyResponse.token}, Customer ID: ${verifyResponse.customerId}");

      await _updateLocation();

      emit(OTPVerificationSuccess(
        message: verifyResponse.message,
        token: verifyResponse.token,
        customerId: verifyResponse.customerId,
      ));
    }
    // catch (e)
    /*{
      final errorMessage = _formatError(e);
      log("❌ OTP Verification Failed: $errorMessage");
      emit(AuthFailure(error: errorMessage));
    }*/
    on DioError catch (dioError) {
      final message =
          dioError.response?.data['message'] ?? 'OTP verification failed';
      // emit(AuthFailure(error: message));
      emit(AuthFailure(error: "OTP verification failed"));
    } catch (e) {
      emit(AuthFailure(error: "OTP verification failed"));
      // emit(AuthFailure(error: "OTP verification failed: $e"));
    }
  }

  /// 🔁 Helper: Fetch and send device location
  Future<void> _updateLocation() async {
    try {
      // print ("Geolocator${serviceEnabled}");
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("Location services are disabled.");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Location permissions are denied.");
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permissions are permanently denied.");
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final locationResponse = await authRepository.setLocation(
        position.latitude,
        position.longitude,
      );
      log("📍 Location Updated: ${locationResponse.message}, Service Available: ${locationResponse.serviceAvailable}");
    } catch (locationError) {
      log("⚠️ Location update skipped: $locationError");
    }
  }

  /// 🔁 Helper: Format error for display
  String _formatError(Object error) {
    if (error.toString().contains("Exception:")) {
      return error.toString().replaceAll("Exception:", "").trim();
    }
    return "An unexpected error occurred.";
  }
}
