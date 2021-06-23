// dart --no-sound-null-safety test test/unit/collect_test.dart
import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:raven/env.dart' as env;
import 'package:raven/account.dart';
import 'package:raven/raven_networks.dart';
import 'package:raven/electrum_client.dart';

Future<List> generate() async {
  var phrase = await env.getMnemonic();
  var account = Account(ravencoinTestnet, seed: bip39.mnemonicToSeed(phrase));
  var client = ElectrumClient();
  await client.connect(host: 'testnet.rvn.rocks', port: 50002);
  await account.deriveNodes(client);
  return [phrase, account, client];
}

void main() async {
  test('sort utxos', () async {
    var gen = await generate();
    var account = gen[1];
    print('collecting UTXOs');
    var _internals = account.getInternals();
    var _externals = account.getExternals();
    //print(_internals);
    print('0');
    print(_internals[0].utxos);
    print('1');
    print(_internals[1].utxos);
    print('2');
    print(_internals[2].utxos);
    print('3');
    print(_internals[3].utxos);

    //_internals.sort((a, b) => a.utxos
    //    .reduce((c, d) => c['value'] + d['value'])
    //    .compareTo(b.utxos.reduce((e, f) => e['value'] + f['value'])));
    //print(_internals);
  });
}
