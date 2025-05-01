import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<bool> checkPermission() async {
    return await Permission.location.request().isGranted;
  }

  static Future<Position?> getCurrentLocation() async {
    if (await checkPermission()) {
      try {
        return await Geolocator.getCurrentPosition();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static String formatLocation(Position position) {
    return 'Lat: ${position.latitude.toStringAsFixed(4)}, '
        'Long: ${position.longitude.toStringAsFixed(4)}';
  }

  static String getLocationUrl(Position position) {
    return 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
  }
}
