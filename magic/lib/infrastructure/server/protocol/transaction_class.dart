/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:typed_data' as _i2;

class BlockchainTransaction extends _i1.SerializableEntity {
  BlockchainTransaction({
    this.id,
    required this.hash,
    required this.height,
    required this.size,
    required this.vsize,
    required this.fee,
    required this.chainId,
    this.opReturnId,
  });

  factory BlockchainTransaction.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return BlockchainTransaction(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      hash: serializationManager
          .deserialize<_i2.ByteData>(jsonSerialization['hash']),
      height:
          serializationManager.deserialize<int>(jsonSerialization['height']),
      size: serializationManager.deserialize<int>(jsonSerialization['size']),
      vsize: serializationManager.deserialize<int>(jsonSerialization['vsize']),
      fee: serializationManager.deserialize<int>(jsonSerialization['fee']),
      chainId:
          serializationManager.deserialize<int>(jsonSerialization['chainId']),
      opReturnId: serializationManager
          .deserialize<int?>(jsonSerialization['opReturnId']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i2.ByteData hash;

  int height;

  int size;

  int vsize;

  int fee;

  int chainId;

  int? opReturnId;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hash': hash,
      'height': height,
      'size': size,
      'vsize': vsize,
      'fee': fee,
      'chainId': chainId,
      'opReturnId': opReturnId,
    };
  }
}
