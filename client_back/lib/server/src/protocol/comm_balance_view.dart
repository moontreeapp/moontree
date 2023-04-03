/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class BalanceView extends _i1.SerializableEntity {
  BalanceView({
    this.id,
    this.error,
    required this.satsConfirmed,
    required this.satsUnconfirmed,
    required this.symbol,
    this.chain,
  });

  factory BalanceView.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return BalanceView(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      error:
          serializationManager.deserialize<String?>(jsonSerialization['error']),
      satsConfirmed: serializationManager
          .deserialize<int>(jsonSerialization['satsConfirmed']),
      satsUnconfirmed: serializationManager
          .deserialize<int>(jsonSerialization['satsUnconfirmed']),
      symbol:
          serializationManager.deserialize<String>(jsonSerialization['symbol']),
      chain:
          serializationManager.deserialize<String?>(jsonSerialization['chain']),
    );
  }

  int? id;

  String? error;

  int satsConfirmed;

  int satsUnconfirmed;

  String symbol;

  String? chain;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'error': error,
      'satsConfirmed': satsConfirmed,
      'satsUnconfirmed': satsUnconfirmed,
      'symbol': symbol,
      'chain': chain,
    };
  }
}
