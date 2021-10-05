// dart --no-sound-null-safety test test/integration/raven_tx_test.dart

import 'package:raven/utils/parse.dart';
import 'package:test/test.dart';

import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:raven/services/transaction.dart' as tx;

const connectionTimeout = Duration(seconds: 5);
const aliveTimerDuration = Duration(seconds: 2);

void main() {
  test('getHistory', () async {
    var client = RavenElectrumClient(await connect('testnet.rvn.rocks'));
    await client.serverVersion(protocolVersion: '1.9');
    var scripthash =
        '93bfc0b3df3f7e2a033ca8d70582d5cf4adf6cc0587e10ef224a78955b636923';
    var history = await client.getHistory(scripthash);
    expect(history, [
      ScripthashHistory(
          txHash:
              '56fcc747b8067133a3dc8907565fa1b31e452c98b3f200687cb836f98c3c46ae',
          height: 747308),
      ScripthashHistory(
          txHash:
              '2dada22848277e6a23b49c1e63d47b661f94819b2001e2789a5fd947b51907d5',
          height: 769767)
    ]); // could fail if people send to this address...
  });
  test('getTransaction and parse', () async {
    var client = RavenElectrumClient(await connect('testnet.rvn.rocks'));
    await client.serverVersion(protocolVersion: '1.9');
    var tx = await client.getTransaction(
        'e86f693b46f1ca33480d904acd526079ba7585896cff6d0ae5dcef322d9dc52a');
    expect(parseTxForMemo(tx),
        'aa21a9ede2f61c3f71d1defd3fa999dfa36953755c690689799962b48bebd836974e8cf9');
  });
}
