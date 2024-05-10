/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class TransctionAssetLink extends _i1.SerializableEntity {
  TransctionAssetLink({
    this.id,
    required this.transactionId,
    required this.assetId,
  });

  factory TransctionAssetLink.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return TransctionAssetLink(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      transactionId: serializationManager
          .deserialize<int>(jsonSerialization['transactionId']),
      assetId:
          serializationManager.deserialize<int>(jsonSerialization['assetId']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int transactionId;

  int assetId;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'assetId': assetId,
    };
  }
}
