import 'package:bip39/bip39.dart' as bip39;

import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:raven/records/net.dart';
import 'package:raven/subjects/reservoir.dart';

import 'models.dart';
import 'env.dart' as env;
import 'boxes.dart';
import 'listener.dart';
import 'accounts.dart';
import 'records/node_exposure.dart';

late Reservoir accounts;
late Reservoir addresses;

void setup2() {
  accounts = Reservoir(
      HiveBoxSource('accounts'),
      (account) => account.accountId,
      (account) => Account.fromRecord(account),
      (account) => account.toRecord());

  addresses = Reservoir(
      HiveBoxSource('addresses'),
      (address) => address.scripthash,
      (address) => Address.fromRecord(address),
      (address) => address.toRecord())
    ..addIndex('account', (address) => address.accountId)
    ..addIndex('account-exposure',
        (address) => '${address.accountId}:${address.exposure}');

  accounts.changes.listen((change) {
    change.when(
        added: (added) {
          Account account = added.data;
          var addr1 = account.deriveAddress(0, NodeExposure.Internal);
          var addr2 = account.deriveAddress(0, NodeExposure.External);
        },
        updated: (updated) {},
        removed: (removed) {});
  });
}

Future setup() async {
  await Truth.instance.open();
  await Truth.instance.clear();
  await Accounts.instance.load();
}

void listenTo(RavenElectrumClient client) {
  var listen = BoxListener(client);
  listen.toAccounts();
  listen.toNodes();
  listen.toUnspents();
}

Future<RavenElectrumClient> init([List<String>? phrases]) async {
  await setup();
  var client = await RavenElectrumClient.connect('testnet.rvn.rocks');
  listenTo(client);
  phrases = phrases ?? [await env.getMnemonic()];
  for (var phrase in phrases) {
    var account = Account(bip39.mnemonicToSeed(phrase),
        cipher: Accounts.instance.cipher, net: Net.Test);
    await Truth.instance.saveAccount(account);
    await Truth.instance.unspents
        .watch()
        .skipWhile((element) =>
            element.key !=
                '0d78acdf5fe186432cbc073921f83bb146d72c4a81c6bde21c3003f48c15eb38' &&
            element.key !=
                'c22b0d7d99e5b41546518d38447b011bb3a4b9a75724558794c07db640b57ed4')
        .take(1)
        .toList();
  }
  return client;
}
