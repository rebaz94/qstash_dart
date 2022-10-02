import 'package:qstash_dart/qstash_dart.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'utils.dart';

void main() async {
  final q = getTestClient();
  final topics = q.topics();

  test(
    'create topic',
    () async {
      final newTopic = await topics.create(CreateTopicRequest('test'));
      expect(newTopic.hasValue, true);
      expect(newTopic.value, isA<Topic>());
    },
  );

  test(
    'list topic',
    () async {
      final allTopics = await topics.list();
      expect(allTopics.hasValue, true);
      expect(allTopics.value, isA<List<Topic>>());
    },
  );

  test(
    'get topic',
    () async {
      final topic = await topics.get(const GetTopicRequest(name: 'test'));
      expect(topic.hasValue, true);
      expect(topic.value, isA<Topic>());
      expect(topic.value.name, 'test');
    },
  );

  test(
    'update topic',
    () async {
      final newTopic = await topics.create(CreateTopicRequest('test'));
      final topic = await topics.update(
        UpdateTopicRequest(id: newTopic.value.topicId, name: 'test-updated'),
      );
      expect(topic.hasValue, true);
      expect(topic.value, isA<Topic>());
      expect(topic.value.name, 'test-updated');
    },
  );

  test(
    'delete topic',
    () async {
      final topic = await topics.create(CreateTopicRequest('test'));
      await topics.delete(DeleteTopicRequest(id: topic.value.topicId));

      final notExistTopic =
          await topics.get(GetTopicRequest(id: topic.value.topicId));
      expect(notExistTopic.hasError, isTrue);
      expect(notExistTopic.error, isNotEmpty);
    },
  );
}
