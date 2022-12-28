/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class RestrictedH160FreezeLink extends _i1.SerializableEntity {
  RestrictedH160FreezeLink({
    this.id,
    required this.h160Id,
    required this.assetId,
    required this.frozen,
    required this.voutId,
  });

  factory RestrictedH160FreezeLink.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return RestrictedH160FreezeLink(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      h160Id:
          serializationManager.deserialize<int>(jsonSerialization['h160Id']),
      assetId:
          serializationManager.deserialize<int>(jsonSerialization['assetId']),
      frozen:
          serializationManager.deserialize<bool>(jsonSerialization['frozen']),
      voutId:
          serializationManager.deserialize<int>(jsonSerialization['voutId']),
    );
  }

  int? id;

  int h160Id;

  int assetId;

  bool frozen;

  int voutId;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'h160Id': h160Id,
      'assetId': assetId,
      'frozen': frozen,
      'voutId': voutId,
    };
  }
}
