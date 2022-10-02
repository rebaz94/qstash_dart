import 'package:qstash_dart/qstash_dart.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() async {
  final q = getTestClient();

  final receiver = Receiver(
    currentSigningKey: "sig_55CLgfUo1cbmvP6kZ2Z3WU4fQ1A3",
    nextSigningKey: "sig_7E7ZLVMTgAp7hMkz9qPRHXj44xnB",
  );

  final testValues = {
    'Hello World':
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiIiLCJib2R5IjoicFpHbTFBdjBJRUJLQVJjeno3ZXhrTllzWmI4THphTXJWN0ozMmEyZkZHND0iLCJleHAiOjE2NjQ3MTM0NjQsImlhdCI6MTY2NDcxMzE2NCwiaXNzIjoiVXBzdGFzaCIsImp0aSI6Imp3dF82dVpvN1VMV3I5TXVlellTb1R2eGlZRUtZSG9CIiwibmJmIjoxNjY0NzEzMTY0LCJzdWIiOiJodHRwczovL3JlYmF6LXFzdGFzaC5yZXF1ZXN0Y2F0Y2hlci5jb20vdGVzdCJ9.bCqTHNMDIXxkvOP1b66t00lwF405LLayzHndSXirDlM',
    '{"name": "rebaz", "language": "dart"}':
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiIiLCJib2R5IjoieWJVbHl6Y3pUM3ZxTG4yRG9lT1ZqUnRWX2RKN3ZsZGdlTE9xZW14TVFmRT0iLCJleHAiOjE2NjQ3MTQyMTcsImlhdCI6MTY2NDcxMzkxNywiaXNzIjoiVXBzdGFzaCIsImp0aSI6Imp3dF82c1J5akpLQ1RDUXhFRUxYZWl3R2M3emRwUUtCIiwibmJmIjoxNjY0NzEzOTE3LCJzdWIiOiJodHRwczovL3JlYmF6LXFzdGFzaC5yZXF1ZXN0Y2F0Y2hlci5jb20vdGVzdCJ9.FgUxFucnrIQQOkcH82UT4gZ5XLaN5j28JwZYFPvu0q0',
  };

  test(
    'verify signature',
    () async {
      for (final entry in testValues.entries) {
        await q.publish(
          PublishRequest(
            destination: const Destination(
              type: DestinationType.url,
              url: 'https://rebaz-qstash.requestcatcher.com/test',
            ),
            body: entry.key,
          ),
        );

        // Validating a signature
        final isValid = await receiver.verify(
          VerifyRequest(
            body: entry.key,
            signature: entry.value,
            url: 'https://rebaz-qstash.requestcatcher.com/test',
          ),
        );
        expect(isValid, isTrue);
      }
    },
  );
}
