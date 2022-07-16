/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: public_member_api_docs
// ignore_for_file: unused_import

import 'dart:io';
import 'dart:typed_data' as typed_data;
import 'package:serverpod_client/serverpod_client.dart';
import 'protocol.dart';

class _EndpointConsent extends EndpointRef {
  @override
  String get name => 'consent';

  _EndpointConsent(EndpointCaller caller) : super(caller);

  Future<String> given(
    String deviceId,
    String documentName,
  ) async {
    return await caller.callServerEndpoint('consent', 'given', 'String', {
      'deviceId': deviceId,
      'documentName': documentName,
    });
  }
}

class _EndpointHasGiven extends EndpointRef {
  @override
  String get name => 'hasGiven';

  _EndpointHasGiven(EndpointCaller caller) : super(caller);

  Future<bool> consent(
    String deviceId,
    String documentName,
  ) async {
    return await caller.callServerEndpoint('hasGiven', 'consent', 'bool', {
      'deviceId': deviceId,
      'documentName': documentName,
    });
  }
}

class _EndpointDocument extends EndpointRef {
  @override
  String get name => 'document';

  _EndpointDocument(EndpointCaller caller) : super(caller);

  Future<String> upload(
    String document,
    String documentName,
    String? documentVersion,
  ) async {
    return await caller.callServerEndpoint('document', 'upload', 'String', {
      'document': document,
      'documentName': documentName,
      'documentVersion': documentVersion,
    });
  }
}

class Client extends ServerpodClient {
  late final _EndpointConsent consent;
  late final _EndpointHasGiven hasGiven;
  late final _EndpointDocument document;

  Client(String host,
      {SecurityContext? context,
      ServerpodClientErrorCallback? errorHandler,
      AuthenticationKeyManager? authenticationKeyManager})
      : super(host, Protocol.instance,
            context: context,
            errorHandler: errorHandler,
            authenticationKeyManager: authenticationKeyManager) {
    consent = _EndpointConsent(this);
    hasGiven = _EndpointHasGiven(this);
    document = _EndpointDocument(this);
  }

  @override
  Map<String, EndpointRef> get endpointRefLookup => {
        'consent': consent,
        'hasGiven': hasGiven,
        'document': document,
      };

  @override
  Map<String, ModuleEndpointCaller> get moduleLookup => {};
}
