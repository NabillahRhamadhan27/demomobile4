import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/controllers/location_controller.dart';
import 'app/controllers/spice_controller.dart';
import 'app/controllers/auth_controller.dart';

import 'app/views/spice_dashboard.dart';
import 'app/views/map_page.dart';
import 'app/views/spice_add_page.dart';
import 'app/views/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ========== WAJIB: INISIALISASI SUPABASE ==========
  await Supabase.initialize(
    url: 'https://lkitxlxzubmwdviyyzgc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxraXR4bHh6dWJtd2R2aXl5emdjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMyMDMxNTIsImV4cCI6MjA3ODc3OTE1Mn0.bXUIiZyhjrdF3qTU2bd2VzsfFSdel-j8aKMzvH08aUg',
  );

  // ========== GETX BINDINGS ==========
  Get.put(AuthController(), permanent: true);
  Get.put(SpiceController(), permanent: true);
  Get.put(LocationController(), permanent: true);

  runApp(const SpiceTrackApp());
}

class SpiceTrackApp extends StatelessWidget {
  const SpiceTrackApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SpiceTrack',
      debugShowCheckedModeBanner: false,
      initialRoute: '/dashboard',

      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/dashboard', page: () => const SpiceDashboard()),
        GetPage(name: '/add', page: () => const SpiceAddPage()),
        GetPage(name: '/map', page: () => MapPage()),
      ],
    );
  }
}
