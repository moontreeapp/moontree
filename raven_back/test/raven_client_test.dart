import 'dart:io';
import 'package:raven/account.dart';
import 'package:raven/raven_networks.dart';
import 'package:raven/electrum_client.dart';
import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;

bool skipUnverified(X509Certificate certificate) {
  return true;
}

const connectionTimeout = Duration(seconds: 5);
const aliveTimerDuration = Duration(seconds: 2);
void main() {
  // test('client', () async {
  //   var internetAddresses = await InternetAddress.lookup('testnet.rvn.rocks');
  //   print(internetAddresses[0]);
  //   var socket = await SecureSocket.connect(internetAddresses[0], 50002,
  //       timeout: connectionTimeout, onBadCertificate: skipUnverified);
  //   print('connected');
  //   var channel = StreamChannel(socket.cast<List<int>>(), socket);
  //   var client = RavenClient(
  //       channel.transform(StreamChannelTransformer.fromCodec(utf8)));
  //   client.listen();

  //   // var client = RavenClient(channel);
  //   print('request server.version');
  //   var version = await client.serverVersion();
  //   print(version);
  //   print('request blockchain.relayfee');
  //   var balance = await client.relayFee();
  //   inspect(balance);
  // });

  // test('electrum client', () async {
  //   var client = ElectrumClient();
  //   print('connecting...');
  //   // await client.connect(host: 'testnet.rvn.rocks', port: 50002);
  //   await client.connect(host: '143.198.142.78', port: 50002);
  //   print('connected, getting version...');
  //   var version = await client.version('MTWallet', '1.8');
  //   print(version);
  //   var features = await client.features();
  //   print(features);
  // });

  test('getBalance', () async {
    var seed = bip39.mnemonicToSeed(
        'smile build brain topple moon scrap area aim budget enjoy polar erosion');

    var account = Account(ravencoinTestnet, seed: seed);

    var client = ElectrumClient();
    await client.connect(host: 'testnet.rvn.rocks', port: 50002);
    var version = await client.version('MTWallet', '1.8');
    print(version);

    var node = account.node(4, exposure: NodeExposure.Internal);

    var balance = await client.getBalance(node.scriptHash);
    print(balance);
  });
}
