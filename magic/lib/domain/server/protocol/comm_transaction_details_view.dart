/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:typed_data' as _i2;

class TransactionDetailsView extends _i1.SerializableEntity {
  TransactionDetailsView({
    this.id,
    this.error,
    this.memo,
    this.containsAssets,
  });

  factory TransactionDetailsView.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return TransactionDetailsView(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      error:
          serializationManager.deserialize<String?>(jsonSerialization['error']),
      memo: serializationManager
          .deserialize<_i2.ByteData?>(jsonSerialization['memo']),
      containsAssets: serializationManager
          .deserialize<String?>(jsonSerialization['containsAssets']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String? error;

  _i2.ByteData? memo;

  String? containsAssets;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'error': error,
      'memo': memo,
      'containsAssets': containsAssets,
    };
  }
}
