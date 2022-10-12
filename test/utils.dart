import 'dart:math' as math;

import 'package:qstash_dart/qstash_dart.dart';

QstashClient getTestClient() {
  return QstashClient.fromEnv();
}

final _random = math.Random();

final destinationUrl = 'https://rebaz-qstash.requestcatcher.com/test';

String randomID() {
  return _random.nextInt(10000000).toString();
}

String randomDestinationUrl() {
  return 'https://rebaz-qstash.requestcatcher.com/test${randomID()}';
}

class Keygen {
  final List<String> topicNames = [];

  String newTopic() {
    final key = 'topic-${randomID()}';
    topicNames.add(key);
    return key;
  }

  Future<void> cleanup() async {
    if (topicNames.isEmpty) return;
    final topics = getTestClient().topics();
    await Future.wait(
        topicNames.map((e) => topics.delete(DeleteTopicRequest(name: e))));
  }
}
