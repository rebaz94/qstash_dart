import 'package:qstash_dart/qstash_dart.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'utils.dart';

void main() async {
  final q = getTestClient();

  test(
    'publish message',
    () async {
      final response = await q.publish(
        PublishRequest(
          destination: Destination(
            type: DestinationType.url,
            url: 'https://rebaz-qstash.requestcatcher.com/test',
          ),
          body: 'Hi',
        ),
      );
      expect(response.hasValue, true);
      expect(response.value.messageId, isNotNull);
    },
  );

  test(
    'publish JSON message',
    () async {
      final response = await q.publishJSON(
        PublishRequest(
          destination: Destination(
            type: DestinationType.url,
            url: 'https://rebaz-qstash.requestcatcher.com/test',
          ),
          body: {'hello': 'world'},
        ),
      );
      expect(response.hasValue, true);
      expect(response.value.messageId, isNotNull);
    },
  );

  test(
    'publish scheduled message',
    () async {
      final response = await q.publishJSON(
        PublishRequest(
          destination: Destination(
            type: DestinationType.url,
            url: 'https://rebaz-qstash.requestcatcher.com/test',
          ),
          body: {'hello': 'world'},
          cron: '9 * * * *',
        ),
      );
      expect(response.hasValue, true);
      expect(response.value.scheduleId, isNotNull);
      expect(response.value.messageId, isNull);
    },
  );
}
