class QstashException implements Exception {
  QstashException(this.message);

  final String message;
}

class QstashError extends QstashException {
  QstashError(super.message);

  @override
  String toString() {
    return 'QstashError($message)';
  }
}

class QstashRetryError extends QstashException {
  QstashRetryError(super.message);

  @override
  String toString() {
    return 'QstashRetryError($message)';
  }
}

class QstashDecodingError extends QstashException {
  QstashDecodingError(
    super.message,
    this.error,
    this.trace,
  );

  final dynamic error;
  final StackTrace? trace;

  @override
  String toString() {
    return 'QstashDecodingError($message, error: $error, trace: $trace)';
  }
}
