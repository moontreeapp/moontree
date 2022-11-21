import 'package:flutter/material.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;
import 'package:ravencoin_back/ravencoin_back.dart';

Future<void> login(BuildContext context) async {
  final key = await SecureStorage.authenticationKey;
  services.cipher.initCiphers(altPassword: key, altSalt: key);
  await services.cipher.updateWallets();
  services.cipher.cleanupCiphers();
  services.cipher.loginTime();
  streams.app.triggers.add(ThresholdTrigger.backup);
  streams.app.context.add(AppContext.wallet);
  streams.app.splash.add(false); // trigger to refresh app bar again
  streams.app.logout.add(false);
  streams.app.verify.add(true);

  if (Current.wallet is LeaderWallet &&
      streams.app.triggers.value == ThresholdTrigger.backup &&
      !Current.wallet.backedUp) {
    streams.app.lead.add(LeadIcon.none);
    Navigator.pushReplacementNamed(context, '/home', arguments: {});
    Navigator.of(context).pushNamed(
      '/security/backup',
      arguments: {'fadeIn': true},
    );
  } else {
    Navigator.pushReplacementNamed(context, '/home', arguments: {});
  }

  /// here we can put logic to migrate database on new version or something:
  //services.version.snapshot?.currentBuild == '17' &&
  //(services.version.snapshot?.buildUpdated ?? false);
}
