import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';

class IOSVersion {
  IOSVersion(
      {@required this.major, @required this.minor, @required this.patch});

  factory IOSVersion.fromString(String version) {
    final components = version.split('.');
    if (components.length != 3) {
      return null;
    }
    return IOSVersion(
      major: int.tryParse(components[0]),
      minor: int.tryParse(components[1]),
      patch: int.tryParse(components[2]),
    );
  }
  final int major;
  final int minor;
  final int patch;

  @override
  String toString() => '$major.$minor.$patch';
}

extension IOSVersionChecker on IOSVersion {
  static Future<IOSVersion> fromDeviceInfo() async {
    if (Platform.isIOS) {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      final version = iosInfo.systemVersion;
      return IOSVersion.fromString(version);
    }
    return null;
  }
}
