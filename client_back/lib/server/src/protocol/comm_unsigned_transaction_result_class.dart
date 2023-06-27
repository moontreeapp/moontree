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
    required this.vinAssets,
    required this.vinAmounts,
    required this.vinPrivateKeySource,
    required this.vinLockingScriptType,
    required this.vinScriptOverride,
    required this.changeSource,
    required this.targetFee,
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
      vinAssets: serializationManager
          .deserialize<List<String?>>(jsonSerialization['vinAssets']),
      vinAmounts: serializationManager
          .deserialize<List<int>>(jsonSerialization['vinAmounts']),
      vinPrivateKeySource: serializationManager
          .deserialize<List<String?>>(jsonSerialization['vinPrivateKeySource']),
      vinLockingScriptType: serializationManager
          .deserialize<List<int>>(jsonSerialization['vinLockingScriptType']),
      vinScriptOverride: serializationManager
          .deserialize<List<String?>>(jsonSerialization['vinScriptOverride']),
      changeSource: serializationManager
          .deserialize<List<String?>>(jsonSerialization['changeSource']),
      targetFee:
          serializationManager.deserialize<int>(jsonSerialization['targetFee']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String? error;

  String rawHex;

  List<String?> vinAssets;

  List<int> vinAmounts;

  List<String?> vinPrivateKeySource;

  List<int> vinLockingScriptType;

  List<String?> vinScriptOverride;

  List<String?> changeSource;

  int targetFee;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'error': error,
      'rawHex': rawHex,
      'vinAssets': vinAssets,
      'vinAmounts': vinAmounts,
      'vinPrivateKeySource': vinPrivateKeySource,
      'vinLockingScriptType': vinLockingScriptType,
      'vinScriptOverride': vinScriptOverride,
      'changeSource': changeSource,
      'targetFee': targetFee,
    };
  }
}
