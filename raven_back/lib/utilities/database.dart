/// this is for testing purposes only

import 'dart:io';
import 'package:raven_back/raven_back.dart';
import 'package:reservoir/reservoir.dart';

Future deleteDatabase() async {
  services.wallet.leader.indexRegistry.clear();
  services.download.history.downloaded.clear();
  services.client.subscribe.subscriptionHandles.clear();
  try {
    await res.addresses.clear();
    await res.balances.clear();
    await res.rates.clear();
    await res.securities.clear();
    await res.settings.clear();
    await res.transactions.clear();
    await res.wallets.clear();
    await res.vins.clear();
    await res.vouts.clear();
  } catch (e) {
    print('clearing failed');
  }
  try {
    await (res.wallets.source as HiveSource).box.clear();
    await (res.addresses.source as HiveSource).box.clear();
    await (res.securities.source as HiveSource).box.clear();
    await (res.transactions.source as HiveSource).box.clear();
    await (res.vins.source as HiveSource).box.clear();
    await (res.vouts.source as HiveSource).box.clear();
    await (res.rates.source as HiveSource).box.clear();
    await (res.balances.source as HiveSource).box.clear();
    await (res.settings.source as HiveSource).box.clear();
  } catch (e) {
    print('box clearing failed');
  }
  try {
    await Directory('database').delete(recursive: true);
  } catch (e) {
    print('database folder not found');
  }
}
