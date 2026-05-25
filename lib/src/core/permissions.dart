import 'package:permission_handler/permission_handler.dart';

class Permissions {
  static Future<bool> ensureCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> ensureGalleryRead() async {
    final photos = await Permission.photos.request();
    if (photos.isGranted || photos.isLimited) {
      return true;
    }
    final storage = await Permission.storage.request();
    return storage.isGranted;
  }

  static Future<bool> ensureNearby() async {
    final requests = <Permission>[
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.nearbyWifiDevices,
    ];

    final results = await requests.request();
    final denied = results.values.any((status) {
      return !(status.isGranted || status.isLimited);
    });
    return !denied;
  }
}
