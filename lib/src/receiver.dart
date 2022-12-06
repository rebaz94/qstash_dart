import 'dart:convert';

import 'package:crypto/crypto.dart';

class VerifyRequest {
  const VerifyRequest({
    required this.signature,
    required this.body,
    this.url,
    this.clockTolerance,
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

  /// Number of seconds to tolerate when checking `nbf` and `exp` claims, to deal with small clock differences among different servers
  ///
  /// @default 0
  final int? clockTolerance;
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

  static final _paddingRegExp = RegExp(r'=+$');

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
    final digestBase64 = base64Url.encode(digest.bytes);

    if (signature.replaceAll(_paddingRegExp, '') !=
        digestBase64.replaceAll(_paddingRegExp, '')) {
      throw SignatureError('signature does not match');
    }

    final normalizedPayload = base64.normalize(payload);
    final decodedPayload = Map<String, dynamic>.from(
      jsonDecode(
        String.fromCharCodes(base64Url.decode(normalizedPayload)),
      ),
    );

    if (decodedPayload['iss'] != 'Upstash') {
      throw SignatureError('invalid issuer: ${decodedPayload['iss']}');
    }

    if (request.url != null && decodedPayload['sub'] != request.url) {
      throw SignatureError(
        'invalid subject: ${decodedPayload['sub']}, want: ${request.url}',
      );
    }

    final exp = decodedPayload['exp'] as int;
    final nbf = decodedPayload['nbf'] as int;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final clockTolerance = request.clockTolerance ?? 0;
    if (now - clockTolerance > exp) {
      print({'now': now, 'exp': exp});
      throw SignatureError('token has expired');
    }

    if (now + clockTolerance < nbf) {
      throw SignatureError('token is not yet valid');
    }

    final bodyHash = sha256.convert(
      request.body is String ? utf8.encode(request.body) : request.body,
    );

    final payloadBody =
        (decodedPayload['body'] as String).replaceAll(_paddingRegExp, '');
    final base64EncodedBody =
        base64Url.encode(bodyHash.bytes).replaceAll(_paddingRegExp, '');
    if (payloadBody != base64EncodedBody) {
      throw SignatureError(
        'body hash does not match, want: $payloadBody, got: $base64EncodedBody',
      );
    }

    return true;
  }
}
