/// this is for testing purposes only

import 'dart:io';
import 'package:raven_back/raven_back.dart';
import 'package:reservoir/reservoir.dart';

Future deleteDatabase() async {
  services.wallet.leader.indexRegistry.clear();
  services.download.history.downloadedOrDownloadQueried.clear();
  services.client.subscribe.subscriptionHandles.clear();
  try {
    await res.addresses.clear();
    await res.assets.clear();
    await res.balances.clear();
    await res.blocks.clear();
    await res.metadatas.clear();
    await res.notes.clear();
    await res.passwords.clear();
    await res.rates.clear();
    await res.securities.clear();
    await res.settings.clear();
    await res.statuses.clear();
    await res.transactions.clear();
    await res.vins.clear();
    await res.vouts.clear();
    await res.wallets.clear();
  } catch (e) {
    print('clearing failed');
  }
  try {
    await (res.addresses.source as HiveSource).box.clear();
    await (res.assets.source as HiveSource).box.clear();
    await (res.balances.source as HiveSource).box.clear();
    await (res.blocks.source as HiveSource).box.clear();
    await (res.metadatas.source as HiveSource).box.clear();
    await (res.notes.source as HiveSource).box.clear();
    await (res.passwords.source as HiveSource).box.clear();
    await (res.rates.source as HiveSource).box.clear();
    await (res.securities.source as HiveSource).box.clear();
    await (res.settings.source as HiveSource).box.clear();
    await (res.statuses.source as HiveSource).box.clear();
    await (res.transactions.source as HiveSource).box.clear();
    await (res.vins.source as HiveSource).box.clear();
    await (res.vouts.source as HiveSource).box.clear();
    await (res.wallets.source as HiveSource).box.clear();
    //await (res.ciphers.source as MapSource).clear();
  } catch (e) {
    print('box clearing failed');
  }
  try {
    await Directory('database').delete(recursive: true);
  } catch (e) {
    print('database folder not found');
  }
}
