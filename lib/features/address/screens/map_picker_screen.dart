// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class MapPickerScreen extends StatefulWidget {
//   const MapPickerScreen({Key? key}) : super(key: key);
//
//   @override
//   State<MapPickerScreen> createState() => _MapPickerScreenState();
// }
//
// class _MapPickerScreenState extends State<MapPickerScreen> {
//   LatLng? pickedLocation;
//   GoogleMapController? mapController;
//
//   static const LatLng _initialPosition = LatLng(25.2048, 55.2708); // Default Dubai
//
//   void _onTap(LatLng position) {
//     setState(() {
//       pickedLocation = position;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Pick Location'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: const CameraPosition(
//               target: _initialPosition,
//               zoom: 12,
//             ),
//             onTap: _onTap,
//             markers: pickedLocation != null
//                 ? {
//               Marker(
//                 markerId: MarkerId('picked'),
//                 position: pickedLocation!,
//               )
//             }
//                 : {},
//             onMapCreated: (controller) {
//               mapController = controller;
//             },
//           ),
//           if (pickedLocation != null)
//             Positioned(
//               bottom: 20,
//               left: 20,
//               right: 20,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context, pickedLocation);
//                 },
//                 child: const Text('Select This Location'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   minimumSize: const Size.fromHeight(50),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/color_data.dart';

class OsmPickerScreen extends StatefulWidget {
  const OsmPickerScreen({Key? key}) : super(key: key);

  @override
  State<OsmPickerScreen> createState() => _OsmPickerScreenState();
}

class _OsmPickerScreenState extends State<OsmPickerScreen> {
  LatLng? pickedLocation;
  late MapController _mapController;

  // late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationError("Location Services disabled. Enable GPS.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showLocationError("Location permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showLocationError("Location permission permanently denied.");
      return;
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      pickedLocation = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location ', style: const TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          pickedLocation == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: pickedLocation,
                      zoom: 15,
                      onMapReady: () {
                        if (pickedLocation != null) {
                          _mapController.move(pickedLocation!, 15); // ✅ Now safe to move
                        }
                      },
                      onTap: (tapPosition, latLng) {
                        setState(() {
                          pickedLocation = latLng;
                        });
                      },
                    ),
                    children: [
                      // TileLayer(
                      //   urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      //   subdomains: ['a', 'b', 'c'],
                      // ),
                      TileLayer(
                        urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'com.spydo.kleanit', // optional but good to add your app id
                      ),

                      MarkerLayer(
                        markers:
                            pickedLocation != null
                                ? [Marker(point: pickedLocation!, width: 80, height: 80, child: const Icon(Icons.location_pin, size: 50, color: Colors.red))]
                                : [],
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, pickedLocation);
                      },
                      child: const Text('Select This Location', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size.fromHeight(50)),
                    ),
                  ),
                ],
              ),
    );
  }

  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }
}
