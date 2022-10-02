import 'package:qstash_dart/src/client/client.dart';
import 'package:qstash_dart/src/client/http.dart';
import 'package:qstash_dart/src/client/types.dart';

class GetScheduleRequest {
  const GetScheduleRequest(this.id);

  final String id;
}

class DeleteScheduleRequest {
  const DeleteScheduleRequest(this.id);

  final String id;
}

class Schedule {
  Schedule({
    required this.scheduleId,
    required this.cron,
    required this.createdAt,
    required this.contentHeader,
    required this.contentBody,
    required this.destination,
    required this.settingsDeadline,
    required this.settingsNotBefore,
    required this.settingsRetries,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      scheduleId: json['scheduleId'] as String,
      cron: json['cron'] as String,
      createdAt: int.parse('${json['createdAt']}'),
      contentHeader:
          Map<String, dynamic>.from(json['content']['header'] as Map),
      contentBody: json['content']['body'] as String?,
      destination: Destination.fromJson(
          Map<String, dynamic>.from(json['destination'] as Map)),
      settingsDeadline: json['settings']?['deadline'] as int?,
      settingsNotBefore: json['settings']?['notBefore'] as int?,
      settingsRetries: json['settings']?['retries'] as int?,
    );
  }

  final String scheduleId;
  final String cron;
  final int createdAt;
  final Map<String, dynamic> contentHeader;
  final String? contentBody;
  final Destination destination;
  final int? settingsDeadline;
  final int? settingsNotBefore;
  final int? settingsRetries;

  @override
  String toString() {
    return 'Schedule{scheduleId: $scheduleId, cron: $cron, createdAt: $createdAt, '
        'contentHeader: $contentHeader, contentBody: $contentBody, destination: $destination, settingsDeadline: $settingsDeadline, settingsNotBefore: $settingsNotBefore, settingsRetries: $settingsRetries}';
  }
}

class ListScheduleLogsRequest {
  ListScheduleLogsRequest(this.id, this.cursor);

  /// Schedule id
  final String id;
  final int? cursor;
}

class ListScheduleLogsResponse {
  ListScheduleLogsResponse(
    this.cursor,
    this.logs,
  );

  factory ListScheduleLogsResponse.fromJson(Map<String, dynamic> json) {
    return ListScheduleLogsResponse(
      json['cursor'] as int?,
      (json['logs'] as List)
          .map((e) => Log.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  final int? cursor;
  final List<Log> logs;
}

class ListScheduleTasksRequest {
  ListScheduleTasksRequest(this.id, this.cursor);

  /// Schedule id
  final String id;
  final int? cursor;
}

class ListScheduleTasksResponse {
  ListScheduleTasksResponse(this.cursor, this.logs);

  factory ListScheduleTasksResponse.fromJson(Map<String, dynamic> json) {
    return ListScheduleTasksResponse(
      json['cursor'] as int?,
      (json['logs'] as List)
          .map((e) => Task.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  final int? cursor;
  final List<Task> logs;
}

class Schedules {
  final Requester _http;

  Schedules(Requester http) : _http = http;

  /// Get a schedule
  Future<UpstashResponse<Schedule>> get(GetScheduleRequest request) async {
    return await _http.request<Schedule, JsonMap>(
      UpstashRequest(
        method: Method.get,
        path: ['v1', 'schedules', request.id],
      ),
      Schedule.fromJson,
    );
  }

  /// List your schedules
  Future<UpstashResponse<List<Schedule>>> list() async {
    return await _http.request<List<Schedule>, JsonList>(
      UpstashRequest(
        method: Method.get,
        path: ['v1', 'schedules'],
      ),
      (json) => json.map(Schedule.fromJson).toList(),
    );
  }

  /// Delete a schedule
  Future<UpstashResponse<String>> delete(DeleteScheduleRequest request) async {
    return await _http.request<String, String>(
      UpstashRequest(
        method: Method.delete,
        path: ['v1', 'schedules', request.id],
      ),
      (value) => value,
    );
  }
}
