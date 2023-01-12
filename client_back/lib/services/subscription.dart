import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart' as server;
import 'package:client_back/server/src/protocol/protocol.dart' as protocol;

class SubscriptionService {
  static const String moontreeUrl =
      'http://24.199.68.139:8080'; //'https://api.moontree.com';
  final server.Client client;

  SubscriptionService() : client = server.Client('$moontreeUrl/');

  Future<void> setupClient({
    required server.ConnectivityMonitor monitor,
  }) async {
    client.connectivityMonitor = monitor;
    await client.openStreamingConnection(
        disconnectOnLostInternetConnection: true);
    await setupListeners();
  }

  Future<void> setupListeners() async {
    // move this to waiter? no, it has to be setup after above, I think, and
    // monitor comes from the frontend, so we have to load the app first.
    // we might as well setup these listeners on login or something like that.
    // probably only needs to be set up once, not everytime we
    // specifySubscription.
    client.subscription.stream.listen((message) {
      /// if height do x
      /// if balance update do y, etc.
      print(message);
    });
  }

  Future<void> specifySubscription({
    required List<String> chains,
    required List<String> roots,
    required List<String> h160s,
  }) async {
    await client.subscription
        .sendStreamMessage(protocol.ChainWalletH160Subscription(
      chains: chains,
      walletPubKeys: roots,
      h160s: h160s,
    ));
  }

  Future<void> setupSubscription({
    Wallet? wallet,
    Chain? chain,
    Net? net,
  }) async {
    wallet ??= pros.wallets.currentWallet;
    chain ??= pros.settings.chain;
    net ??= pros.settings.net;
    List<String> roots = [];
    List<String> h160s = [];
    if (wallet is LeaderWallet) {
      roots = await wallet.roots;
    } else if (wallet is SingleWallet) {
      h160s = wallet.addresses.map((e) => e.h160String).toList();
    }
    final subscriptionVoid =

        /// MOCK SERVER
        await Future.delayed(Duration(seconds: 1), spoofNothing);

    /// SERVER
    //await services.subscription.specifySubscription(
    //    chains: [ChainNet(chain, net).chaindata.name],
    //    roots: roots,
    //    h160s: h160s);

    return subscriptionVoid;
  }

  void spoofNothing() {}
}
