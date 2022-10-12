import 'package:qstash_dart/qstash_dart.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'utils.dart';

void main() async {
  final q = getTestClient();
  final schedules = q.schedules();

  test(
    'get schedule',
    () async {
      final result = await q.publishJSON(
        PublishRequest(
          destination: Destination(
            type: DestinationType.url,
            url: destinationUrl,
          ),
          cron: '9 * * * *',
        ),
      );
      final schedule =
          await schedules.get(GetScheduleRequest(result.value.scheduleId!));
      expect(schedule.exception, isNull);
      expect(schedule.hasValue, true);
      expect(schedule.value, isA<Schedule>());
      expect(schedule.value.scheduleId, result.value.scheduleId!);
    },
  );

  test(
    'list schedule',
    () async {
      final allSchedules = await schedules.list();
      expect(allSchedules.exception, isNull);
      expect(allSchedules.hasValue, true);
      expect(allSchedules.value, isA<List<Schedule>>());
    },
  );

  test(
    'delete schedule',
    () async {
      final result = await q.publishJSON(
        PublishRequest(
          destination: Destination(
            type: DestinationType.url,
            url: destinationUrl,
          ),
          cron: '9 * * * *',
        ),
      );

      final deleteResult = await schedules
          .delete(DeleteScheduleRequest(result.value.scheduleId!));
      expect(deleteResult.exception, isNull);
      expect(deleteResult.hasError, false);
      expect(deleteResult.value, 'Accepted');
    },
  );
}
