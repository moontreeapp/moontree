//import 'dart:io';
/* on dart upgrade platform_device_id began to fail: 
FAILURE: Build failed with an exception.

* What went wrong:
The Android Gradle plugin supports only Kotlin Gradle plugin version 1.5.20 and higher.
The following dependencies do not satisfy the required version:
project ':platform_device_id' -> org.jetbrains.kotlin:kotlin-gradle-plugin:1.3.50
//import 'package:platform_device_id/platform_device_id.dart';
//Future<String> getId() async {
//  return await PlatformDeviceId.getDeviceId ??
//      (Platform.isIOS
//          ? (await PlatformDeviceId.deviceInfoPlugin.iosInfo)
//              .identifierForVendor
//          : (await PlatformDeviceId.deviceInfoPlugin.androidInfo).androidId);
//}
*/

/* this solution might work but device_info has been discontinued
import 'package:device_info/device_info.dart';

Future<String> getId() async {
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    return androidInfo.androidId; // UID for Android devices
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
    return iosInfo.identifierForVendor; // UID for iOS devices
  }
  return 'Unknown'; // UID not available for other platforms
}
*/
/*
import 'package:device_info_plus/device_info_plus.dart';

Future<String> getId() async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    print((await deviceInfoPlugin.androidInfo).fingerprint);
    return (await deviceInfoPlugin.androidInfo).id;
    //return (await deviceInfoPlugin.androidInfo).fingerprint;
  } else if (Platform.isIOS) {
    return (await deviceInfoPlugin.iosInfo).identifierForVendor ??
        (await deviceInfoPlugin.iosInfo).name;
  } else if (Platform.isLinux) {
    return (await deviceInfoPlugin.linuxInfo).id;
  } else if (Platform.isMacOS) {
    return (await deviceInfoPlugin.macOsInfo).systemGUID ??
        (await deviceInfoPlugin.macOsInfo).computerName;
  } else if (Platform.isWindows) {
    return (await deviceInfoPlugin.windowsInfo).deviceId;
  }
  return (await deviceInfoPlugin.deviceInfo).data.toString();
}
*/