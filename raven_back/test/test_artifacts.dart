// dart --no-sound-null-safety test test/raven_tx_test.dart
import 'dart:io';
import 'package:bip39/bip39.dart' as bip39;

import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'package:raven/unneeded/accounts.dart';
import 'package:raven/unneeded/boxes.dart';
import 'package:raven/utils/env.dart' as env;
import 'package:raven/services/address_subscription.dart';
import 'package:raven/models/account.dart';
import 'package:raven/records/net.dart';

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
  var listen = ElectrumListener(client);
  listen.toAccounts();
  listen.toNodes();
  listen.toUnspents();
}

Future<Generated> generate() async {
  await setup();
  var client = await RavenElectrumClient.connect('testnet.rvn.rocks');
  listenTo(client);
  var truth = Truth.instance;
  var phrase = await env.getMnemonic();
  var account = Account(bip39.mnemonicToSeed(phrase), net: Net.Test);
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