/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class Asset extends _i1.SerializableEntity {
  Asset({
    this.id,
    required this.chainId,
    required this.symbol,
    required this.latestMetadataId,
  });

  factory Asset.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return Asset(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      chainId:
          serializationManager.deserialize<int>(jsonSerialization['chainId']),
      symbol:
          serializationManager.deserialize<String>(jsonSerialization['symbol']),
      latestMetadataId: serializationManager
          .deserialize<int>(jsonSerialization['latestMetadataId']),
    );
  }

  int? id;

  int chainId;

  String symbol;

  int latestMetadataId;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chainId': chainId,
      'symbol': symbol,
      'latestMetadataId': latestMetadataId,
    };
  }
}
