// dart test .\test\unit\services\download_assets.dart
import 'package:test/test.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_electrum/ravencoin_electrum.dart';

//import 'package:raven_electrum/methods/asset/meta.dart';??
/*
  JSON-RPC error -32601 (method not found): unknown method "blockchain.asset.get_meta"
  package:json_rpc_2/src/client.dart 121:62             Client.sendRequest
  package:json_rpc_2/src/peer.dart 98:15                Peer.sendRequest
  package:raven_electrum/client/base_client.dart 55:23  BaseClient.request
  package:raven_electrum/methods/asset/meta.dart 58:26  GetAssetMetaMethod.getMeta
  test\unit\services\download_assets.dart 19:29         main.<fn>
  */

void main() async {
  test('get asset', () async {
    var client = RavenElectrumClient(await connect('testnet.rvn.rocks'));
    //RavenElectrumClient(await connect('rvn4lyfe.com', port: 50003));
    //var txHash = [
    //  '6b082294f4046c05d54e7fa4c846673258c1cb63734f50558b9210b75e3037d5',
    //  '5cdde1dc17f820320011ec648272237322e1cde48e62158b3cb56999c5aba0e8',
    //  '9b64eb258a4352a68c4ce98cbbadddcbbcb285c422f7f9f97ed4b826d0a387d7',
    //];
    //var tx = await client.getTransaction(txHash[0]);
    //print(tx);

    //var meta = await client.getMeta('MOONTREE');
    //print(meta);
    //await services.download.asset.downloadAsset('MOONTREE', client);
    //expect(?, ?);
    services.client.ravenElectrumClient = client;
    print(await services.client.api.getAssetNames('MOON'));
  });
}
