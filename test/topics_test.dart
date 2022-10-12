import 'package:qstash_dart/qstash_dart.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'utils.dart';

void main() async {
  final q = getTestClient();
  final topics = q.topics();
  final keygen = Keygen();
  final newTopic = keygen.newTopic;

  tearDownAll(() => keygen.cleanup());

  test(
    'create topic',
    () async {
      final topic = await topics.create(CreateTopicRequest(newTopic()));
      expect(topic.exception, isNull);
      expect(topic.error, isNull);
      expect(topic.hasValue, true);
      expect(topic.value, isA<Topic>());
    },
  );

  test(
    'list topic',
    () async {
      await topics.create(CreateTopicRequest(newTopic()));
      final allTopics = await topics.list();
      expect(allTopics.exception, isNull);
      expect(allTopics.hasValue, true);
      expect(allTopics.value, isA<List<Topic>>());
    },
  );

  test(
    'get topic',
    () async {
      final topic = await topics.create(CreateTopicRequest(newTopic()));

      final getTopic =
          await topics.get(GetTopicRequest(name: topic.value.name));
      expect(getTopic.exception, isNull);
      expect(getTopic.hasValue, true);
      expect(getTopic.value, isA<Topic>());
      expect(getTopic.value.name, topic.value.name);
    },
  );

  test(
    'update topic',
    () async {
      final topic = await topics.create(CreateTopicRequest(newTopic()));
      keygen.topicNames.add('test-updated');
      await Future.delayed(const Duration(seconds: 2));
      final updatedTopic = await topics.update(
        UpdateTopicRequest(id: topic.value.topicId, name: 'test-updated'),
      );

      expect(updatedTopic.exception, isNull);
      expect(updatedTopic.hasValue, true);
      expect(updatedTopic.value, isA<Topic>());
      expect(updatedTopic.value.name, 'test-updated');
    },
  );

  test(
    'delete topic',
    () async {
      final topic = await topics.create(CreateTopicRequest(newTopic()));
      await topics.delete(DeleteTopicRequest(id: topic.value.topicId));

      final notExistTopic =
          await topics.get(GetTopicRequest(id: topic.value.topicId));
      expect(notExistTopic.exception, isNull);
      expect(notExistTopic.hasError, isTrue);
      expect(notExistTopic.error, isNotEmpty);
    },
  );
}
