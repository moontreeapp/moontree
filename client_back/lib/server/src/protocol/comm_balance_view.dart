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
    required this.sats,
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
      sats: serializationManager.deserialize<int>(jsonSerialization['sats']),
      symbol:
          serializationManager.deserialize<String>(jsonSerialization['symbol']),
      chain:
          serializationManager.deserialize<String?>(jsonSerialization['chain']),
    );
  }

  int? id;

  String? error;

  int sats;

  String symbol;

  String? chain;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'error': error,
      'sats': sats,
      'symbol': symbol,
      'chain': chain,
    };
  }
}
