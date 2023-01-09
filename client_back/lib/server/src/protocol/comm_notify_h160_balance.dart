/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class NotifyChainH160Balance extends _i1.SerializableEntity {
  NotifyChainH160Balance({
    this.id,
    required this.chainName,
    required this.h160,
    required this.sats,
  });

  factory NotifyChainH160Balance.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return NotifyChainH160Balance(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      chainName: serializationManager
          .deserialize<String>(jsonSerialization['chainName']),
      h160: serializationManager.deserialize<String>(jsonSerialization['h160']),
      sats: serializationManager.deserialize<int>(jsonSerialization['sats']),
    );
  }

  int? id;

  String chainName;

  String h160;

  int sats;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chainName': chainName,
      'h160': h160,
      'sats': sats,
    };
  }
}
