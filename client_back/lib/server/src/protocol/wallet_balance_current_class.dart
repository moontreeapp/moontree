/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class WalletBalanceCurrent extends _i1.SerializableEntity {
  WalletBalanceCurrent({
    this.id,
    required this.walletId,
    this.assetId,
    required this.sats,
    required this.chainId,
  });

  factory WalletBalanceCurrent.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return WalletBalanceCurrent(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      walletId:
          serializationManager.deserialize<int>(jsonSerialization['walletId']),
      assetId:
          serializationManager.deserialize<int?>(jsonSerialization['assetId']),
      sats: serializationManager.deserialize<int>(jsonSerialization['sats']),
      chainId:
          serializationManager.deserialize<int>(jsonSerialization['chainId']),
    );
  }

  int? id;

  int walletId;

  int? assetId;

  int sats;

  int chainId;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletId': walletId,
      'assetId': assetId,
      'sats': sats,
      'chainId': chainId,
    };
  }
}
