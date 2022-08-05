/// this is for testing purposes only

import 'dart:io';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:proclaim/proclaim.dart';

Future deleteDatabase() async {
  services.wallet.leader.registry.indexRegistry.clear();
  await services.download.history.clearDownloadState();
  services.client.subscribe.subscriptionHandlesAddress.clear();
  services.client.subscribe.subscriptionHandlesAsset.clear();
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