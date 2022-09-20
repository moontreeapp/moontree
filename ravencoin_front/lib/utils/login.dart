import 'package:flutter/material.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;
import 'package:ravencoin_back/ravencoin_back.dart';

Future<void> login(BuildContext context) async {
  Navigator.pushReplacementNamed(
    context,
    '/home',
    arguments: {},
  );
  final key = await SecureStorage.authenticationKey;
  services.cipher.initCiphers(
    altPassword: key,
    altSalt: key,
  );
  await services.cipher.updateWallets();
  services.cipher.cleanupCiphers();
  services.cipher.loginTime();
  streams.app.splash.add(false); // trigger to refresh app bar again
  streams.app.logout.add(false);
  streams.app.verify.add(true);
}
