/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class NotifyChainHeight extends _i1.SerializableEntity {
  NotifyChainHeight({
    this.id,
    required this.chainName,
    required this.height,
  });

  factory NotifyChainHeight.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return NotifyChainHeight(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      chainName: serializationManager
          .deserialize<String>(jsonSerialization['chainName']),
      height:
          serializationManager.deserialize<int>(jsonSerialization['height']),
    );
  }

  int? id;

  String chainName;

  int height;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chainName': chainName,
      'height': height,
    };
  }
}
