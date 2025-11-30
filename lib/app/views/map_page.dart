import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Alias untuk menghindari konflik nama Marker
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';

import '../controllers/location_controller.dart';

class MapPage extends StatefulWidget {
  MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final c = Get.find<LocationController>();
  final fm.MapController mapCtrl = fm.MapController();

  @override
  void initState() {
    super.initState();

    // Ambil GPS pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.getGPSLocation();
    });

    // Update kamera setiap koordinat berubah
    everAll([c.latitude, c.longitude], (_) {
      final lat = c.latitude.value;
      final lng = c.longitude.value;

      if (lat == 0.0 && lng == 0.0) return;

      try {
        mapCtrl.move(LatLng(lat, lng), 16);
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OpenStreetMap (flutter_map v8)")),
      body: Column(
        children: [
          // ===== BUTTONS =====
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: c.getGPSLocation,
                  child: const Text("GPS Location"),
                ),
                ElevatedButton(
                  onPressed: c.getNetworkLocation,
                  child: const Text("Network Location"),
                ),
                ElevatedButton(
                  onPressed: c.startLiveLocation,
                  child: const Text("Live Update"),
                ),
              ],
            ),
          ),

          // ===== INFO =====
          Obx(() {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: Text(
                "Lat: ${c.latitude.value} | Long: ${c.longitude.value} | Acc: ${c.accuracy.value} m",
                style: const TextStyle(fontSize: 14),
              ),
            );
          }),

          // ===== MAP VIEW =====
          Expanded(
            child: Obx(() {
              final lat = c.latitude.value;
              final lng = c.longitude.value;

              // Default center agar tidak (0,0)
              final center = (lat == 0.0 && lng == 0.0)
                  ? LatLng(-7.9739, 112.6336) // Malang default
                  : LatLng(lat, lng);

              return fm.FlutterMap(
                mapController: mapCtrl,
                options: fm.MapOptions(initialCenter: center, initialZoom: 16),
                children: [
                  // ===== TILE LAYER OPENSTREETMAP =====
                  fm.TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'com.example.demomodul3',
                  ),

                  // ===== MARKER =====
                  fm.MarkerLayer(
                    markers: [
                      fm.Marker(
                        point: center,
                        width: 60,
                        height: 60,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
