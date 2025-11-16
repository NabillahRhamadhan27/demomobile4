import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
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

  // Modul requirement
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

  // ======================= Shared Preferences ===========================
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

  // ======================= Connectivity Check ===========================
  Future<bool> _isOffline() async {
    try {
      final res = await InternetAddress.lookup("example.com");
      return res.isEmpty;
    } catch (_) {
      return true;
    }
  }

  // ======================= Loading Spices ================================
  Future<void> loadSpices({bool forceRemote = false}) async {
    isLoading.value = true;
    final sw = Stopwatch()..start();

    try {
      final offline = await _isOffline();

      if (!forceRemote && offline) {
        final cached = HiveService.readSpices();
        if (cached != null) {
          spices.value = cached;
          return;
        }
      }

      if (offline) {
        spices.value = HiveService.readSpices() ?? [];
      } else {
        // Fetch from remote API
        final fetched = useDio.value
            ? await SpiceApiDio.fetchSpices()
            : await SpiceApiHttp.fetchSpices();

        spices.value = fetched;
        await HiveService.saveSpices(spices);
      }
    } catch (e) {
      spices.value = HiveService.readSpices() ?? [];
    } finally {
      sw.stop();
      responseTime.value = sw.elapsedMilliseconds;
      isLoading.value = false;
    }
  }

  // ======================= UPLOAD IMAGE UNIVERSAL =======================
  /// Android → upload File
  /// Web → uploadBinary (XFile)
  Future<String> uploadImage(XFile file) async {
    final fileName = "rempah_${DateTime.now().millisecondsSinceEpoch}.png";
    return await SupabaseService.uploadImageUniversal(file, fileName);
  }

  // ======================= ADD SPICE ====================================
  Future<void> addSpiceToCloud(Spice spice) async {
    final user = authC.user.value;
    if (user == null) throw Exception('User not logged in');

    // Kirim JSON (Map<String, dynamic>) bukan objek Spice
    await SupabaseService.insertSpice(user.id, spice.toJson());
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

  // ======================= DELETE SPICE =================================
  Future<void> deleteSpice(String spiceId) async {
    spices.removeWhere((s) => s.id == spiceId);
    await HiveService.saveSpices(spices);

    try {
      await SupabaseService.deleteSpice(spiceId);
    } catch (_) {}

    Get.snackbar("Berhasil", "Data rempah berhasil dihapus");
  }

  // ======================= RECOMMENDATION ================================
  Future<void> loadSpicesWithRecommendation() async {
    recommendationText.value = "Memuat data rempah...";

    final offline = await _isOffline();
    final data = offline
        ? HiveService.readSpices() ?? []
        : useDio.value
        ? await SpiceApiDio.fetchSpices()
        : await SpiceApiHttp.fetchSpices();

    if (data.isEmpty) {
      recommendationText.value = "Tidak ada data rempah.";
      return;
    }

    final first = data.first.name;
    final rec = await fetchRecommendation(first);

    recommendationText.value = "Rekomendasi: $rec";
  }

  void loadSpicesWithCallback() {
    recommendationText.value = "Memuat data rempah (callback)...";

    (useDio.value ? SpiceApiDio.fetchSpices() : SpiceApiHttp.fetchSpices())
        .then((data) {
          if (data.isEmpty) {
            recommendationText.value = "Tidak ada data rempah.";
            return;
          }

          final first = data.first.name;
          fetchRecommendation(first)
              .then((r) {
                recommendationText.value = "Rekomendasi: $r";
              })
              .catchError((_) {
                recommendationText.value = "Error rekomendasi";
              });
        })
        .catchError((_) {
          recommendationText.value = "Error memuat data";
        });
  }

  Future<String> fetchRecommendation(String name) async {
    await Future.delayed(const Duration(seconds: 2));
    return "Gunakan $name untuk produk ekspor herbal";
  }

  Future<String> uploadImageXFile(XFile file) async {
    try {
      final fileName = "rempah_${DateTime.now().millisecondsSinceEpoch}.png";
      return await SupabaseService.uploadXFile(file, fileName);
    } catch (e) {
      debugPrint("Upload XFile error: $e");
      return "";
    }
  }
}
