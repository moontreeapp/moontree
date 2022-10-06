/// this is for testing purposes only

import 'dart:io';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:proclaim/proclaim.dart';

/// erases data concerning transactions and the like, leaves assets alone.
Future eraseChainData() async {
  await pros.blocks.removeAll(pros.blocks.records);
  await pros.statuses.removeAll(pros.statuses.records);
  //await pros.balances.removeAll(pros.balances.records);
  //await pros.addresses.removeAll(pros.addresses.records);
  await pros.unspents.removeAll(pros.unspents.records);
  await pros.vouts.removeAll(pros.vouts.records);
  await pros.vins.removeAll(pros.vins.records);
  await pros.transactions.removeAll(pros.transactions.records);
}

Future eraseDerivedData({bool keepBalances = false}) async {
  if (!keepBalances) {
    await pros.balances.removeAll(pros.balances.records);
  }
  await pros.addresses.removeAll(pros.addresses.records);
}

void resetInMemoryState() {
  services.client.subscribe.unsubscribeAddressesAll();
  services.client.subscribe.unsubscribeAssetsAll();
  services.client.subscribe.subscriptionHandlesAddress.clear();
  services.client.subscribe.subscriptionHandlesAsset.clear();
  services.download.overrideGettingStarted = false;
  services.download.history.calledAllDoneProcess = 0;
  services.download.queue.addresses.clear();
  services.download.queue.transactions.clear();
  services.download.queue.dangling.clear();
  services.download.queue.updated = false;
  services.download.queue.address = null;
  services.download.queue.transactionSet = null;
}

Future deleteDatabase() async {
  resetInMemoryState();
  try {
    await pros.addresses.clear();
    await pros.assets.clear();
    await pros.balances.clear();
    await pros.blocks.clear();
    await pros.ciphers.clear();
    await pros.metadatas.clear();
    await pros.notes.clear();
    await pros.passwords.clear();
    await pros.rates.clear();
    await pros.securities.clear();
    await pros.settings.clear();
    await pros.statuses.clear();
    await pros.transactions.clear();
    await pros.unspents.clear();
    await pros.vins.clear();
    await pros.vouts.clear();
    await pros.wallets.clear();
  } catch (e) {
    print('clearing failed');
  }
  try {
    await (pros.addresses.source as HiveSource).box.clear();
    await (pros.assets.source as HiveSource).box.clear();
    await (pros.balances.source as HiveSource).box.clear();
    await (pros.blocks.source as HiveSource).box.clear();
    await (pros.metadatas.source as HiveSource).box.clear();
    await (pros.notes.source as HiveSource).box.clear();
    await (pros.passwords.source as HiveSource).box.clear();
    await (pros.rates.source as HiveSource).box.clear();
    await (pros.securities.source as HiveSource).box.clear();
    await (pros.settings.source as HiveSource).box.clear();
    await (pros.statuses.source as HiveSource).box.clear();
    await (pros.transactions.source as HiveSource).box.clear();
    await (pros.vins.source as HiveSource).box.clear();
    await (pros.vouts.source as HiveSource).box.clear();
    await (pros.wallets.source as HiveSource).box.clear();
    //await (pros.ciphers.source as MapSource).clear();
    //await (pros.unspents.source as MapSource).clear();
  } catch (e) {
    print('box clearing failed');
  }
  try {
    await Directory('database').delete(recursive: true);
  } catch (e) {
    print('database folder not found');
  }
}
