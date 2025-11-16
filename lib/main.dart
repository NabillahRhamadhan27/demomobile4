import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/controllers/auth_controller.dart';
import 'app/controllers/spice_controller.dart';
import 'app/views/login_page.dart';
import 'app/views/spice_dashboard.dart';
import 'app/views/spice_add_page.dart'; // <-- TAMBAHKAN INI

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lkitxlxzubmwdviyyzgc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxraXR4bHh6dWJtd2R2aXl5emdjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMyMDMxNTIsImV4cCI6MjA3ODc3OTE1Mn0.bXUIiZyhjrdF3qTU2bd2VzsfFSdel-j8aKMzvH08aUg',
  );

  Get.put(AuthController());
  Get.put(SpiceController());

  runApp(const SpiceTrackApp());
}

class SpiceTrackApp extends StatelessWidget {
  const SpiceTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();

    return GetMaterialApp(
      title: 'SpiceTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: Obx(() {
        if (authC.isInitialized.value == false) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return authC.isLoggedIn ? SpiceDashboard() : const LoginPage();
      }),
      getPages: [
        GetPage(name: '/', page: () => const SpiceDashboard()),
        GetPage(name: '/add', page: () => const SpiceAddPage()), // sudah valid
        GetPage(name: '/login', page: () => const LoginPage()),
      ],
    );
  }
}
