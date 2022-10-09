import 'package:qstash_dart/src/client/endpoints.dart';
import 'package:qstash_dart/src/client/http.dart';
import 'package:qstash_dart/src/client/messages.dart';
import 'package:qstash_dart/src/client/platform/platform.dart';
import 'package:qstash_dart/src/client/schedules.dart';
import 'package:qstash_dart/src/client/topics.dart';
import 'package:qstash_dart/src/client/types.dart';

class ClientConfig {
  const ClientConfig({
    this.baseUrl,
    required this.token,
    this.retryConfig,
  });

  /// Url of the qstash api server.
  ///
  /// This is only used for testing.
  ///
  /// @default "https://qstash.upstash.io"
  final String? baseUrl;

  /// The authorization token from the upstash console.
  final String token;

  /// The retry configuration
  final RetryConfig? retryConfig;
}

enum DestinationType {
  url,
  topic,
}

class Destination {
  const Destination({
    required this.type,
    this.url,
    this.topicId,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      type:
          json['type'] == 'topic' ? DestinationType.topic : DestinationType.url,
      url: json['url'] as String?,
      topicId: json['topicId'] as String?,
    );
  }

  final DestinationType type;

  /// The url of a publicly accessible server where you want to send this message to.
  /// The url must have a valid scheme (http or https).
  final String? url;

  /// Either the name or id of a topic to send this message to.
  final String? topicId;

  @override
  String toString() {
    return 'Destination{type: $type, url: $url, topicId: $topicId}';
  }
}

class PublishRequest {
  const PublishRequest({
    required this.destination,
    this.body,
    this.headers,
    this.delay,
    this.notBefore,
    this.deduplicationId,
    this.contentBasedDeduplication,
    this.retries,
    this.cron,
  });

  /// The destination
  final Destination destination;

  /// The message to send.
  ///
  /// This can be anything, but please set the `Content-Type` header accordingly.
  ///
  /// You can leave this empty if you want to send a message with no body.
  final Object? body;

  /// Optionally send along headers with the message.
  /// These headers will be sent to your destination.
  ///
  /// We highly recommend sending a `Content-Type` header along, as this will help your destination
  /// server to understand the content of the message.
  final Map<String, dynamic>? headers;

  /// Optionally delay the delivery of this message.
  ///
  /// In seconds.
  ///
  /// @default undefined
  final int? delay;

  /// Optionally set the absolute delay of this message.
  /// This will override the delay option.
  /// The message will not delivered until the specified time.
  ///
  /// Unix timestamp in seconds.
  ///
  /// @default undefined
  final int? notBefore;

  /// Provide a unique id for deduplication. This id will be used to detect duplicate messages.
  /// If a duplicate message is detected, the request will be accepted but not enqueued.
  ///
  /// We store deduplication ids for 90 days. Afterwards it is possible that the message with the
  /// same deduplication id is delivered again.
  ///
  /// When scheduling a message, the deduplication happens before the schedule is created.
  ///
  /// @default undefined
  final String? deduplicationId;

  /// If true, the message content will get hashed and used as deduplication id.
  /// If a duplicate message is detected, the request will be accepted but not enqueued.
  ///
  /// The content based hash includes the following values:
  ///    - All headers, except Upstash-Authorization, this includes all headers you are sending.
  ///    - The entire raw request body The destination from the url path
  ///
  /// We store deduplication ids for 90 days. Afterwards it is possible that the message with the
  /// same deduplication id is delivered again.
  ///
  /// When scheduling a message, the deduplication happens before the schedule is created.
  ///
  /// @default false
  final bool? contentBasedDeduplication;

  /// In case your destination server is unavailable or returns a status code outside of the 200-299
  /// range, we will retry the request after a certain amount of time.
  ///
  /// Configure how many times you would like the delivery to be retried
  ///
  /// @default The maximum retry quota associated with your account.
  final int? retries;

  /// Optionally specify a cron expression to repeatedly send this message to the destination.
  ///
  /// @default undefined
  final String? cron;

  PublishRequest copyWith({Map<String, String>? headers, Object? body}) {
    return PublishRequest(
      destination: destination,
      body: body ?? this.body,
      headers: headers ?? this.headers,
      delay: delay,
      notBefore: notBefore,
      deduplicationId: deduplicationId,
      contentBasedDeduplication: contentBasedDeduplication,
      retries: retries,
      cron: cron,
    );
  }
}

class PublishResponse {
  PublishResponse({
    required this.scheduleId,
    required this.messageId,
  });

  factory PublishResponse.fromJson(Map<String, dynamic> json) {
    return PublishResponse(
      scheduleId: json['scheduleId'] as String?,
      messageId: json['messageId'] as String?,
    );
  }

  /// Return true when response is scheduled. (the [PublishRequest] provides cron parameter]
  bool get isScheduled {
    return scheduleId != null;
  }

  /// The schedule id, only has value when [PublishRequest] has [cron] parameter
  final String? scheduleId;

  /// The message id.
  final String? messageId;

  @override
  String toString() {
    return 'PublishResponse{scheduleId: $scheduleId, messageId: $messageId}';
  }
}

typedef PublishJsonRequest = PublishRequest;

class LogsRequest {
  LogsRequest({required this.cursor});

  final int? cursor;
}

class GetLogsResponse {
  GetLogsResponse(this.cursor, this.logs);

  factory GetLogsResponse.fromJson(Map<String, dynamic> json) {
    return GetLogsResponse(
      json['cursor'] as int?,
      (json['logs'] as List).map((e) {
        return Log.fromJson(Map<String, dynamic>.from(e));
      }).toList(),
    );
  }

  final int? cursor;
  final List<Log> logs;
}

class Client {
  final Requester http;

  Client._(Requester requester) : http = requester;

  factory Client(ClientConfig config) {
    return Client._(
      HttpClient(
        HttpClientConfig(
          baseUrl: config.baseUrl != null
              ? config.baseUrl!.replaceAll(RegExp(r'/$'), '')
              : 'https://qstash.upstash.io',
          authorization: 'Bearer ${config.token}',
          retry: config.retryConfig,
        ),
      ),
    );
  }

  factory Client.byClient(Requester client) {
    return Client._(client);
  }

  factory Client.fromEnv({
    RetryConfig? retryConfig,
  }) {
    final platform = PlatformEnv();
    final url = platform['QSTASH_REST_URL'] ?? '';
    final token = platform['QSTASH_REST_TOKEN'] ?? '';

    if (token.isEmpty) {
      throw Exception(
        'Unable to find environment variable: `QSTASH_REST_TOKEN`.',
      );
    }

    return Client(
      ClientConfig(
        baseUrl: url.isNotEmpty ? url : null,
        token: token,
        retryConfig: retryConfig,
      ),
    );
  }

  /// Access the topic API.
  ///
  /// Create, read, update or delete topics.
  Topics topics() {
    return Topics(http);
  }

  /// Access the endpoint API.
  ///
  /// Create, read, update or delete endpoints.
  Endpoints endpoints() {
    return Endpoints(http);
  }

  /// Access the message API.
  ///
  /// Read or cancel messages.
  Messages messages() {
    return Messages(http);
  }

  /// Access the schedule API.
  ///
  /// Read or delete schedules.
  Schedules schedules() {
    return Schedules(http);
  }

  Future<UpstashResponse<PublishResponse>> publish(PublishRequest req) async {
    final destination = req.destination.url ?? req.destination.topicId;
    if (destination == null) {
      throw StateError('Either url or topic must be set');
    }

    final headers = Map<String, String>.from(req.headers ?? {});

    if (req.delay != null) {
      headers['Upstash-Delay'] = '${req.delay}s';
    }

    if (req.notBefore != null) {
      headers['Upstash-Not-Before'] = req.notBefore.toString();
    }

    if (req.deduplicationId != null) {
      headers['Upstash-Deduplication-Id'] = req.deduplicationId!;
    }

    if (req.contentBasedDeduplication == true) {
      headers['Upstash-Content-Based-Deduplication'] = 'true';
    }

    if (req.retries != null) {
      headers['Upstash-Retries'] = req.retries.toString();
    }

    if (req.cron != null) {
      headers['Upstash-Cron'] = req.cron!;
    }

    final result = await http.request<PublishResponse, JsonMap>(
      UpstashRequest(
        method: Method.post,
        path: ['v1', 'publish', destination],
        body: req.body,
        headers: headers,
      ),
      PublishResponse.fromJson,
    );
    return result;
  }

  /// publishJSON is a utility wrapper around `publish` that automatically serializes the body
  /// and sets the `Content-Type` header to `application/json`.
  Future<UpstashResponse<PublishResponse>> publishJSON(
      PublishRequest request) async {
    final headers = Map<String, String>.from(request.headers ?? {});
    headers['Content-Type'] = 'application/json';

    final result = await publish(
      request.copyWith(
        headers: headers,
        body: request.body != null ? stringify(request.body) : null,
      ),
    );
    return result;
  }

  /// Retrieve your logs.
  ///
  /// The logs endpoint is paginated and returns only 100 logs at a time.
  /// If you want to receive more logs, you can use the cursor to paginate.
  ///
  /// The cursor is a unix timestamp with millisecond precision
  ///
  /// @example
  /// ```dart
  /// int cursor = DateTime.now().millisecondsSinceEpoch;
  /// final logs = <Log>[];
  /// while (cursor > 0) {
  ///   final res = await qstash.logs(LogsRequest(cursor: cursor));
  ///   logs.addAll(res.logs);
  ///   cursor = res.cursor ?? 0;
  /// }
  /// ```
  Future<UpstashResponse<GetLogsResponse>> logs([LogsRequest? request]) async {
    final query = <String, int>{};
    final cursor = request?.cursor;
    if (cursor != null && cursor > 0) {
      query['cursor'] = cursor;
    }

    final result = await http.request<GetLogsResponse, JsonMap>(
      UpstashRequest(
        method: Method.get,
        path: ['v1', 'logs'],
        query: query,
      ),
      GetLogsResponse.fromJson,
    );

    return result;
  }
}
