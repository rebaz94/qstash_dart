import 'package:qstash_dart/qstash_dart.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'utils.dart';

void main() async {
  final q = getTestClient();
  final messages = q.messages();

  test(
    'get message',
    () async {
      final response = await q.publishJSON(
        PublishRequest(
          destination: Destination(
            type: DestinationType.url,
            url: destinationUrl,
          ),
          body: {},
        ),
      );
      final message =
          await messages.get(GetMessageRequest(response.value.messageId!));
      expect(message.exception, isNull);
      expect(message.hasValue, true);
      expect(message.value.messageId, response.value.messageId);
    },
  );

  test(
    'list messages',
    () async {
      await q.publishJSON(
        PublishRequest(
          destination: Destination(
            type: DestinationType.url,
            url: destinationUrl,
          ),
          body: {},
        ),
      );
      final allMessages = await messages.list();
      expect(allMessages.exception, isNull);
      expect(allMessages.hasValue, true);
    },
  );

  test(
    'list messages with cursor',
    () async {
      final allMessages = await messages.list(
        ListMessagesRequest(
          DateTime.now().millisecondsSinceEpoch,
        ),
      );
      expect(allMessages.exception, isNull);
      expect(allMessages.hasValue, true);
    },
  );

  test(
    'log messages',
    () async {
      final response = await q.publishJSON(
        PublishRequest(
          destination: Destination(
            type: DestinationType.url,
            url: destinationUrl,
          ),
          body: {},
        ),
      );

      final logs = await messages
          .logs(ListMessageLogsRequest(id: response.value.messageId!));
      expect(logs.exception, isNull);
      expect(logs.hasValue, true);
    },
  );

  test(
    'task messages',
    () async {
      final response = await q.publishJSON(
        PublishRequest(
          destination: Destination(
            type: DestinationType.url,
            url: destinationUrl,
          ),
          body: {},
        ),
      );

      final tasks = await messages
          .tasks(ListMessageTasksRequest(id: response.value.messageId!));
      expect(tasks.exception, isNull);
      expect(tasks.hasValue, true);
    },
  );

  test(
    'delete message',
    () async {
      final response = await q.publishJSON(
        PublishRequest(
          destination: Destination(
            type: DestinationType.url,
            url: destinationUrl,
          ),
          body: {},
          delay: 2,
        ),
      );

      final cancelMsgResult = await messages
          .delete(CancelMessageRequest(response.value.messageId!));
      expect(cancelMsgResult.exception, isNull);
      expect(cancelMsgResult.hasValue, true);
      expect(cancelMsgResult.value, 'Accepted');
    },
  );
}
