import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;

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
  //streams.app.triggers.add(ThresholdTrigger.backup);
  streams.app.context.add(AppContext.wallet);
  streams.app.splash.add(false); // trigger to refresh app bar again
  streams.app.logout.add(false);
  streams.app.verify.add(true);
  //streams.app.lead.add(LeadIcon.menu);
  postLogin(context);

  /// here we can put logic to migrate database on new version or something:
  //services.version.snapshot?.currentBuild == '17' &&
  //(services.version.snapshot?.buildUpdated ?? false);
}

void postLogin(BuildContext context) {
  if (Current.wallet is LeaderWallet &&
      //streams.app.triggers.value == ThresholdTrigger.backup &&
      !Current.wallet.backedUp) {
    Navigator.pushReplacementNamed(context, '/home',
        arguments: <dynamic, dynamic>{});
    Navigator.of(context).pushNamed(
      '/security/backup/backupintro',
      arguments: <String, bool>{'fadeIn': true},
    );
  } else {
    Navigator.pushReplacementNamed(context, '/home',
        arguments: <dynamic, dynamic>{});
  }
}
