/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class UnsignedTransactionRequest extends _i1.SerializableEntity {
  UnsignedTransactionRequest({
    this.id,
    required this.myH106s,
    required this.myPubkeys,
    this.feeRateKb,
    required this.eachOutputAddress,
    required this.eachOutputAsset,
    required this.eachOutputAmount,
  });

  factory UnsignedTransactionRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return UnsignedTransactionRequest(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      myH106s: serializationManager
          .deserialize<List<String>>(jsonSerialization['myH106s']),
      myPubkeys: serializationManager
          .deserialize<List<String>>(jsonSerialization['myPubkeys']),
      feeRateKb: serializationManager
          .deserialize<double?>(jsonSerialization['feeRateKb']),
      eachOutputAddress: serializationManager
          .deserialize<List<String>>(jsonSerialization['eachOutputAddress']),
      eachOutputAsset: serializationManager
          .deserialize<List<String?>>(jsonSerialization['eachOutputAsset']),
      eachOutputAmount: serializationManager
          .deserialize<List<int>>(jsonSerialization['eachOutputAmount']),
    );
  }

  int? id;

  List<String> myH106s;

  List<String> myPubkeys;

  double? feeRateKb;

  List<String> eachOutputAddress;

  List<String?> eachOutputAsset;

  List<int> eachOutputAmount;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'myH106s': myH106s,
      'myPubkeys': myPubkeys,
      'feeRateKb': feeRateKb,
      'eachOutputAddress': eachOutputAddress,
      'eachOutputAsset': eachOutputAsset,
      'eachOutputAmount': eachOutputAmount,
    };
  }
}