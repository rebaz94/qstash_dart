import 'dart:io';

import 'package:qstash_dart/src/client/platform/platform.dart';

class IOPlatform implements PlatformEnv {
  const IOPlatform();

  @override
  String? operator [](String key) => Platform.environment[key];
}

PlatformEnv getPlatform() => const IOPlatform();
