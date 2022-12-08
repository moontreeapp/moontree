import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
// ignore: unused_import
import 'package:ravencoin_back/services/consent.dart';
import 'package:ravencoin_front/components/components.dart';

Future<void> logout() async {
  pros.ciphers.clear();
  streams.app.setting.add(null);
  //streams.app.logout.add(true); // notify the login page not to auto-ask
  Navigator.pushReplacementNamed(
      components.navigator.routeContext!, getMethodPathLogin(),
      arguments: <String, bool>{'autoInitiateUnlock': false});
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
