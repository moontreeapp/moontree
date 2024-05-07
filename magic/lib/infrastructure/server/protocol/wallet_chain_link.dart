/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class WalletChainLink extends _i1.SerializableEntity {
  WalletChainLink({
    this.id,
    required this.walletId,
    required this.chainId,
    required this.highestUsedIndex,
  });

  factory WalletChainLink.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return WalletChainLink(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      walletId:
          serializationManager.deserialize<int>(jsonSerialization['walletId']),
      chainId:
          serializationManager.deserialize<int>(jsonSerialization['chainId']),
      highestUsedIndex: serializationManager
          .deserialize<int>(jsonSerialization['highestUsedIndex']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int walletId;

  int chainId;

  int highestUsedIndex;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletId': walletId,
      'chainId': chainId,
      'highestUsedIndex': highestUsedIndex,
    };
  }
}
