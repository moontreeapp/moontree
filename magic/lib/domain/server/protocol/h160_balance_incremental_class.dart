/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class AddressBalanceIncremental extends _i1.SerializableEntity {
  AddressBalanceIncremental({
    this.id,
    required this.h160Id,
    this.assetId,
    required this.sats,
    required this.height,
    required this.chainId,
  });

  factory AddressBalanceIncremental.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return AddressBalanceIncremental(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      h160Id:
          serializationManager.deserialize<int>(jsonSerialization['h160Id']),
      assetId:
          serializationManager.deserialize<int?>(jsonSerialization['assetId']),
      sats: serializationManager.deserialize<int>(jsonSerialization['sats']),
      height:
          serializationManager.deserialize<int>(jsonSerialization['height']),
      chainId:
          serializationManager.deserialize<int>(jsonSerialization['chainId']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int h160Id;

  int? assetId;

  int sats;

  int height;

  int chainId;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'h160Id': h160Id,
      'assetId': assetId,
      'sats': sats,
      'height': height,
      'chainId': chainId,
    };
  }
}
