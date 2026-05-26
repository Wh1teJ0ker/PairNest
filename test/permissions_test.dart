import 'package:flutter_test/flutter_test.dart';
import 'package:pairnest/src/core/permissions.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  test('nearby permissions for Android 11 request location and bluetooth', () {
    expect(Permissions.nearbyPermissionsForSdk(30), <Permission>[
      Permission.location,
      Permission.bluetooth,
    ]);
  });

  test(
    'nearby permissions for Android 12 request location plus bluetooth runtime permissions',
    () {
      expect(Permissions.nearbyPermissionsForSdk(31), <Permission>[
        Permission.location,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
      ]);
    },
  );

  test(
    'nearby permissions for Android 13 and above skip location and request nearby wifi devices',
    () {
      expect(Permissions.nearbyPermissionsForSdk(34), <Permission>[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.nearbyWifiDevices,
      ]);
    },
  );
}
