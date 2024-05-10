/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:typed_data' as _i2;

class AssetMetadataResponse extends _i1.SerializableEntity {
  AssetMetadataResponse({
    this.id,
    this.error,
    required this.reissuable,
    required this.totalSupply,
    required this.divisibility,
    required this.frozen,
    this.associatedData,
    this.verifierString,
    this.mempoolReissuable,
    this.mempoolTotalSupply,
    this.mempoolDivisibility,
    this.mempoolFrozen,
    this.mempoolAssociatedData,
    this.mempoolVerifierString,
  });

  factory AssetMetadataResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return AssetMetadataResponse(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      error:
          serializationManager.deserialize<String?>(jsonSerialization['error']),
      reissuable: serializationManager
          .deserialize<bool>(jsonSerialization['reissuable']),
      totalSupply: serializationManager
          .deserialize<int>(jsonSerialization['totalSupply']),
      divisibility: serializationManager
          .deserialize<int>(jsonSerialization['divisibility']),
      frozen:
          serializationManager.deserialize<bool>(jsonSerialization['frozen']),
      associatedData: serializationManager
          .deserialize<_i2.ByteData?>(jsonSerialization['associatedData']),
      verifierString: serializationManager
          .deserialize<String?>(jsonSerialization['verifierString']),
      mempoolReissuable: serializationManager
          .deserialize<bool?>(jsonSerialization['mempoolReissuable']),
      mempoolTotalSupply: serializationManager
          .deserialize<int?>(jsonSerialization['mempoolTotalSupply']),
      mempoolDivisibility: serializationManager
          .deserialize<int?>(jsonSerialization['mempoolDivisibility']),
      mempoolFrozen: serializationManager
          .deserialize<bool?>(jsonSerialization['mempoolFrozen']),
      mempoolAssociatedData: serializationManager.deserialize<_i2.ByteData?>(
          jsonSerialization['mempoolAssociatedData']),
      mempoolVerifierString: serializationManager
          .deserialize<String?>(jsonSerialization['mempoolVerifierString']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String? error;

  bool reissuable;

  int totalSupply;

  int divisibility;

  bool frozen;

  _i2.ByteData? associatedData;

  String? verifierString;

  bool? mempoolReissuable;

  int? mempoolTotalSupply;

  int? mempoolDivisibility;

  bool? mempoolFrozen;

  _i2.ByteData? mempoolAssociatedData;

  String? mempoolVerifierString;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'error': error,
      'reissuable': reissuable,
      'totalSupply': totalSupply,
      'divisibility': divisibility,
      'frozen': frozen,
      'associatedData': associatedData,
      'verifierString': verifierString,
      'mempoolReissuable': mempoolReissuable,
      'mempoolTotalSupply': mempoolTotalSupply,
      'mempoolDivisibility': mempoolDivisibility,
      'mempoolFrozen': mempoolFrozen,
      'mempoolAssociatedData': mempoolAssociatedData,
      'mempoolVerifierString': mempoolVerifierString,
    };
  }
}
