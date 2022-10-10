import 'package:qstash_dart/qstash_dart.dart';

void main() async {
  final q = QstashClient.fromEnv();

  final receiver = Receiver(
    currentSigningKey: "sig_55CLgfUo1cbmvP6kZ2Z3WU4fQ1A3",
    nextSigningKey: "sig_7E7ZLVMTgAp7hMkz9qPRHXj44xnB",
  );

  final res = await q.publish(
    PublishRequest(
      destination: const Destination(
        type: DestinationType.url,
        url: 'https://rebaz-qstash.requestcatcher.com/test',
      ),
      body: 'Hello World',
    ),
  );

  print(res);

  // Validating a signature
  final isValid = await receiver.verify(
    VerifyRequest(
      body: 'Hello World',
      signature:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiIiLCJib2R5IjoicFpHbTFBdjBJRUJLQVJjeno3ZXhrTllzWmI4THphTXJWN0ozMmEyZkZHND0iLCJleHAiOjE2NjQ3MTM0NjQsImlhdCI6MTY2NDcxMzE2NCwiaXNzIjoiVXBzdGFzaCIsImp0aSI6Imp3dF82dVpvN1VMV3I5TXVlellTb1R2eGlZRUtZSG9CIiwibmJmIjoxNjY0NzEzMTY0LCJzdWIiOiJodHRwczovL3JlYmF6LXFzdGFzaC5yZXF1ZXN0Y2F0Y2hlci5jb20vdGVzdCJ9.bCqTHNMDIXxkvOP1b66t00lwF405LLayzHndSXirDlM',
      url: 'https://rebaz-qstash.requestcatcher.com/test',
    ),
  );

  print(isValid);
}
