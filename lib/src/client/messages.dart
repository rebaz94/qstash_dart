import 'package:qstash_dart/src/client/http.dart';
import 'package:qstash_dart/src/client/types.dart';

class GetMessageRequest {
  const GetMessageRequest(this.id);

  final String id;
}

class CancelMessageRequest {
  const CancelMessageRequest(this.id);

  final String id;
}

class Message {
  const Message({
    required this.messageId,
    required this.header,
    required this.body,
    this.url,
    this.topicId,
  }) : assert(url == null || topicId == null);

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'] as String,
      header: Map<String, String>.from(json['header'] as Map),
      body: json['body'] as String,
      url: json['url'] as String?,
      topicId: json['topicId'] as String?,
    );
  }

  final String messageId;
  final Map<String, String> header;
  final String body;
  final String? url;
  final String? topicId;

  @override
  String toString() {
    return 'Message{messageId: $messageId, header: $header, body: $body, url: $url, topicId: $topicId}';
  }
}

class ListMessagesRequest {
  const ListMessagesRequest(this.cursor);

  final int? cursor;
}

class ListMessagesResponse {
  ListMessagesResponse(this.cursor, this.messages);

  factory ListMessagesResponse.fromJson(Map<String, dynamic> json) {
    return ListMessagesResponse(
      json['cursor'] as int?,
      (json['messages'] as List).map((e) {
        return Message.fromJson(Map<String, dynamic>.from(e));
      }).toList(),
    );
  }

  final int? cursor;
  final List<Message> messages;

  @override
  String toString() {
    return 'ListMessagesResponse{cursor: $cursor, messages: $messages}';
  }
}

class ListMessageLogsRequest {
  const ListMessageLogsRequest({
    required this.id,
    this.cursor,
  });

  /// Message id
  final String id;
  final int? cursor;
}

class ListMessageLogsResponse {
  ListMessageLogsResponse(
    this.cursor,
    this.logs,
  );

  factory ListMessageLogsResponse.fromJson(Map<String, dynamic> json) {
    return ListMessageLogsResponse(
      json['cursor'] as int?,
      (json['logs'] as List)
          .map((e) => Log.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  final int? cursor;
  final List<Log> logs;

  @override
  String toString() {
    return 'ListMessageLogsResponse{cursor: $cursor, logs: $logs}';
  }
}

class ListMessageTasksRequest {
  const ListMessageTasksRequest({required this.id, this.cursor});

  /// Message id
  final String id;
  final int? cursor;
}

class ListMessageTasksResponse {
  ListMessageTasksResponse(this.cursor, this.tasks);

  factory ListMessageTasksResponse.fromJson(Map<String, dynamic> json) {
    return ListMessageTasksResponse(
      json['cursor'] as int?,
      (json['tasks'] as List)
          .map((e) => Task.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  final int? cursor;
  final List<Task> tasks;

  @override
  String toString() {
    return 'ListMessageTasksResponse{cursor: $cursor, tasks: $tasks}';
  }
}

class Messages {
  final Requester _http;

  Messages(Requester http) : _http = http;

  /// Get a message
  Future<UpstashResponse<Message>> get(GetMessageRequest request) async {
    return await _http.request<Message, JsonMap>(
      UpstashRequest(
        method: Method.get,
        path: ['v1', 'messages', request.id],
      ),
      Message.fromJson,
    );
  }

  /// List your messages
  Future<UpstashResponse<ListMessagesResponse>> list(
      [ListMessagesRequest? request]) async {
    return await _http.request<ListMessagesResponse, JsonMap>(
      UpstashRequest(
        method: Method.get,
        path: ['v1', 'messages'],
        query: {
          if (request?.cursor != null) 'cursor': request!.cursor!.toString()
        },
      ),
      ListMessagesResponse.fromJson,
    );
  }

  /// List logs from a message
  Future<UpstashResponse<ListMessageLogsResponse>> logs(
      ListMessageLogsRequest request) async {
    return await _http.request<ListMessageLogsResponse, JsonMap>(
      UpstashRequest(
        method: Method.get,
        path: ['v1', 'messages', request.id, 'logs'],
        query: {
          if (request.cursor != null) 'cursor': request.cursor!.toString()
        },
      ),
      ListMessageLogsResponse.fromJson,
    );
  }

  /// List tasks for a message
  Future<UpstashResponse<ListMessageTasksResponse>> tasks(
      ListMessageTasksRequest request) async {
    return await _http.request<ListMessageTasksResponse, JsonMap>(
      UpstashRequest(
        method: Method.get,
        path: ['v1', 'messages', request.id, 'tasks'],
        query: {
          if (request.cursor != null) 'cursor': request.cursor!.toString()
        },
      ),
      ListMessageTasksResponse.fromJson,
    );
  }

  /// Cancel a topic by name or id.
  Future<UpstashResponse<String>> delete(CancelMessageRequest request) async {
    return await _http.request<String, String>(
      UpstashRequest(
        method: Method.delete,
        path: ['v1', 'messages', request.id],
      ),
      (value) => value,
    );
  }
}
