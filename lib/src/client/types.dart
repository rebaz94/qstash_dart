enum State {
  created,
  planned,
  active,
  delivered,
  error,
  failed,
  canceled,
}

class Log {
  const Log({
    required this.time,
    required this.state,
    required this.messageId,
    this.taskId,
    this.nextScheduledAt,
    this.error,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      time: json['time'] as int,
      state: State.values.byName(json['state'] as String),
      messageId: json['messageId'] as String,
      taskId: json['taskId'] as String?,
      nextScheduledAt: json['nextScheduledAt'] as int?,
      error: json['error'] as String?,
    );
  }

  final int time;
  final State state;
  final String messageId;
  final String? taskId;
  final int? nextScheduledAt;
  final String? error;

  @override
  String toString() {
    return 'Log{time: $time, state: $state, messageId: $messageId, '
        'taskId: $taskId, nextScheduledAt: $nextScheduledAt, error: $error}';
  }
}

class Task {
  const Task({
    required this.taskId,
    required this.state,
    required this.maxRetry,
    required this.retried,
    this.completedAt,
    required this.url,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['taskId'] as String,
      state: State.values.byName(json['state'] as String),
      maxRetry: json['maxRetry'] as int,
      retried: json['retried'] as int,
      completedAt: json['completedAt'] as int?,
      url: json['url'] as String,
    );
  }

  final String taskId;
  final State state;
  final int maxRetry;
  final int retried;
  final int? completedAt;
  final String url;
}
