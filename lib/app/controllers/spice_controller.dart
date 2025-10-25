import 'package:get/get.dart';
import '../models/spice_model.dart';
import '../services/spice_api_http.dart';
import '../services/spice_api_dio.dart';

class SpiceController extends GetxController {
  var spices = <Spice>[].obs;
  var isLoading = false.obs;
  var useDio = false.obs;
  var responseTime = 0.obs;
  var recommendationText = ''.obs;

  // 🔹 untuk animasi zoom
  var selectedIndex = (-1).obs;

  // =========================
  // LOAD DATA UTAMA
  // =========================
  Future<void> loadSpices() async {
    isLoading.value = true;
    final stopwatch = Stopwatch()..start();
    try {
      print("Memuat data rempah (${useDio.value ? 'Dio' : 'HTTP'})...");
      if (useDio.value) {
        spices.value = await SpiceApiDio.fetchSpices();
      } else {
        spices.value = await SpiceApiHttp.fetchSpices();
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      stopwatch.stop();
      responseTime.value = stopwatch.elapsedMilliseconds;
      isLoading.value = false;
      print("Waktu respon: ${responseTime.value} ms");
    }
  }

  // =========================
  // TOGGLE LIBRARY
  // =========================
  void toggleLibrary() {
    useDio.value = !useDio.value;
    loadSpices();
  }

  // =========================
  // EXPERIMEN ASYNC–AWAIT
  // =========================
  Future<void> loadSpicesWithRecommendation() async {
    try {
      recommendationText.value = "Memuat data rempah...";
      print("Memuat data rempah...");

      // API pertama
      final spicesData = await SpiceApiHttp.fetchSpices();
      final firstSpice = spicesData.first.name;

      // API kedua (chained request)
      final recommendation = await fetchRecommendation(firstSpice);

      recommendationText.value =
          "Rekomendasi untuk $firstSpice: $recommendation";
      print("Rekomendasi untuk $firstSpice: $recommendation");
    } catch (e) {
      print("Error async-await: $e");
      recommendationText.value = "Terjadi error: $e";
    }
  }

  // =========================
  // EXPERIMEN CALLBACK CHAINING
  // =========================
  void loadSpicesWithCallback() {
    recommendationText.value = "Memuat data rempah dengan callback...";
    print("Memuat data rempah dengan callback...");

    SpiceApiHttp.fetchSpices()
        .then((spicesData) {
          final firstSpice = spicesData.first.name;

          fetchRecommendation(firstSpice)
              .then((recommendation) {
                recommendationText.value =
                    "Rekomendasi untuk $firstSpice: $recommendation";
                print("Rekomendasi untuk $firstSpice: $recommendation");
              })
              .catchError((error) {
                print("Error saat fetch rekomendasi: $error");
                recommendationText.value = "Terjadi error saat rekomendasi.";
              });
        })
        .catchError((error) {
          print("Error callback chaining: $error");
          recommendationText.value = "Terjadi error saat memuat data rempah.";
        });
  }

  // =========================
  // SIMULASI API KEDUA
  // =========================
  Future<String> fetchRecommendation(String spiceName) async {
    await Future.delayed(const Duration(seconds: 2));
    return "Gunakan $spiceName untuk produk ekspor herbal 🌿";
  }
}
