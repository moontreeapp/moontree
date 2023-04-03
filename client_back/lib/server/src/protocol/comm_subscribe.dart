/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class ChainWalletH160Subscription extends _i1.SerializableEntity {
  ChainWalletH160Subscription({
    this.id,
    required this.chains,
    required this.walletPubKeys,
    required this.h160s,
  });

  factory ChainWalletH160Subscription.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return ChainWalletH160Subscription(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      chains: serializationManager
          .deserialize<List<String>>(jsonSerialization['chains']),
      walletPubKeys: serializationManager
          .deserialize<List<String>>(jsonSerialization['walletPubKeys']),
      h160s: serializationManager
          .deserialize<List<String>>(jsonSerialization['h160s']),
    );
  }

  int? id;

  List<String> chains;

  List<String> walletPubKeys;

  List<String> h160s;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chains': chains,
      'walletPubKeys': walletPubKeys,
      'h160s': h160s,
    };
  }
}
