import 'package:test/test.dart';

import 'package:bip39/bip39.dart' as bip39;
import 'package:ravencoin/ravencoin.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'package:raven/boxes.dart';
import 'package:raven/env.dart';
import 'package:raven/cipher.dart';
import 'package:raven/account.dart';
import 'package:raven/models/node_exposure.dart';
import '../test_artifacts.dart' as tests;

void main() async {
  var account;
  var client = await RavenElectrumClient.connect('testnet.rvn.rocks');

  setUpAll(() async {
    await tests.setup();
    //tests.listenTo(client);
    account = Account.bySeed(
        testnet, bip39.mnemonicToSeed(await getMnemonic()), CIPHER);
  });

  tearDownAll(() async => await Truth.instance.close());

  test('run batch', () async {
    var stats = await client.getOurStats();
    print('before ${stats.toString()}');
    account.deriveBatch(NodeExposure.Internal, 1);
    account.deriveBatch(NodeExposure.External, 100);
    // 200 'cd13adba86dbe94e244ce031e3e80197e44566cd86f113e7f30a3ea05fed0486'
    // 300 'c8053a6a61b0d6b77f13986ac4183c396d4e1735a2dc35729d9eec158d6b9f34'
    await Truth.instance.scripthashAccountIdExternal
        .watch()
        .skipWhile((element) =>
            element.key !=
            'dee2e493767ef0dbf1efe998c6cce6f877fd20ef8375498beaec1159178061b1')
        .take(1)
        .toList();
    var hashes = account.accountScripthashes;
    print('hashes: ${hashes.length}');
    var balances = await client.getBalances(hashes);
    print('balances: ${balances.length}');
    stats = await client.getOurStats();
    print('after ${stats.toString()}');
    expect(account.accountId,
        '7b2c0df50ca21115199b1a0d5d254bb280b49be83552cac8a5b5e6471f376267');
  });

  /** before batch
  ServerStats(
    ourCost: 5.705,
    hardLimit: 0,
    softLimit: 0,
    costDecayPerSec: 0.0,
    bandwithCostPerByte: 0.001,
    sleep: 2.5,
    concurrentRequests: 10,
    sendSize: 73,
    sendCount: 1,
    receiveSize: 132,
    receiveCount: 2)
  */
  /** batch of 99 scripthashes to get_balance
  hashes: 99
  balances: 99
  after ServerStats(
      ourCost: 127.349,
      hardLimit: 0,
      softLimit: 0,
      costDecayPerSec: 0.0,
      bandwithCostPerByte: 0.001,
      sleep: 2.5,
      concurrentRequests: 10,
      sendSize: 7876,
      sendCount: 3,
      receiveSize: 14933,
      receiveCount: 4)
   */
  /** 500, 300, 200 all timed out, tried 100 again and it timed out too...
   * so I think it's got to be a ddos limit or something... not problem, we
   * can batch at 10 or 20 for now, further optimization won't save much more.
   * and now we can at least check our costs on demand if we want to...
   */
}
