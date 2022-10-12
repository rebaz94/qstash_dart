import 'package:qstash_dart/qstash_dart.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() async {
  final q = getTestClient();

  final receiver = Receiver(
    currentSigningKey: "sig_7dskHhQGd7zBn4pUmfcuuhoVv8dV",
    nextSigningKey: "sig_7JUWKbCTjbxGvaBg5M788TTRBLtj",
  );

  final testValues = {
    'Hello World':
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiIiLCJib2R5IjoicFpHbTFBdjBJRUJLQVJjeno3ZXhrTllzWmI4THphTXJWN0ozMmEyZkZHND0iLCJleHAiOjE2NjU2MTUwMzgsImlhdCI6MTY2NTYxNDczOCwiaXNzIjoiVXBzdGFzaCIsImp0aSI6Imp3dF82ZDRCUXd6RzRDb0hadGU4VkNoSk54SnVuMTVDIiwibmJmIjoxNjY1NjE0NzM4LCJzdWIiOiJodHRwczovL3JlYmF6LXFzdGFzaC5yZXF1ZXN0Y2F0Y2hlci5jb20vdGVzdCJ9.y0_9NlMBUmO9dlPxG0PlnyekjfO88oIKfgmJfcoYo8k',
    '{"name": "rebaz", "language": "dart"}':
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiIiLCJib2R5IjoieWJVbHl6Y3pUM3ZxTG4yRG9lT1ZqUnRWX2RKN3ZsZGdlTE9xZW14TVFmRT0iLCJleHAiOjE2NjU2MTUwMDksImlhdCI6MTY2NTYxNDcwOSwiaXNzIjoiVXBzdGFzaCIsImp0aSI6Imp3dF82OXBiNkZja0txU3VMOGRQR0RlVjlVZGl4RlVLIiwibmJmIjoxNjY1NjE0NzA5LCJzdWIiOiJodHRwczovL3JlYmF6LXFzdGFzaC5yZXF1ZXN0Y2F0Y2hlci5jb20vdGVzdCJ9.rWpRAf9AmdLOpq9xsM7VGVxL44KfQTfxcA2TtIUHC9E',
  };

  test(
    'verify signature',
    () async {
      for (final entry in testValues.entries) {
        await q.publish(
          PublishRequest(
            destination: Destination(
              type: DestinationType.url,
              url: destinationUrl,
            ),
            body: entry.key,
          ),
        );

        // Validating a signature
        final isValid = await receiver.verify(
          VerifyRequest(
            body: entry.key,
            signature: entry.value,
            url: destinationUrl,
          ),
        );
        expect(isValid, isTrue);
      }
    },
  );
}
