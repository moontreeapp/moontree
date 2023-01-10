import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart' as server;
import 'package:client_back/server/src/protocol/protocol.dart' as protocol;
import 'package:client_front/services/lookup.dart';

class SubscriptionGeneric {
  static const String moontreeUrl =
      'http://24.199.68.139:8080'; //'https://api.moontree.com';
  final server.Client client;

  SubscriptionGeneric() : client = server.Client('$moontreeUrl/');

  Future<void> setupGenericSubscription({
    required List<String> chains,
    required List<String> roots,
    required List<String> h160s,
    required server.ConnectivityMonitor monitor,
  }) async {
    client.connectivityMonitor = monitor;
    await client.openStreamingConnection(
        disconnectOnLostInternetConnection: true);
    client.subscription.stream.listen((message) {
      print(message);
    });
    client.subscription.sendStreamMessage(protocol.ChainWalletH160Subscription(
      chains: chains,
      walletPubKeys: roots,
      h160s: h160s,
    ));
  }
}

Future<void> discoverSubscriptionGeneric({
  Wallet? wallet,
  Chain? chain,
  Net? net,
  required server.ConnectivityMonitor monitor,
}) async {
  wallet ??= Current.wallet;
  chain ??= Current.chain;
  net ??= Current.net;
  List<String> roots = [];
  List<String> h160s = [];
  if (wallet is LeaderWallet) {
    roots = await wallet.roots;
  } else if (wallet is SingleWallet) {
    h160s = Current.wallet.addresses.map((e) => e.h160String).toList();
  }
  final subscriptionVoid =

      /// MOCK SERVER
      //await Future.delayed(Duration(seconds: 1), spoofNothing);

      /// SERVER
      await SubscriptionGeneric().setupGenericSubscription(
          chains: [ChainNet(chain, net).chaindata.name],
          roots: roots,
          h160s: h160s,
          monitor: monitor);

  return subscriptionVoid;
}

void spoofNothing() {}
