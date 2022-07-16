/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: unused_import
// ignore_for_file: unnecessary_import
// ignore_for_file: overridden_fields

import 'package:serverpod_client/serverpod_client.dart';
import 'dart:typed_data';
import 'protocol.dart';

class ConsentDocument extends SerializableEntity {
  @override
  String get className => 'ConsentDocument';

  int? id;
  late String document;
  late String document_name;
  late String document_version;

  ConsentDocument({
    this.id,
    required this.document,
    required this.document_name,
    required this.document_version,
  });

  ConsentDocument.fromSerialization(Map<String, dynamic> serialization) {
    var _data = unwrapSerializationData(serialization);
    id = _data['id'];
    document = _data['document']!;
    document_name = _data['document_name']!;
    document_version = _data['document_version']!;
  }

  @override
  Map<String, dynamic> serialize() {
    return wrapSerializationData({
      'id': id,
      'document': document,
      'document_name': document_name,
      'document_version': document_version,
    });
  }
}
