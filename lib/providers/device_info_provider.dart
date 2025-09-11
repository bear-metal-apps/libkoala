import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_info_provider.g.dart';

@riverpod
DeviceInfo deviceInfo(Ref ref) {
  final DevicePlatform devicePlatform;
  final DeviceOS deviceOS;

  if (kIsWeb) {
    devicePlatform = DevicePlatform.web;
    deviceOS = DeviceOS.web;
  } else if (Platform.isAndroid) {
    devicePlatform = DevicePlatform.mobile;
    deviceOS = DeviceOS.android;
  } else if (Platform.isIOS) {
    devicePlatform = DevicePlatform.mobile;
    deviceOS = DeviceOS.ios;
  } else if (Platform.isWindows) {
    devicePlatform = DevicePlatform.desktop;
    deviceOS = DeviceOS.windows;
  } else if (Platform.isLinux) {
    devicePlatform = DevicePlatform.desktop;
    deviceOS = DeviceOS.linux;
  } else if (Platform.isMacOS) {
    devicePlatform = DevicePlatform.desktop;
    deviceOS = DeviceOS.macos;
  } else {
    devicePlatform = DevicePlatform.web;
    deviceOS = DeviceOS.web;
  }

  return DeviceInfo(deviceType: devicePlatform, deviceOS: deviceOS);
}

class DeviceInfo {
  final DevicePlatform deviceType;
  final DeviceOS deviceOS;

  DeviceInfo({required this.deviceType, required this.deviceOS});
}

enum DevicePlatform { mobile, desktop, web }

enum DeviceOS { android, ios, windows, linux, macos, web }
