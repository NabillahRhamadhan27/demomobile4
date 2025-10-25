import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/views/spice_dashboard.dart';

void main() {
  runApp(const SpiceTrackApp());
}

class SpiceTrackApp extends StatelessWidget {
  const SpiceTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SpiceTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const SpiceDashboard(),
    );
  }
}
