import 'package:client_front/infrastructure/calls/subscription.dart';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:client_front/infrastructure/services/storage.dart'
    show SecureStorage;
import 'package:client_front/presentation/services/services.dart' show sail;

Future<void> login(
  BuildContext context, {
  String? password,
  String? key,
}) async {
  key ??= await SecureStorage.authenticationKey;
  services.cipher.initCiphers(
    altPassword: password ?? key,
    altSalt: key, // should salt with password, see create_password.dart
  );
  await services.cipher.updateWallets();
  services.cipher.cleanupCiphers();
  services.cipher.loginTime();
  streams.app.loc.splash.add(false); // trigger to refresh app bar again
  streams.app.auth.logout.add(false);
  streams.app.auth.verify.add(true);

  // setup subscription on moontree client for this wallet
  await setupSubscription(wallet: Current.wallet);

  // go to home
  postLogin(context);

  /// here we can put logic to migrate database on new version or something:
  //services.version.snapshot?.currentBuild == '17' &&
  //(services.version.snapshot?.buildUpdated ?? false);
}

void postLogin(BuildContext context) {
  if (Current.wallet is LeaderWallet && !Current.wallet.backedUp) {
    sail.to('/wallet/holdings', replaceOverride: true);
    sail.to('/backup/intro', arguments: <String, bool>{'fadeIn': true});
  } else {
    sail.to('/wallet/holdings', replaceOverride: true);
  }
}
