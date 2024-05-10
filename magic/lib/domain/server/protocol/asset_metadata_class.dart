/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:typed_data' as _i2;

class AssetMetadata extends _i1.SerializableEntity {
  AssetMetadata({
    this.id,
    required this.reissuable,
    required this.totalSupply,
    required this.divisibility,
    this.associatedData,
    required this.frozen,
    this.verifierStringVoutId,
    required this.voutId,
  });

  factory AssetMetadata.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return AssetMetadata(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      reissuable: serializationManager
          .deserialize<bool>(jsonSerialization['reissuable']),
      totalSupply: serializationManager
          .deserialize<int>(jsonSerialization['totalSupply']),
      divisibility: serializationManager
          .deserialize<int>(jsonSerialization['divisibility']),
      associatedData: serializationManager
          .deserialize<_i2.ByteData?>(jsonSerialization['associatedData']),
      frozen:
          serializationManager.deserialize<bool>(jsonSerialization['frozen']),
      verifierStringVoutId: serializationManager
          .deserialize<int?>(jsonSerialization['verifierStringVoutId']),
      voutId:
          serializationManager.deserialize<int>(jsonSerialization['voutId']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  bool reissuable;

  int totalSupply;

  int divisibility;

  _i2.ByteData? associatedData;

  bool frozen;

  int? verifierStringVoutId;

  int voutId;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reissuable': reissuable,
      'totalSupply': totalSupply,
      'divisibility': divisibility,
      'associatedData': associatedData,
      'frozen': frozen,
      'verifierStringVoutId': verifierStringVoutId,
      'voutId': voutId,
    };
  }
}
