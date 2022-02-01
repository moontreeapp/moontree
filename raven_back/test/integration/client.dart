// dart test test/integration/client.dart

import 'package:test/test.dart';

import 'package:raven_electrum/raven_electrum.dart';

void main() {
  test('getTransaction on odd tx', () async {
    var client =
        // RavenElectrumClient(await connect('testnet.rvn.rocks'));
        RavenElectrumClient(await connect('rvn4lyfe.com', port: 50003));
    var txHash = [
      //'6b082294f4046c05d54e7fa4c846673258c1cb63734f50558b9210b75e3037d5',
      '5cdde1dc17f820320011ec648272237322e1cde48e62158b3cb56999c5aba0e8',
      //'9b64eb258a4352a68c4ce98cbbadddcbbcb285c422f7f9f97ed4b826d0a387d7',
    ];
    var tx = await client.getTransaction(txHash[0]);
    //print(tx);
    print('done');
    //var tx1 = await client.getTransaction(txHash[1]);
    //print(tx1);
  });
}
