import 'dart:io';
import 'package:platform_device_id/platform_device_id.dart';

Future<String> getId() async {
  return await PlatformDeviceId.getDeviceId ??
      (Platform.isIOS
          ? (await PlatformDeviceId.deviceInfoPlugin.iosInfo)
              .identifierForVendor
          : (await PlatformDeviceId.deviceInfoPlugin.androidInfo).androidId);
}
