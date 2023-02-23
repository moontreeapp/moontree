import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
// ignore: unused_import
import 'package:client_back/services/consent.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/presentation/services/services.dart' show sail;

Future<void> logout() async {
  pros.ciphers.clear();
  streams.app.setting.add(null);
  //streams.app.logout.add(true); // notify the login page not to auto-ask
  sail.to(getMethodPathLogin(),
      arguments: <String, bool>{'autoInitiateUnlock': false},
      replaceOverride: true);
  //streams.app.lead.add(LeadIcon.dismiss);
  streams.app.splash.add(false);
}

String getMethodPathLogin({bool? nativeSecurity}) =>
    nativeSecurity ?? pros.settings.authMethodIsNativeSecurity
        ? '/login/native'
        : '/login/password';

String getMethodPathCreate({bool? nativeSecurity}) =>
    nativeSecurity ?? pros.settings.authMethodIsNativeSecurity
        ? '/login/create/native'
        : '/login/create/password';
