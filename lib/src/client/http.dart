import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:qstash_dart/src/client/error.dart';

enum Method {
  post,
  get,
  put,
  delete,
}

class UpstashRequest {
  UpstashRequest({
    this.path = const [],
    this.body,
    this.headers = const {"Content-Type": "application/json"},
    this.keepalive,
    required this.method,
    this.query,
  });

  /// The path to the resource.
  final List<String> path;

  /// A Headers object, an object literal, or an array of two-item arrays to set request's headers.
  final Map<String, String>? headers;

  /// [body] A BodyInit object or null to set request's body.
  final Object? body;

  /// [keepalive] A boolean to set request's keepalive.

  final bool? keepalive;

  /// [method] A string to set request's method.

  final Method method;
  final Map<String, dynamic>? query;
}

class UpstashResponse<TResult> {
  const UpstashResponse({
    this.result,
    this.error,
    this.exception,
  });

  factory UpstashResponse.error(String error, [QstashException? exception]) {
    return UpstashResponse(error: error, exception: exception);
  }

  static UpstashResponse<TResult> parse<TResult, TResponse>(
    http.Response res,
    TResult Function(TResponse) modelFromJson,
  ) {
    final decodedValue = const [String, int, double, num, bool].contains(TResult)
        ? res.body
        : json.decode(res.body);

    final TResult bodyResult;
    String? error;

    try {
      if (res.statusCode < 200 || res.statusCode >= 300) {
        if (decodedValue is Map && decodedValue['error'] is String) {
          return UpstashResponse.error(decodedValue['error']);
        } else {
          return UpstashResponse.error(
              res.body.isNotEmpty ? res.body : 'StatusCode: ${res.statusCode}');
        }
      }

      if (decodedValue is List) {
        bodyResult = modelFromJson(
          decodedValue.map((e) => Map<String, dynamic>.from(e)).toList()
              as TResponse,
        );
      } else if (decodedValue is Map) {
        bodyResult =
            modelFromJson(Map<String, dynamic>.from(decodedValue) as TResponse);
        error = decodedValue['error'] as String?;
      } else {
        bodyResult = decodedValue as TResult;
      }

      return UpstashResponse(result: bodyResult, error: error);
    } catch (e, s) {
      if (decodedValue is Map && decodedValue['error'] is String) {
        return UpstashResponse.error(decodedValue['error']);
      } else {
        return UpstashResponse.error(
            'Decoding failed', QstashDecodingError('decoding failed', e, s));
      }
    }
  }

  final TResult? result;
  final String? error;
  final QstashException? exception;

  /// Result parsed from response
  ///
  /// note, ensure error is null before accessing this property
  TResult get value {
    return result!;
  }

  /// Return true if [error] is not null.
  bool get hasError {
    return error != null;
  }

  /// Return true if [result] != null.
  bool get hasValue {
    return result != null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpstashResponse &&
          runtimeType == other.runtimeType &&
          result == other.result &&
          error == other.error &&
          exception == other.exception;

  @override
  int get hashCode => result.hashCode ^ error.hashCode ^ exception.hashCode;

  @override
  String toString() {
    return 'UpstashResponse{result: $result, error: $error, exception: $exception}';
  }
}

typedef Decoder<M, V> = M Function(V json);
typedef JsonMap = Map<String, dynamic>;
typedef JsonList = List<Map<String, dynamic>>;

abstract class Requester {
  Future<UpstashResponse<TResult>> request<TResult, TResponse>(
    UpstashRequest req,
    Decoder<TResult, TResponse> fromJson,
  );
}

String stringify(Object? data) {
  return jsonEncode(data);
}

class RetryConfig {
  const RetryConfig({
    this.retries = 5,
    this.backoff = _defaultBackoff,
  });

  /// The number of retries to attempt before giving up.
  ///
  /// default 5
  final int retries;

  /// A backoff function receives the current retry count and returns a number in milliseconds to wait before retrying.
  ///
  /// default
  /// math.exp(retryCount) * 50
  final double Function(int retryCount) backoff;
}

double _defaultBackoff(int retryCount) {
  return math.exp(retryCount) * 50;
}

class Retry {
  const Retry({
    required this.attempts,
    this.backoff = _defaultBackoff,
  });

  /// The number of retries to attempt before giving up.
  final int attempts;

  /// A backoff function receives the current retry count and returns a number in milliseconds to wait before retrying.
  final double Function(int retryCount) backoff;
}

class HttpClientConfig {
  HttpClientConfig({
    required this.baseUrl,
    required this.authorization,
    this.retry,
  });

  final String baseUrl;
  final String authorization;
  final RetryConfig? retry;
}

class HttpClient implements Requester {
  HttpClient(HttpClientConfig config)
      : baseUrl = config.baseUrl.replaceAll(RegExp(r'/$'), ''),
        authorization = config.authorization,
        retry = config.retry == null
            ? Retry(attempts: 1, backoff: (retryCount) => 0)
            : Retry(
                attempts: config.retry!.retries,
                backoff: config.retry!.backoff,
              );

  final String baseUrl;
  final String authorization;
  final Retry retry;

  @override
  Future<UpstashResponse<TResult>> request<TResult, TResponse>(
    UpstashRequest req,
    Decoder<TResult, TResponse> fromJson,
  ) async {
    http.Response? rawResponse;
    try {
      rawResponse = await _makeRequest(req);
    } on QstashException catch (e) {
      return UpstashResponse(
        error: e.message,
        exception: e,
      );
    } catch (e) {
      return UpstashResponse(
        error: 'Request to upstash failed',
        exception: QstashException(e.toString()),
      );
    }

    // final value = parseResponse<TResponse>(decodedValue);
    // bodyResult = fromJson(value);
    return UpstashResponse.parse<TResult, TResponse>(rawResponse, fromJson);
  }

  Future<http.Response> _makeRequest(UpstashRequest req) async {
    final headers = Map<String, String>.from(req.headers ?? {});
    headers['Authorization'] = authorization;

    Uri uri = Uri.parse([baseUrl, ...req.path].join('/'));

    if (req.query != null) {
      uri = uri.replace(
          queryParameters: req.query!
            ..removeWhere((_, value) => value == null));
    }

    http.Response? result;
    dynamic error;

    for (int i = 0; i <= retry.attempts; i++) {
      try {
        switch (req.method) {
          case Method.post:
            result = await http.post(uri, headers: headers, body: req.body);
            break;
          case Method.put:
            result = await http.put(uri, headers: headers, body: req.body);
            break;
          case Method.delete:
            result = await http.delete(uri, headers: headers, body: req.body);
            break;
          default:
            result = await http.get(uri, headers: headers);
        }
        break;
      } catch (e) {
        error = e;
        await Future.delayed(Duration(milliseconds: retry.backoff(i).toInt()));
      }
    }

    if (result == null) {
      if (error != null) {
        throw QstashException(error.toString());
      }

      throw QstashRetryError('Exhausted all retries');
    }

    return result;
  }
}
