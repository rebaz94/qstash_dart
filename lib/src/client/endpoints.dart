import 'package:qstash_dart/src/client/http.dart';

class CreateEndpointRequest {
  const CreateEndpointRequest({
    required this.url,
    required this.topicName,
  });

  /// The url of the endpoint.
  final String url;

  /// The name of the topic to subscribe to.
  final String topicName;

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'topicName': topicName,
    };
  }
}

class GetEndpointRequest {
  const GetEndpointRequest(this.id);

  final String id;
}

class UpdateEndpointRequest {
  const UpdateEndpointRequest({
    required this.id,
    this.url,
  });

  final String id;
  final String? url;
}

class DeleteEndpointRequest {
  const DeleteEndpointRequest(this.id);

  final String id;
}

class Endpoint {
  const Endpoint({
    required this.endpointId,
    required this.url,
    required this.topicId,
  });

  factory Endpoint.fromJson(Map<String, dynamic> json) {
    return Endpoint(
      endpointId: json['endpointId'] as String,
      url: json['url'] as String,
      topicId: json['topicId'] as String,
    );
  }

  /// id for this endpoint
  final String endpointId;

  /// The url of this endpoint.
  final String url;

  /// The topic id this endpoint is subscribed to.
  final String topicId;

  @override
  String toString() {
    return 'Endpoint{endpointId: $endpointId, url: $url, topicId: $topicId}';
  }
}

class Endpoints {
  final Requester _http;

  Endpoints(Requester http) : _http = http;

  /// Create a new endpoint with the given name.
  Future<UpstashResponse<Endpoint>> create(
      CreateEndpointRequest request) async {
    return await _http.request<Endpoint, JsonMap>(
      UpstashRequest(
        method: Method.post,
        path: ['v1', 'endpoints'],
        body: stringify(request.toJson()),
      ),
      Endpoint.fromJson,
    );
  }

  /// Get a list of all endpoints.
  Future<UpstashResponse<List<Endpoint>>> list() async {
    return await _http.request<List<Endpoint>, JsonList>(
      UpstashRequest(
        method: Method.get,
        path: ['v1', 'endpoints'],
      ),
      (json) => json.map(Endpoint.fromJson).toList(),
    );
  }

  /// Get a single endpoint.
  Future<UpstashResponse<Endpoint>> get(GetEndpointRequest request) async {
    return await _http.request<Endpoint, JsonMap>(
      UpstashRequest(
        method: Method.get,
        path: ['v1', 'endpoints', request.id],
      ),
      Endpoint.fromJson,
    );
  }

  /// Update a endpoint
  Future<UpstashResponse<Endpoint>> update(
      UpdateEndpointRequest request) async {
    return await _http.request<Endpoint, JsonMap>(
      UpstashRequest(
        method: Method.put,
        path: ['v1', 'endpoints', request.id],
        body: stringify({'url': request.url}),
      ),
      Endpoint.fromJson,
    );
  }

  /// Delete a endpoint.
  Future<UpstashResponse<String>> delete(DeleteEndpointRequest request) async {
    return await _http.request<String, String>(
      UpstashRequest(
        method: Method.delete,
        path: ['v1', 'endpoints', request.id],
      ),
      (value) => value,
    );
  }
}
