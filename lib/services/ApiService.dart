// // lib/services/api_service.dart
// // import 'package:dio/dio.dart';
//
// import 'package:dio/dio.dart';
//
// class ApiService {
//   final Dio _dio;
//
//   ApiService() : _dio = Dio(BaseOptions(baseUrl: baseUrl));
//
//   // Example GET request
//   Future<Response> getRequest(String endpoint) async {
//     try {
//       final response = await _dio.get(endpoint);
//       return response;
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   // Example POST request
//   Future<Response> postRequest(String endpoint, dynamic data) async {
//     try {
//       final response = await _dio.post(endpoint, data: data);
//       return response;
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
