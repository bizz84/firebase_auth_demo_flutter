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
      minor: int.tryParse(components[0]),
      patch: int.tryParse(components[0]),
    );
  }
  final int major;
  final int minor;
  final int patch;
}

extension IOSVersionChecker on IOSVersion {
  static Future<IOSVersion> fromDeviceInfo() async {
    final iosInfo = await DeviceInfoPlugin().iosInfo;
    final version = iosInfo.systemVersion;
    return IOSVersion.fromString(version);
  }
}
