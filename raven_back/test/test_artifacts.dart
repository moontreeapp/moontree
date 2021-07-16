// dart --no-sound-null-safety test test/raven_tx_test.dart
import 'dart:io';
import 'package:bip39/bip39.dart' as bip39;

import 'package:ravencoin/ravencoin.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'package:raven/account.dart';
import 'package:raven/env.dart' as env;
import 'package:raven/boxes.dart';
import 'package:raven/listen.dart' as listen;
import 'package:raven/accounts.dart';

class Generated {
  String phrase;
  Account account;
  RavenElectrumClient client;
  Truth truth;
  Generated(this.phrase, this.account, this.client, this.truth);
}

Future setup() async {
  await Directory('database').delete(recursive: true);
  await Truth.instance.open();
  await Accounts.instance.load();
}

void listenTo(RavenElectrumClient client) {
  listen.toAccounts();
  listen.toNodes(client);
  listen.toUnspents();
}

Future<Generated> generate() async {
  await setup();
  var client = await RavenElectrumClient.connect('testnet.rvn.rocks');
  listenTo(client);
  var truth = Truth.instance;
  var phrase = await env.getMnemonic();
  var account = Account.bySeed(ravencoin, bip39.mnemonicToSeed(phrase));
  await truth.saveAccount(account);
  await Truth.instance.unspents
      .watch()
      .skipWhile((element) =>
          element.key !=
          '0d78acdf5fe186432cbc073921f83bb146d72c4a81c6bde21c3003f48c15eb38')
      .take(1)
      .toList();
  return Generated(phrase, account, client, truth);
}


//Future<Generated> generateFromMemory() async {
//  var truth = memory.Truth.instance;
//  var account = Account(ravencoinTestnet, seed: truth.boxes['accounts']['seed']);
//  var client = await ElectrumClient.connect('testnet.rvn.rocks');
//  await truth.saveAccount(account);
//  await account.deriveNodes(client);
//  await truth.saveAccountBalance(account);
//  return Generated(phrase, account, client);
//}