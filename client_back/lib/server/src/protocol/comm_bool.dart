/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class CommBool extends _i1.SerializableEntity {
  CommBool({
    this.id,
    this.error,
    required this.value,
  });

  factory CommBool.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return CommBool(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      error:
          serializationManager.deserialize<String?>(jsonSerialization['error']),
      value: serializationManager.deserialize<bool>(jsonSerialization['value']),
    );
  }

  int? id;

  String? error;

  bool value;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'error': error,
      'value': value,
    };
  }
}
