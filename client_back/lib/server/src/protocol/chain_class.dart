/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class Chain extends _i1.SerializableEntity {
  Chain({
    this.id,
    required this.name,
    required this.height,
    required this.upToDate,
    required this.circulatingSats,
  });

  factory Chain.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return Chain(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      name: serializationManager.deserialize<String>(jsonSerialization['name']),
      height:
          serializationManager.deserialize<int>(jsonSerialization['height']),
      upToDate:
          serializationManager.deserialize<bool>(jsonSerialization['upToDate']),
      circulatingSats: serializationManager
          .deserialize<int>(jsonSerialization['circulatingSats']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  int height;

  bool upToDate;

  int circulatingSats;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'height': height,
      'upToDate': upToDate,
      'circulatingSats': circulatingSats,
    };
  }
}
