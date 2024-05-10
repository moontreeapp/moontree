/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class AssetCreationRequest extends _i1.SerializableEntity {
  AssetCreationRequest({
    this.id,
    required this.myH106s,
    required this.myPubkeys,
    this.feeRateKb,
    this.changeSource,
    this.opReturnMemo,
    required this.assetType,
    required this.asset,
    this.parentAsset,
    this.divisibility,
    this.amount,
    required this.reissuable,
    this.associatedData,
    this.verifierString,
    this.lockedUtxos,
  });

  factory AssetCreationRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return AssetCreationRequest(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      myH106s: serializationManager
          .deserialize<List<String>>(jsonSerialization['myH106s']),
      myPubkeys: serializationManager
          .deserialize<List<String>>(jsonSerialization['myPubkeys']),
      feeRateKb: serializationManager
          .deserialize<double?>(jsonSerialization['feeRateKb']),
      changeSource: serializationManager
          .deserialize<String?>(jsonSerialization['changeSource']),
      opReturnMemo: serializationManager
          .deserialize<String?>(jsonSerialization['opReturnMemo']),
      assetType:
          serializationManager.deserialize<int>(jsonSerialization['assetType']),
      asset:
          serializationManager.deserialize<String>(jsonSerialization['asset']),
      parentAsset: serializationManager
          .deserialize<String?>(jsonSerialization['parentAsset']),
      divisibility: serializationManager
          .deserialize<int?>(jsonSerialization['divisibility']),
      amount:
          serializationManager.deserialize<int?>(jsonSerialization['amount']),
      reissuable: serializationManager
          .deserialize<bool>(jsonSerialization['reissuable']),
      associatedData: serializationManager
          .deserialize<String?>(jsonSerialization['associatedData']),
      verifierString: serializationManager
          .deserialize<String?>(jsonSerialization['verifierString']),
      lockedUtxos: serializationManager
          .deserialize<List<String>?>(jsonSerialization['lockedUtxos']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  List<String> myH106s;

  List<String> myPubkeys;

  double? feeRateKb;

  String? changeSource;

  String? opReturnMemo;

  int assetType;

  String asset;

  String? parentAsset;

  int? divisibility;

  int? amount;

  bool reissuable;

  String? associatedData;

  String? verifierString;

  List<String>? lockedUtxos;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'myH106s': myH106s,
      'myPubkeys': myPubkeys,
      'feeRateKb': feeRateKb,
      'changeSource': changeSource,
      'opReturnMemo': opReturnMemo,
      'assetType': assetType,
      'asset': asset,
      'parentAsset': parentAsset,
      'divisibility': divisibility,
      'amount': amount,
      'reissuable': reissuable,
      'associatedData': associatedData,
      'verifierString': verifierString,
      'lockedUtxos': lockedUtxos,
    };
  }
}
