# Upstash QStash SDK

**QStash** is an HTTP based messaging and scheduling solution for serverless and
edge runtimes.

It is 100% built on stateless HTTP requests and designed for:

- Serverless functions (AWS Lambda ...)
- Cloudflare Workers (see
  [the example](https://github.com/upstash/sdk-qstash-ts/tree/main/examples/cloudflare-workers))
- Fastly Compute@Edge
- Next.js, including [edge](https://nextjs.org/docs/api-reference/edge-runtime)
- Deno
- Client side web/mobile applications
- WebAssembly
- and other environments where HTTP is preferred over TCP.

## Status of the SDK

It is currently in beta and we are actively collecting feedback from the
community. Please report any issues you encounter or feature requests in the
[GitHub issues](https://github.com/upstash/sdk-qstash-ts/issues) or talk to us
on [Discord](https://discord.gg/w9SenAtbme). Thank you!

## How does QStash work?

QStash is the message broker between your serverless apps. You send an HTTP
request to QStash, that includes a destination, a payload and optional settings.
We durably store your message and will deliver it to the destination API via
HTTP. In case the destination is not ready to receive the message, we will retry
the message later, to guarentee at-least-once delivery.

## Quick Start

### Install

```
dart pub add qstash_dart
```

### Get your authorization token

Go to [upstash](https://console.upstash.com/qstash) and copy the token.

## Basic Usage:

### Publishing a message

```dart
import 'package:qstash_dart/qstash_dart.dart';

void main() async {
  final c = Client(
    ClientConfig(
      token: '<QSTASH_TOKEN>',
    ),
  );

  final res = await c.publishJSON(
    PublishRequest(
      destination: const Destination(
        type: DestinationType.url,
        url: 'https://rebaz-qstash.requestcatcher.com/test',
        // or topic: "the name or id of a topic"
      ),
      body: {
        'hello': 'world',
      },
    ),
  );
  print(res);
}
// PublishResponse{scheduleId: null, messageId: msg_xxxxxxxxxxxxxxxx}
```

### Receiving a message

How to receive a message depends on your http server. The `Receiver.verify`
method should be called by you as the first step in your handler function.

```dart
import 'package:qstash_dart/qstash_dart.dart';

void main() async {
  final receiver = Receiver(
    currentSigningKey: "sig_55CLgfUo1cbmvP6kZ2Z3WU4fQ1A3",
    nextSigningKey: "sig_7E7ZLVMTgAp7hMkz9qPRHXj44xnB",
  );

  // Validating a signature
  final isValid = await receiver.verify(
    VerifyRequest(
      body: 'string', // the raw request body
      signature: 'string', // The signature from the `Upstash-Signature` header
    ),
  );
}
```

## Docs

See [the documentation](https://docs.upstash.com/qstash) for details.

## Contributing

- Fork the repo on [GitHub](https://github.com/rebaz94/qstash_dart)
- Clone the project to your own machine
- Commit changes to your own branch
- Push your work back up to your fork
- Submit a Pull request so that we can review your changes and merge

## License

This repo is licenced under MIT.

## Credits

- https://github.com/upstash/sdk-qstash-ts