/// this is for testing purposes only

import 'dart:io';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:proclaim/proclaim.dart';

/// erases data concerning transactions and the like, leaves assets alone.
Future<void> eraseTransactionData({
  bool quick = false,
  bool keepBalances = false,
}) async {
  await pros.blocks.removeAll(pros.blocks.records);
  if (quick) {
    await pros.vouts.delete();
    await pros.vins.delete();
    await pros.transactions.delete();
    //await pros.blocks.delete();
  } else {
    await pros.vouts.clear();
    await pros.vins.clear();
    await pros.transactions.clear();
    //await pros.blocks.clear();
  }
}

Future<void> eraseUnspentData({
  bool quick = false,
  bool keepBalances = false,
}) async {
  if (quick) {
    await pros.statuses.delete();
    await pros.unspents.delete();
    if (!keepBalances) {
      await pros.balances.delete();
    }
  } else {
    await pros.statuses.clear();
    await pros.unspents.clear();
    if (!keepBalances) {
      await pros.balances.clear();
    }
  }
}

Future<void> eraseAddressData({bool quick = false}) async {
  if (quick) {
    await pros.addresses.delete();
  } else {
    await pros.addresses.clear();
  }
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
