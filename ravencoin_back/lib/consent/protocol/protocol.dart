/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: public_member_api_docs
// ignore_for_file: unnecessary_import

library protocol;

// ignore: unused_import
import 'dart:typed_data';
import 'package:serverpod_client/serverpod_client.dart';

import 'consent_class.dart';
import 'consent_document_class.dart';

export 'consent_class.dart';
export 'consent_document_class.dart';
export 'client.dart';

class Protocol extends SerializationManager {
  static final Protocol instance = Protocol();

  final Map<String, constructor> _constructors = {};
  @override
  Map<String, constructor> get constructors => _constructors;

  Protocol() {
    constructors['Consent'] = (Map<String, dynamic> serialization) =>
        Consent.fromSerialization(serialization);
    constructors['ConsentDocument'] = (Map<String, dynamic> serialization) =>
        ConsentDocument.fromSerialization(serialization);
  }
}
