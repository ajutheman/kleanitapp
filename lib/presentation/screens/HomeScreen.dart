// // lib/presentation/screens/home_screen.dart
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:kleanit/core/constants/Constant.dart';
// import 'package:kleanit/core/theme/resizer/fetch_pixels.dart';
// import 'package:kleanit/core/theme/widget_utils.dart';
// import 'package:kleanit/routes/app_routes..dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   // Retrieves the user's location as a formatted string.
//   Future<String> _getLocation() async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerData = prefs.getString("customer_data");
//     if (customerData != null) {
//       final data = jsonDecode(customerData);
//       if (data["is_location_selected"] == "yes" &&
//           data["latitude"] != null &&
//           data["longitude"] != null &&
//           data["latitude"].toString().isNotEmpty &&
//           data["longitude"].toString().isNotEmpty) {
//         // Format the location as desired; here we display latitude and longitude.
//         return "Lat: ${data["latitude"]}, Lng: ${data["longitude"]}";
//       }
//     }
//     return "Dubai, UAE"; // fallback location
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     FetchPixels(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: FutureBuilder<String>(
//           future: _getLocation(),
//           builder: (context, snapshot) {
//             String locationText = "Loading...";
//             if (snapshot.connectionState == ConnectionState.done) {
//               locationText = snapshot.data ?? "Dubai, UAE";
//             }
//             return Row(
//               children: [
//                 // Wallet / Coin info.
//                 getSvgImage('coin.svg', width: 20, height: 20),
//                 const SizedBox(width: 7),
//                 const Text('245.50',
//                     style:
//                         TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//                 const Spacer(),
//                 // Display user location.
//                 Row(
//                   children: [
//                     getSvgImage("location.svg"),
//                     getHorSpace(FetchPixels.getPixelWidth(4)),
//                     getCustomFont(locationText, 14, Colors.black, 1,
//                         fontWeight: FontWeight.w400),
//                   ],
//                 ),
//                 const Spacer(),
//                 // Notification icon.
//                 GestureDetector(
//                   onTap: () {
//                     Constant.sendToNext(context, Routes.homeScreenRoute);
//                   },
//                   child: getSvgImage("notification.svg",
//                       height: FetchPixels.getPixelHeight(24),
//                       width: FetchPixels.getPixelHeight(24)),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//       body: Container(
//         padding: EdgeInsets.all(FetchPixels.getPixelWidth(16)),
//         child: ListView(
//           children: [
//             // A card to display user location.
//             FutureBuilder<String>(
//               future: _getLocation(),
//               builder: (context, snapshot) {
//                 String locationText = "Loading...";
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   locationText = snapshot.data ?? "Dubai, UAE";
//                 }
//                 return Card(
//                   elevation: 4,
//                   margin:
//                       EdgeInsets.only(bottom: FetchPixels.getPixelHeight(20)),
//                   child: ListTile(
//                     leading: getSvgImage("location.svg"),
//                     title: getCustomFont("Your Location", 16, Colors.black, 1,
//                         fontWeight: FontWeight.bold),
//                     subtitle: getCustomFont(locationText, 14, Colors.grey, 1),
//                   ),
//                 );
//               },
//             ),
//             // You can add additional sections here.
//             // For example, a section for popular services.
//             Card(
//               elevation: 4,
//               margin: EdgeInsets.only(bottom: FetchPixels.getPixelHeight(20)),
//               child: Padding(
//                 padding: EdgeInsets.all(FetchPixels.getPixelHeight(16)),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     getCustomFont("Popular Services", 18, Colors.black, 1,
//                         fontWeight: FontWeight.bold),
//                     // Add your popular services widget here (e.g., a horizontal list).
//                     const SizedBox(height: 10),
//                     Center(
//                         child: getCustomFont(
//                             "Service cards here", 16, Colors.grey, 1))
//                   ],
//                 ),
//               ),
//             ),
//             // Add other sections like "Refer & Earn", "Categories", etc.
//             Card(
//               elevation: 4,
//               margin: EdgeInsets.only(bottom: FetchPixels.getPixelHeight(20)),
//               child: Padding(
//                 padding: EdgeInsets.all(FetchPixels.getPixelHeight(16)),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     getCustomFont("Refer & Earn", 18, Colors.black, 1,
//                         fontWeight: FontWeight.bold),
//                     const SizedBox(height: 10),
//                     Center(
//                         child: getCustomFont(
//                             "Refer & Earn content", 16, Colors.grey, 1)),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 0, // Update currentIndex as needed.
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.book), label: "Bookings"),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.favorite), label: "Wishlists"),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//         ],
//         onTap: (index) {
//           // Handle bottom navigation tap.
//           // You may use Constant.sendToNext(context, route) for navigation.
//         },
//       ),
//     );
//   }
// }
