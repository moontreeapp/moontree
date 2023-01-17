/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class UnsignedTransactionResult extends _i1.SerializableEntity {
  UnsignedTransactionResult({
    this.id,
    this.error,
    required this.rawHex,
    required this.vinPreimageHex,
    required this.vinPrivateKeySource,
  });

  factory UnsignedTransactionResult.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return UnsignedTransactionResult(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      error:
          serializationManager.deserialize<String?>(jsonSerialization['error']),
      rawHex:
          serializationManager.deserialize<String>(jsonSerialization['rawHex']),
      vinPreimageHex: serializationManager
          .deserialize<List<String>>(jsonSerialization['vinPreimageHex']),
      vinPrivateKeySource: serializationManager
          .deserialize<List<String>>(jsonSerialization['vinPrivateKeySource']),
    );
  }

  int? id;

  String? error;

  String rawHex;

  List<String> vinPreimageHex;

  List<String> vinPrivateKeySource;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'error': error,
      'rawHex': rawHex,
      'vinPreimageHex': vinPreimageHex,
      'vinPrivateKeySource': vinPrivateKeySource,
    };
  }
}
