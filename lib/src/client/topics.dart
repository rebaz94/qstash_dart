import 'package:qstash_dart/qstash_dart.dart';
import 'package:qstash_dart/src/client/http.dart';

class CreateTopicRequest {
  CreateTopicRequest(this.name);

  /// The name of the topic.
  /// Must be unique and only contain alphanumeric, hyphen, underscore and periods.
  final String name;
}

class GetTopicRequest {
  const GetTopicRequest({
    this.id,
    this.name,
  }) : assert(id == null || name == null);

  final String? id;
  final String? name;
}

class UpdateTopicRequest {
  const UpdateTopicRequest({
    required this.id,
    this.name,
  });

  final String id;
  final String? name;
}

class DeleteTopicRequest {
  const DeleteTopicRequest({
    this.id,
    this.name,
  }) : assert(id == null || name == null);

  final String? id;
  final String? name;
}

class Topic {
  const Topic({
    required this.topicId,
    required this.name,
    required this.endpoints,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      topicId: json['topicId'] as String,
      name: json['name'] as String,
      endpoints: (json['endpoints'] as List).map((e) {
        return Endpoint.fromJson(Map<String, dynamic>.from(e));
      }).toList(),
    );
  }

  /// id for this topic
  final String topicId;

  /// The name of this topic.
  final String name;

  /// A list of all subscribed endpoints
  final List<Endpoint> endpoints;

  @override
  String toString() {
    return 'Topic{topicId: $topicId, name: $name, endpoints: $endpoints}';
  }
}

class Topics {
  Topics(Requester http) : _http = http;

  final Requester _http;

  /// Create a new topic with the given name.
  Future<UpstashResponse<Topic>> create(CreateTopicRequest request) async {
    return await _http.request<Topic, JsonMap>(
      UpstashRequest(
        method: Method.post,
        path: ['v1', 'topics'],
        body: stringify({'name': request.name}),
      ),
      Topic.fromJson,
    );
  }

  /// Get a list of all topics.
  Future<UpstashResponse<List<Topic>>> list() async {
    return await _http.request<List<Topic>, JsonList>(
      UpstashRequest(
        method: Method.get,
        path: ['v1', 'topics'],
      ),
      (json) => json.map(Topic.fromJson).toList(),
    );
  }

  /// Get a single topic by name or id.
  Future<UpstashResponse<Topic>> get(GetTopicRequest request) async {
    final idOrName = request.id ?? request.name;
    if (idOrName == null) {
      throw StateError("Either id or name must be provided");
    }

    return await _http.request<Topic, JsonMap>(
      UpstashRequest(
        method: Method.get,
        path: ['v1', 'topics', idOrName],
      ),
      Topic.fromJson,
    );
  }

  /// Update a topic
  Future<UpstashResponse<Topic>> update(UpdateTopicRequest request) async {
    return await _http.request<Topic, JsonMap>(
      UpstashRequest(
        method: Method.put,
        path: ['v1', "topics", request.id],
        body: stringify({'name': request.name}),
      ),
      Topic.fromJson,
    );
  }

  /// Delete a topic by name or id.
  Future<void> delete(DeleteTopicRequest request) async {
    final idOrName = request.id ?? request.name;
    if (idOrName == null) {
      throw StateError("Either id or name must be provided");
    }
    await _http.request<String, String>(
      UpstashRequest(
        method: Method.delete,
        path: ['v1', 'topics', idOrName],
      ),
      (_) => _,
    );
  }
}
