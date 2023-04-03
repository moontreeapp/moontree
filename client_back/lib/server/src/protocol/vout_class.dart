/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:typed_data' as _i2;

class Vout extends _i1.SerializableEntity {
  Vout({
    this.id,
    required this.transactionId,
    required this.chainId,
    this.assetId,
    this.h160Id,
    required this.idx,
    required this.sats,
    this.lockingScript,
    required this.lockingScriptType,
    this.assetMemo,
    this.assetMemoTimestamp,
    this.vinTransactionId,
    this.vinIdx,
  });

  factory Vout.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return Vout(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      transactionId: serializationManager
          .deserialize<int>(jsonSerialization['transactionId']),
      chainId:
          serializationManager.deserialize<int>(jsonSerialization['chainId']),
      assetId:
          serializationManager.deserialize<int?>(jsonSerialization['assetId']),
      h160Id:
          serializationManager.deserialize<int?>(jsonSerialization['h160Id']),
      idx: serializationManager.deserialize<int>(jsonSerialization['idx']),
      sats: serializationManager.deserialize<int>(jsonSerialization['sats']),
      lockingScript: serializationManager
          .deserialize<_i2.ByteData?>(jsonSerialization['lockingScript']),
      lockingScriptType: serializationManager
          .deserialize<int>(jsonSerialization['lockingScriptType']),
      assetMemo: serializationManager
          .deserialize<_i2.ByteData?>(jsonSerialization['assetMemo']),
      assetMemoTimestamp: serializationManager
          .deserialize<int?>(jsonSerialization['assetMemoTimestamp']),
      vinTransactionId: serializationManager
          .deserialize<int?>(jsonSerialization['vinTransactionId']),
      vinIdx:
          serializationManager.deserialize<int?>(jsonSerialization['vinIdx']),
    );
  }

  int? id;

  int transactionId;

  int chainId;

  int? assetId;

  int? h160Id;

  int idx;

  int sats;

  _i2.ByteData? lockingScript;

  int lockingScriptType;

  _i2.ByteData? assetMemo;

  int? assetMemoTimestamp;

  int? vinTransactionId;

  int? vinIdx;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'chainId': chainId,
      'assetId': assetId,
      'h160Id': h160Id,
      'idx': idx,
      'sats': sats,
      'lockingScript': lockingScript,
      'lockingScriptType': lockingScriptType,
      'assetMemo': assetMemo,
      'assetMemoTimestamp': assetMemoTimestamp,
      'vinTransactionId': vinTransactionId,
      'vinIdx': vinIdx,
    };
  }
}
