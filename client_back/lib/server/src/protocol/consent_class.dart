/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class Consent extends _i1.SerializableEntity {
  Consent({
    this.id,
    required this.deviceId,
    required this.documentName,
    required this.documentVersion,
    this.insertedAt,
  });

  factory Consent.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return Consent(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      deviceId: serializationManager
          .deserialize<String>(jsonSerialization['deviceId']),
      documentName: serializationManager
          .deserialize<String>(jsonSerialization['documentName']),
      documentVersion: serializationManager
          .deserialize<String>(jsonSerialization['documentVersion']),
      insertedAt: serializationManager
          .deserialize<DateTime?>(jsonSerialization['insertedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String deviceId;

  String documentName;

  String documentVersion;

  DateTime? insertedAt;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'documentName': documentName,
      'documentVersion': documentVersion,
      'insertedAt': insertedAt,
    };
  }
}
