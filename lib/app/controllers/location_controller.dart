import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class LocationController extends GetxController {
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var accuracy = 0.0.obs;
  var isLoading = false.obs;

  Stream<Position>? positionStream;

  @override
  void onInit() {
    super.onInit();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  // HIGH ACCURACY (GPS)
  Future<void> getGPSLocation() async {
    try {
      isLoading.value = true;
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude.value = pos.latitude;
      longitude.value = pos.longitude;
      accuracy.value = pos.accuracy;
    } catch (e) {
      print("GPS Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // NETWORK PROVIDER (LOW ACCURACY)
  Future<void> getNetworkLocation() async {
    try {
      isLoading.value = true;
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      latitude.value = pos.latitude;
      longitude.value = pos.longitude;
      accuracy.value = pos.accuracy;
    } catch (e) {
      print("Network Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // REAL-TIME / LIVE LOCATION
  void startLiveLocation() {
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 3,
      ),
    );

    positionStream!.listen((pos) {
      latitude.value = pos.latitude;
      longitude.value = pos.longitude;
      accuracy.value = pos.accuracy;
    });
  }
}
