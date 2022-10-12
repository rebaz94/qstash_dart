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
            url: destinationUrl,
          ),
          body: 'Hi',
        ),
      );
      expect(response.exception, isNull);
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
            url: destinationUrl,
          ),
          body: {'hello': 'world'},
        ),
      );
      expect(response.exception, isNull);
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
            url: destinationUrl,
          ),
          body: {'hello': 'world'},
          cron: '9 * * * *',
        ),
      );
      expect(response.exception, isNull);
      expect(response.hasValue, true);
      expect(response.value.scheduleId, isNotNull);
      expect(response.value.messageId, isNull);
    },
  );
}
