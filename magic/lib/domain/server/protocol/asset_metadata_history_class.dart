/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class AssetMetadataHistory extends _i1.SerializableEntity {
  AssetMetadataHistory({
    this.id,
    required this.assetId,
    required this.assetMetadataId,
    required this.height,
    required this.chainId,
  });

  factory AssetMetadataHistory.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return AssetMetadataHistory(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      assetId:
          serializationManager.deserialize<int>(jsonSerialization['assetId']),
      assetMetadataId: serializationManager
          .deserialize<int>(jsonSerialization['assetMetadataId']),
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

  int assetId;

  int assetMetadataId;

  int height;

  int chainId;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'assetMetadataId': assetMetadataId,
      'height': height,
      'chainId': chainId,
    };
  }
}
