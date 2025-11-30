import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  StreamSubscription<Position>? _positionStreamSub;

  /// Request permission, return true if granted
  static Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Get current position (with desired accuracy)
  static Future<Position> getCurrent({
    LocationAccuracy accuracy = LocationAccuracy.best,
  }) {
    return Geolocator.getCurrentPosition(desiredAccuracy: accuracy);
  }

  /// Start streaming positions; callback called for every position
  void startStream({
    required void Function(Position) onData,
    LocationAccuracy accuracy = LocationAccuracy.best,
    int distanceFilter = 5,
    bool forceAndroidLocationManager = false,
  }) {
    stopStream();
    LocationSettings locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );

    _positionStreamSub =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            onData(position);
          },
          onError: (e) {
            // pass through errors if needed
          },
        );
  }

  void stopStream() {
    _positionStreamSub?.cancel();
    _positionStreamSub = null;
  }

  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }
}
