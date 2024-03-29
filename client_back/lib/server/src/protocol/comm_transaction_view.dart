/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:typed_data' as _i2;

class TransactionView extends _i1.SerializableEntity {
  TransactionView({
    this.id,
    this.error,
    required this.hash,
    required this.datetime,
    required this.fee,
    required this.vsize,
    required this.height,
    required this.containsAssets,
    required this.consolidation,
    required this.iProvided,
    required this.iReceived,
    required this.issueMainBurned,
    required this.reissueBurned,
    required this.issueSubBurned,
    required this.issueUniqueBurned,
    required this.issueMessageBurned,
    required this.issueQualifierBurned,
    required this.issueSubQualifierBurned,
    required this.issueRestrictedBurned,
    required this.addTagBurned,
    required this.burnBurned,
    this.chain,
    this.symbol,
  });

  factory TransactionView.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return TransactionView(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      error:
          serializationManager.deserialize<String?>(jsonSerialization['error']),
      hash: serializationManager
          .deserialize<_i2.ByteData>(jsonSerialization['hash']),
      datetime: serializationManager
          .deserialize<DateTime>(jsonSerialization['datetime']),
      fee: serializationManager.deserialize<int>(jsonSerialization['fee']),
      vsize: serializationManager.deserialize<int>(jsonSerialization['vsize']),
      height:
          serializationManager.deserialize<int>(jsonSerialization['height']),
      containsAssets: serializationManager
          .deserialize<bool>(jsonSerialization['containsAssets']),
      consolidation: serializationManager
          .deserialize<bool>(jsonSerialization['consolidation']),
      iProvided:
          serializationManager.deserialize<int>(jsonSerialization['iProvided']),
      iReceived:
          serializationManager.deserialize<int>(jsonSerialization['iReceived']),
      issueMainBurned: serializationManager
          .deserialize<int>(jsonSerialization['issueMainBurned']),
      reissueBurned: serializationManager
          .deserialize<int>(jsonSerialization['reissueBurned']),
      issueSubBurned: serializationManager
          .deserialize<int>(jsonSerialization['issueSubBurned']),
      issueUniqueBurned: serializationManager
          .deserialize<int>(jsonSerialization['issueUniqueBurned']),
      issueMessageBurned: serializationManager
          .deserialize<int>(jsonSerialization['issueMessageBurned']),
      issueQualifierBurned: serializationManager
          .deserialize<int>(jsonSerialization['issueQualifierBurned']),
      issueSubQualifierBurned: serializationManager
          .deserialize<int>(jsonSerialization['issueSubQualifierBurned']),
      issueRestrictedBurned: serializationManager
          .deserialize<int>(jsonSerialization['issueRestrictedBurned']),
      addTagBurned: serializationManager
          .deserialize<int>(jsonSerialization['addTagBurned']),
      burnBurned: serializationManager
          .deserialize<int>(jsonSerialization['burnBurned']),
      chain:
          serializationManager.deserialize<String?>(jsonSerialization['chain']),
      symbol: serializationManager
          .deserialize<String?>(jsonSerialization['symbol']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String? error;

  _i2.ByteData hash;

  DateTime datetime;

  int fee;

  int vsize;

  int height;

  bool containsAssets;

  bool consolidation;

  int iProvided;

  int iReceived;

  int issueMainBurned;

  int reissueBurned;

  int issueSubBurned;

  int issueUniqueBurned;

  int issueMessageBurned;

  int issueQualifierBurned;

  int issueSubQualifierBurned;

  int issueRestrictedBurned;

  int addTagBurned;

  int burnBurned;

  String? chain;

  String? symbol;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'error': error,
      'hash': hash,
      'datetime': datetime,
      'fee': fee,
      'vsize': vsize,
      'height': height,
      'containsAssets': containsAssets,
      'consolidation': consolidation,
      'iProvided': iProvided,
      'iReceived': iReceived,
      'issueMainBurned': issueMainBurned,
      'reissueBurned': reissueBurned,
      'issueSubBurned': issueSubBurned,
      'issueUniqueBurned': issueUniqueBurned,
      'issueMessageBurned': issueMessageBurned,
      'issueQualifierBurned': issueQualifierBurned,
      'issueSubQualifierBurned': issueSubQualifierBurned,
      'issueRestrictedBurned': issueRestrictedBurned,
      'addTagBurned': addTagBurned,
      'burnBurned': burnBurned,
      'chain': chain,
      'symbol': symbol,
    };
  }
}
