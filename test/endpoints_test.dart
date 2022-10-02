import 'dart:math';

import 'package:qstash_dart/qstash_dart.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'utils.dart';

void main() async {
  final q = getTestClient();
  final endpoints = q.endpoints();
  final topic = await q
      .topics()
      .create(CreateTopicRequest('test-${Random().nextInt(100)}'));

  test(
    'create endpoint',
    () async {
      final endpoint = await endpoints.create(
        CreateEndpointRequest(
          topicName: topic.value.name,
          url: 'https://rebaz-qstash.requestcatcher.com/test',
        ),
      );
      expect(endpoint.hasValue, true);
      expect(
          endpoint.value.url, 'https://rebaz-qstash.requestcatcher.com/test');
    },
  );

  test(
    'list endpoints',
    () async {
      final endpoint = await endpoints.create(
        CreateEndpointRequest(
          topicName: topic.value.name,
          url: 'https://rebaz-qstash.requestcatcher.com/test',
        ),
      );

      final allEndpoints = await endpoints.list();
      expect(allEndpoints.hasValue, true);
      expect(allEndpoints.value, isA<List<Endpoint>>());
      expect(
          allEndpoints.value
              .firstWhere((e) => e.endpointId == endpoint.value.endpointId),
          isNotNull);
    },
  );

  test(
    'get endpoint',
    () async {
      final newEndpoint = await endpoints.create(
        CreateEndpointRequest(
          topicName: topic.value.name,
          url: 'https://rebaz-qstash.requestcatcher.com/test',
        ),
      );

      final endpoint =
          await endpoints.get(GetEndpointRequest(newEndpoint.value.endpointId));
      expect(endpoint.hasValue, true);
      expect(endpoint.value, isA<Endpoint>());
      expect(endpoint.value.endpointId, newEndpoint.value.endpointId);
    },
  );

  test(
    'update endpoint',
    () async {
      final newEndpoint = await endpoints.create(
        CreateEndpointRequest(
          topicName: topic.value.name,
          url: 'https://rebaz-qstash.requestcatcher.com/test',
        ),
      );

      final endpoint = await endpoints.update(UpdateEndpointRequest(
        id: newEndpoint.value.endpointId,
        url: 'https://google.com/test',
      ));
      expect(endpoint.hasValue, true);
      expect(endpoint.value, isA<Endpoint>());
      expect(endpoint.value.url, 'https://google.com/test');
    },
  );

  test(
    'delete endpoint',
    () async {
      final newEndpoint = await endpoints.create(
        CreateEndpointRequest(
          topicName: topic.value.name,
          url: 'https://rebaz-qstash.requestcatcher.com/test',
        ),
      );

      final endpoint = await endpoints
          .delete(DeleteEndpointRequest(newEndpoint.value.endpointId));
      expect(endpoint.hasValue, true);
      expect(endpoint.value, 'OK');
    },
  );
}
