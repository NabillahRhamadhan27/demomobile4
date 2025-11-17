import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import '../models/spice_model.dart';
import '../services/spice_api_http.dart';
import '../services/spice_api_dio.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';
import 'auth_controller.dart';

class SpiceController extends GetxController {
  var spices = <Spice>[].obs;
  var isLoading = false.obs;
  var useDio = false.obs;
  var responseTime = 0.obs;

  var prefReadTime = 0.obs;
  var prefWriteTime = 0.obs;

  var recommendationText = ''.obs;

  final authC = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    _initLocal();
  }

  Future<void> _initLocal() async {
    await HiveService.init();
    await _loadPreference();
    await loadSpices();
  }

  Future<void> _loadPreference() async {
    final sw = Stopwatch()..start();
    final prefs = await SharedPreferences.getInstance();

    useDio.value = prefs.getBool('useDio') ?? false;

    sw.stop();
    prefReadTime.value = sw.elapsedMilliseconds;
  }

  Future<void> _savePreference() async {
    final sw = Stopwatch()..start();
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('useDio', useDio.value);

    sw.stop();
    prefWriteTime.value = sw.elapsedMilliseconds;
  }

  void toggleLibrary() async {
    useDio.value = !useDio.value;
    await _savePreference();
    await loadSpices(forceRemote: true);
  }

  Future<bool> _isOffline() async {
    try {
      final res = await InternetAddress.lookup("example.com");
      return res.isEmpty;
    } catch (_) {
      return true;
    }
  }

  Future<void> loadSpices({bool forceRemote = false}) async {
    isLoading.value = true;
    final sw = Stopwatch()..start();

    try {
      final offline = await _isOffline();

      if (!forceRemote && offline) {
        spices.value = HiveService.readSpices() ?? [];
        return;
      }

      if (offline) {
        spices.value = HiveService.readSpices() ?? [];
      } else {
        final fetched = useDio.value
            ? await SpiceApiDio.fetchSpices()
            : await SpiceApiHttp.fetchSpices();

        spices.value = fetched;
        await HiveService.saveSpices(spices);
      }
    } catch (_) {
      spices.value = HiveService.readSpices() ?? [];
    } finally {
      sw.stop();
      responseTime.value = sw.elapsedMilliseconds;
      isLoading.value = false;
    }
  }

  /// Universal upload
  Future<String> uploadImage(XFile file) async {
    final fileName = "rempah_${DateTime.now().millisecondsSinceEpoch}.png";
    return await SupabaseService.uploadImageUniversal(file, fileName);
  }

  Future<void> addSpiceToCloud(Spice spice) async {
    final user = authC.user.value;
    if (user == null) throw Exception('User not logged in');

    await SupabaseService.insertSpice(user.id, spice);
  }

  Future<void> addLocalSpice(Spice spice, {bool tryUpload = true}) async {
    spices.insert(0, spice);
    await HiveService.saveSpices(spices);

    if (tryUpload) {
      try {
        await addSpiceToCloud(spice);
      } catch (_) {}
    }
  }

  Future<void> deleteSpice(String spiceId) async {
    spices.removeWhere((s) => s.id == spiceId);
    await HiveService.saveSpices(spices);

    try {
      await SupabaseService.deleteSpice(spiceId);
    } catch (_) {}

    Get.snackbar("Berhasil", "Data rempah berhasil dihapus");
  }

  Future<String> fetchRecommendation(String name) async {
    await Future.delayed(const Duration(seconds: 2));
    return "Gunakan $name untuk produk ekspor herbal";
  }
}
