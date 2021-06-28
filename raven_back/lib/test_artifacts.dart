// dart --no-sound-null-safety test test/raven_tx_test.dart

import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:raven/raven_networks.dart';
import 'package:raven/account.dart';
import 'package:raven/electrum_client/electrum_client.dart';
import 'package:raven/electrum_client/connect.dart';
import 'package:raven/env.dart' as env;

class Generated {
  String phrase;
  Account account;
  ElectrumClient client;
  Generated(this.phrase, this.account, this.client);
}

Future<Generated> generate() async {
  var phrase = await env.getMnemonic();
  var account = Account(ravencoinTestnet, seed: bip39.mnemonicToSeed(phrase));
  var client = ElectrumClient(await connect('testnet.rvn.rocks'));
  await account.deriveNodes(client);
  return Generated(phrase, account, client);
}
