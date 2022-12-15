/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i2;
import 'dart:io' as _i3;
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'protocol.dart' as _i4;

class _EndpointConsent extends _i1.EndpointRef {
  _EndpointConsent(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'consent';

  _i2.Future<String> given(
    String deviceId,
    String documentName,
  ) =>
      caller.callServerEndpoint<String>(
        'consent',
        'given',
        <String, dynamic>{
          'deviceId': deviceId,
          'documentName': documentName,
        },
      );
}

class _EndpointHasGiven extends _i1.EndpointRef {
  _EndpointHasGiven(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'hasGiven';

  _i2.Future<bool> consent(
    String deviceId,
    String documentName,
  ) =>
      caller.callServerEndpoint<bool>(
        'hasGiven',
        'consent',
        <String, dynamic>{
          'deviceId': deviceId,
          'documentName': documentName,
        },
      );
}

class _EndpointDocument extends _i1.EndpointRef {
  _EndpointDocument(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'document';

  _i2.Future<String> upload(
    String document,
    String documentName,
    String? documentVersion,
  ) =>
      caller.callServerEndpoint<String>(
        'document',
        'upload',
        <String, dynamic>{
          'document': document,
          'documentName': documentName,
          'documentVersion': documentVersion,
        },
      );
}

class Client extends _i1.ServerpodClient {
  Client(
    String host, {
    _i3.SecurityContext? context,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
  }) : super(
          host,
          _i4.Protocol(),
          context: context,
          authenticationKeyManager: authenticationKeyManager,
        ) {
    consent = _EndpointConsent(this);
    hasGiven = _EndpointHasGiven(this);
    document = _EndpointDocument(this);
  }

  late final _EndpointConsent consent;

  late final _EndpointHasGiven hasGiven;

  late final _EndpointDocument document;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup =>
      <String, _i1.EndpointRef>{
        'consent': consent,
        'hasGiven': hasGiven,
        'document': document,
      };
  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup =>
      <String, _i1.ModuleEndpointCaller>{};
}
