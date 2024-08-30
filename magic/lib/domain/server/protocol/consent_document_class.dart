/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class ConsentDocument extends _i1.SerializableEntity {
  ConsentDocument({
    this.id,
    required this.document,
    required this.documentName,
    required this.documentVersion,
    this.insertedAt,
  });

  factory ConsentDocument.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return ConsentDocument(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      document: serializationManager
          .deserialize<String>(jsonSerialization['document']),
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

  String document;

  String documentName;

  String documentVersion;

  DateTime? insertedAt;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document': document,
      'documentName': documentName,
      'documentVersion': documentVersion,
      'insertedAt': insertedAt,
    };
  }
}
