import 'package:flutter/material.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;
import 'package:ravencoin_back/ravencoin_back.dart';

Future<void> preLogin() async {
  /// init ciphers takes 2 seconds don't encrypt anything so no need,
  /// however, everything expects a cipher to exist therefore,
  /// we'll create one as soon as the login page shows in the background.
  final key = await SecureStorage.authenticationKey;
  services.cipher.initCiphers(
    altPassword: key,
    altSalt: key,
  );
  await services.cipher.updateWallets();
  services.cipher.cleanupCiphers();
}

Future<void> login(BuildContext context) async {
  Navigator.pushReplacementNamed(
    context,
    '/home',
    arguments: {},
  );
  services.cipher.loginTime();
  streams.app.splash.add(false); // trigger to refresh app bar again
  streams.app.logout.add(false);
  streams.app.verify.add(true);
}
