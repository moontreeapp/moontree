/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class AssetAddressTagRequest extends _i1.SerializableEntity {
  AssetAddressTagRequest({
    this.id,
    required this.myH106s,
    required this.myPubkeys,
    this.feeRateKb,
    this.changeSource,
    this.opReturnMemo,
    required this.asset,
    required this.address,
    required this.flag,
    this.lockedUtxos,
  });

  factory AssetAddressTagRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return AssetAddressTagRequest(
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
      asset:
          serializationManager.deserialize<String>(jsonSerialization['asset']),
      address: serializationManager
          .deserialize<String>(jsonSerialization['address']),
      flag: serializationManager.deserialize<bool>(jsonSerialization['flag']),
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

  String asset;

  String address;

  bool flag;

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
      'asset': asset,
      'address': address,
      'flag': flag,
      'lockedUtxos': lockedUtxos,
    };
  }
}
