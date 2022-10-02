import 'package:qstash_dart/src/client/platform/platform.dart';

class WebPlatform implements PlatformEnv {
  const WebPlatform();

  @override
  String? operator [](String key) => null;
}

PlatformEnv getPlatform() => const WebPlatform();
