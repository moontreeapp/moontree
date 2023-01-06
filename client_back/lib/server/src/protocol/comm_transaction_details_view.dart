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
    this.memo,
    required this.containsAssets,
  });

  factory TransactionDetailsView.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return TransactionDetailsView(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      memo: serializationManager
          .deserialize<_i2.ByteData?>(jsonSerialization['memo']),
      containsAssets: serializationManager
          .deserialize<bool>(jsonSerialization['containsAssets']),
    );
  }

  int? id;

  _i2.ByteData? memo;

  bool containsAssets;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memo': memo,
      'containsAssets': containsAssets,
    };
  }
}
