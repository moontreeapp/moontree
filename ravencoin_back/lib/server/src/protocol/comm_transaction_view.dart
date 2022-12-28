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
    this.symbol,
    required this.chain,
    required this.hash,
    required this.datetime,
    required this.height,
    required this.iProvided,
    required this.otherProvided,
    required this.iReceived,
    required this.otherReceived,
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
  });

  factory TransactionView.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return TransactionView(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      symbol: serializationManager
          .deserialize<String?>(jsonSerialization['symbol']),
      chain:
          serializationManager.deserialize<String>(jsonSerialization['chain']),
      hash: serializationManager
          .deserialize<_i2.ByteData>(jsonSerialization['hash']),
      datetime: serializationManager
          .deserialize<DateTime>(jsonSerialization['datetime']),
      height:
          serializationManager.deserialize<int>(jsonSerialization['height']),
      iProvided:
          serializationManager.deserialize<int>(jsonSerialization['iProvided']),
      otherProvided: serializationManager
          .deserialize<int>(jsonSerialization['otherProvided']),
      iReceived:
          serializationManager.deserialize<int>(jsonSerialization['iReceived']),
      otherReceived: serializationManager
          .deserialize<int>(jsonSerialization['otherReceived']),
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
    );
  }

  int? id;

  String? symbol;

  String chain;

  _i2.ByteData hash;

  DateTime datetime;

  int height;

  int iProvided;

  int otherProvided;

  int iReceived;

  int otherReceived;

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

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'chain': chain,
      'hash': hash,
      'datetime': datetime,
      'height': height,
      'iProvided': iProvided,
      'otherProvided': otherProvided,
      'iReceived': iReceived,
      'otherReceived': otherReceived,
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
    };
  }
}
