/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:typed_data' as _i2;

class BlockchainBlock extends _i1.SerializableEntity {
  BlockchainBlock({
    this.id,
    required this.chainId,
    required this.height,
    required this.hash,
    required this.blocktime,
    required this.insertedAt,
  });

  factory BlockchainBlock.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return BlockchainBlock(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      chainId:
          serializationManager.deserialize<int>(jsonSerialization['chainId']),
      height:
          serializationManager.deserialize<int>(jsonSerialization['height']),
      hash: serializationManager
          .deserialize<_i2.ByteData>(jsonSerialization['hash']),
      blocktime: serializationManager
          .deserialize<DateTime>(jsonSerialization['blocktime']),
      insertedAt: serializationManager
          .deserialize<DateTime>(jsonSerialization['insertedAt']),
    );
  }

  int? id;

  int chainId;

  int height;

  _i2.ByteData hash;

  DateTime blocktime;

  DateTime insertedAt;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chainId': chainId,
      'height': height,
      'hash': hash,
      'blocktime': blocktime,
      'insertedAt': insertedAt,
    };
  }
}
