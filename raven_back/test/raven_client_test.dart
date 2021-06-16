import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:raven/raven_client.dart';
import 'package:raven/raven_networks.dart';
import 'package:raven/raven_network.dart';
import 'package:raven/wallet_exposure.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:raven/electrum_client.dart';
import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bitcoin_flutter/bitcoin_flutter.dart' as bitcoin;

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

    var network = RavenNetwork(ravencoinTestnet);

    var client = ElectrumClient();
    await client.connect(host: 'testnet.rvn.rocks', port: 50002);
    var version = await client.version('MTWallet', '1.8');
    print(version);

    var wallet = network.getRavenWallet(seed);
    var scriptHash =
        wallet.scriptHashFromAddress(4, exposure: WalletExposure.Internal);
    var balance = await client.getBalance(scriptHash);
    print(balance);
  });
}
