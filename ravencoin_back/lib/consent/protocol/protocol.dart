/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

library protocol; // ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'consent_class.dart' as _i2;
import 'consent_document_class.dart' as _i3;
export 'consent_class.dart';
export 'consent_document_class.dart';
export 'client.dart'; // ignore_for_file: equal_keys_in_map

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Map<Type, _i1.constructor> customConstructors = {};

  static final Protocol _instance = Protocol._();

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (customConstructors.containsKey(t)) {
      return customConstructors[t]!(data, this) as T;
    }
    if (t == _i2.Consent) {
      return _i2.Consent.fromJson(data, this) as T;
    }
    if (t == _i3.ConsentDocument) {
      return _i3.ConsentDocument.fromJson(data, this) as T;
    }
    if (t == _i1.getType<_i2.Consent?>()) {
      return (data != null ? _i2.Consent.fromJson(data, this) : null) as T;
    }
    if (t == _i1.getType<_i3.ConsentDocument?>()) {
      return (data != null ? _i3.ConsentDocument.fromJson(data, this) : null)
          as T;
    }
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object data) {
    if (data is _i2.Consent) {
      return 'Consent';
    }
    if (data is _i3.ConsentDocument) {
      return 'ConsentDocument';
    }
    return super.getClassNameForObject(data);
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    if (data['className'] == 'Consent') {
      return deserialize<_i2.Consent>(data['data']);
    }
    if (data['className'] == 'ConsentDocument') {
      return deserialize<_i3.ConsentDocument>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
