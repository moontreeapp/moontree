import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
// ignore: unused_import
import 'package:client_back/services/consent.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

Future<void> logout() async {
  pros.ciphers.clear();
  streams.app.setting.add(null);
  //streams.app.logout.add(true); // notify the login page not to auto-ask
  Navigator.pushReplacementNamed(
      components.routes.routeContext!, getMethodPathLogin(),
      arguments: <String, bool>{'autoInitiateUnlock': false});
  //streams.app.lead.add(LeadIcon.dismiss);
  streams.app.splash.add(false);
}

String getMethodPathLogin({bool? nativeSecurity}) =>
    nativeSecurity ?? pros.settings.authMethodIsNativeSecurity
        ? '/security/native/login'
        : '/security/password/login';

String getMethodPathCreate({bool? nativeSecurity}) =>
    nativeSecurity ?? pros.settings.authMethodIsNativeSecurity
        ? '/security/native/createlogin'
        : '/security/password/createlogin';
