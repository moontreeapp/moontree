/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:typed_data' as _i2;

class H160 extends _i1.SerializableEntity {
  H160({
    this.id,
    required this.h160,
    this.walletId,
    this.index,
  });

  factory H160.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return H160(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      h160: serializationManager
          .deserialize<_i2.ByteData>(jsonSerialization['h160']),
      walletId:
          serializationManager.deserialize<int?>(jsonSerialization['walletId']),
      index: serializationManager.deserialize<int?>(jsonSerialization['index']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i2.ByteData h160;

  int? walletId;

  int? index;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'h160': h160,
      'walletId': walletId,
      'index': index,
    };
  }
}
