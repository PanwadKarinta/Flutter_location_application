import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  LatLng userLocation = LatLng(0, 0);
  double accuracyRadius = 0; // 🔵 เก็บค่า accuracy
  MapController mapController = MapController();

  bool isSatellite = false; // 🔵 ใช้สลับแผนที่

  // 🔹 ดึงตำแหน่งผู้ใช้
  Future<void> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
      accuracyRadius = position.accuracy; // 🔵 เอาค่า accuracy มาเก็บ
    });

    // 🔹 เลื่อนกล้องไปยังตำแหน่งผู้ใช้
    mapController.move(userLocation, 16);
  }

  // 🔹 เปลี่ยนรูปแบบแผนที่
  void toggleMapLayer() {
    setState(() {
      isSatellite = !isSatellite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter Location Application')),
        body: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: const LatLng(17.80316, 102.74811),
            initialZoom: 14.0,
          ),
          children: [
            // 🔵 เปลี่ยน Layer ตามปุ่ม
            TileLayer(
              urlTemplate: isSatellite
                  ? "https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png"
                  : "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
            ),

            // 🔵 วงกลม accuracy
            if (accuracyRadius > 0)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: userLocation,
                    radius: accuracyRadius, // ใช้ accuracy เป็นรัศมี
                    useRadiusInMeter: true,
                    color: Colors.blue.withOpacity(0.3),
                    borderColor: Colors.blue,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),

            // 🔵 Marker ผู้ใช้
            if (userLocation.latitude != 0 &&
                userLocation.longitude != 0)
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40,
                    height: 40,
                    point: userLocation,
                    child: const Icon(
                      Icons.person_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
          ],
        ),

        // 🔵 ปุ่ม 2 ปุ่ม
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "location",
              onPressed: getUserLocation,
              child: const Icon(Icons.my_location),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: "map",
              onPressed: toggleMapLayer,
              child: const Icon(Icons.layers),
            ),
          ],
        ),
      ),
    );
  }
}
