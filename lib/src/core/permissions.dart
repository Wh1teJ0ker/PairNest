import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
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
    if (!Platform.isAndroid) {
      return true;
    }

    final sdkInt = await androidSdkInt();
    final requests = nearbyPermissionsForSdk(sdkInt);

    final results = await requests.request();
    final denied = results.values.any((status) {
      return !(status.isGranted || status.isLimited);
    });
    return !denied;
  }

  static Future<int> androidSdkInt() async {
    final info = await DeviceInfoPlugin().androidInfo;
    return info.version.sdkInt;
  }

  static List<Permission> nearbyPermissionsForSdk(int sdkInt) {
    if (sdkInt >= 32) {
      return const <Permission>[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.nearbyWifiDevices,
      ];
    }

    if (sdkInt == 31) {
      return const <Permission>[
        Permission.location,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
      ];
    }

    return const <Permission>[Permission.location, Permission.bluetooth];
  }
}
