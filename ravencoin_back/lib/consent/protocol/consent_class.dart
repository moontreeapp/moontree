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

class Consent extends SerializableEntity {
  @override
  String get className => 'Consent';

  int? id;
  late String device_id;
  late String document_name;
  late String document_version;

  Consent({
    this.id,
    required this.device_id,
    required this.document_name,
    required this.document_version,
  });

  Consent.fromSerialization(Map<String, dynamic> serialization) {
    var _data = unwrapSerializationData(serialization);
    id = _data['id'];
    device_id = _data['device_id']!;
    document_name = _data['document_name']!;
    document_version = _data['document_version']!;
  }

  @override
  Map<String, dynamic> serialize() {
    return wrapSerializationData({
      'id': id,
      'device_id': device_id,
      'document_name': document_name,
      'document_version': document_version,
    });
  }
}
