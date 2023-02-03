/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class NotifyChainWalletBalance extends _i1.SerializableEntity {
  NotifyChainWalletBalance({
    this.id,
    required this.chainName,
    required this.walletPubKey,
    this.symbol,
    required this.satsConfirmed,
    required this.satsUnconfirmed,
  });

  factory NotifyChainWalletBalance.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return NotifyChainWalletBalance(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      chainName: serializationManager
          .deserialize<String>(jsonSerialization['chainName']),
      walletPubKey: serializationManager
          .deserialize<String>(jsonSerialization['walletPubKey']),
      symbol: serializationManager
          .deserialize<String?>(jsonSerialization['symbol']),
      satsConfirmed: serializationManager
          .deserialize<int>(jsonSerialization['satsConfirmed']),
      satsUnconfirmed: serializationManager
          .deserialize<int>(jsonSerialization['satsUnconfirmed']),
    );
  }

  int? id;

  String chainName;

  String walletPubKey;

  String? symbol;

  int satsConfirmed;

  int satsUnconfirmed;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chainName': chainName,
      'walletPubKey': walletPubKey,
      'symbol': symbol,
      'satsConfirmed': satsConfirmed,
      'satsUnconfirmed': satsUnconfirmed,
    };
  }
}
