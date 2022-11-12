import 'package:flutter/material.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;
import 'package:ravencoin_back/ravencoin_back.dart';

Future<void> login(BuildContext context) async {
  Navigator.pushReplacementNamed(context, '/home', arguments: {});
  final key = await SecureStorage.authenticationKey;
  services.cipher.initCiphers(altPassword: key, altSalt: key);
  await services.cipher.updateWallets();
  services.cipher.cleanupCiphers();
  services.cipher.loginTime();
  streams.app.context.add(AppContext.wallet);
  streams.app.splash.add(false); // trigger to refresh app bar again
  streams.app.logout.add(false);
  streams.app.verify.add(true);

  /// here we can put logic to migrate database on new version or something:
  //services.version.snapshot?.currentBuild == '17' &&
  //(services.version.snapshot?.buildUpdated ?? false);
}
