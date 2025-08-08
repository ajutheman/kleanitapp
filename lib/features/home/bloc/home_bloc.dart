import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../customer_model.dart';
import '../home_repository.dart';
import '../repo/exceptions.dart';
import '../service_response_model.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;

  HomeBloc({required this.repository}) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
      LoadHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      // Retrieve token and customer data from SharedPreferences.
      final prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("user_access_token") ?? "";
      if (token.isEmpty) {
        emit(HomeTokenExpired("Session expired."));
        return;
      }
      final customerDataStr = prefs.getString("customer_data");
      Customer? customer;
      if (customerDataStr != null) {
        final data = jsonDecode(customerDataStr);
        customer = Customer.fromJson(data);
      }

      // Get real-time device location.
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location services are disabled.");
      }
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
          desiredAccuracy: LocationAccuracy.high);
      double latitude = position.latitude;
      double longitude = position.longitude;
      print("latitude:$latitude");
      print("longitude:$longitude");
      print("token:$token");
      // Call the repository to update the location with real-time coordinates.
      ServiceAvailabilityResponse response =
          await repository.setLocation(latitude, longitude, token);

      if (response.serviceAvailable == "yes") {
        emit(HomeServiceAvailable(response.message, customer: customer));
      } else {
        emit(HomeServiceNotAvailable(response.message, customer: customer));
      }
    } on UnauthorizedException catch (e) {
      // ✅ Token expired or invalid
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("user_access_token");
      await prefs.remove("customer_data");
      emit(HomeTokenExpired(e.message));
    } on BadRequestException catch (e) {
      emit(HomeError(e.message));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
