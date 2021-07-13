// dart --no-sound-null-safety test test/raven_tx_test.dart
import 'dart:io';
import 'package:bip39/bip39.dart' as bip39;

import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'package:raven/raven_networks.dart';
import 'package:raven/account.dart';
import 'package:raven/env.dart' as env;
import 'package:raven/boxes.dart' as boxes;
import 'package:raven/listen.dart' as listen;
import 'package:raven/accounts.dart' as accounts;

class Generated {
  String phrase;
  Account account;
  RavenElectrumClient client;
  boxes.Truth truth;
  Generated(this.phrase, this.account, this.client, this.truth);
}

Future setup() async {
  // Deletes the directory "remove" with all folders and files under it.
  await Directory('database').delete(recursive: true);
  await boxes.Truth.instance.open();
  //await boxes.Truth.instance.clear();
  await boxes.Truth.instance.loadDefaults();
  await accounts.Accounts.instance.load();
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
  var truth = boxes.Truth.instance;
  var phrase = await env.getMnemonic();
  var account = Account.bySeed(ravencoinTestnet, bip39.mnemonicToSeed(phrase));
  await truth.saveAccount(account);
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