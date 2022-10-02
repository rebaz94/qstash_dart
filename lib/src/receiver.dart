import 'dart:convert';

import 'package:crypto/crypto.dart';

class VerifyRequest {
  const VerifyRequest({
    required this.signature,
    required this.body,
    this.url,
  });

  /// The signature from the `upstash-signature` header.
  final String signature;

  /// The raw request body.
  // String | Uint8List
  final dynamic body;

  /// URL of the endpoint where the request was sent to.
  ///
  /// Omit empty to disable checking the url.
  final String? url;
}

class SignatureError implements Exception {
  final String message;

  SignatureError(this.message);

  @override
  String toString() {
    return 'SignatureError{message: $message}';
  }
}

class Receiver {
  Receiver({
    required this.currentSigningKey,
    required this.nextSigningKey,
  });

  /// The current signing key. Get it from `https://console.upstash.com/qstash
  final String currentSigningKey;

  /// The next signing key. Get it from `https://console.upstash.com/qstash
  final String nextSigningKey;

  Future<bool> verify(VerifyRequest request) async {
    final isValid = await _verifyWithKey(currentSigningKey, request);
    if (isValid) {
      return true;
    }

    return _verifyWithKey(nextSigningKey, request);
  }

  final _cachedValue = <String, Hmac>{};

  Future<bool> _verifyWithKey(String key, VerifyRequest request) async {
    final parts = request.signature.split('.');

    if (parts.length != 3) {
      throw SignatureError(
        '`Upstash-Signature` header is not a valid signature',
      );
    }

    final header = parts[0];
    final payload = parts[1];
    final signature = parts[2];

    final hmacSha256 = _cachedValue.putIfAbsent(
      key,
      () => Hmac(sha256, utf8.encode(key)),
    );

    final message = utf8.encode('$header.$payload');
    final digest = hmacSha256.convert(message);

    return signature.replaceAll('=', '') ==
        base64Encode(digest.bytes).replaceAll('=', '');
  }
}
