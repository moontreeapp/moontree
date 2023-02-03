import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart' as server;
import 'package:client_back/server/src/protocol/protocol.dart' as protocol;
import 'package:serverpod_client/serverpod_client.dart';

class SubscriptionService {
  static const String moontreeUrl =
      'http://24.199.68.139:8080'; //'https://api.moontree.com';
  final server.Client client;
  late server.ConnectivityMonitor monitor;

  SubscriptionService() : client = server.Client('$moontreeUrl/');

  Future<void> setupClient(
    server.ConnectivityMonitor givenMonitor,
  ) async {
    monitor = givenMonitor;
    client.connectivityMonitor = givenMonitor;
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
    try {
      client.subscription.stream.listen((message) async {
        /// # status means the state of the synchronizer (2 means up to date)
        /// examples:
        ///   {"id":null,"chainName":"evrmore_mainnet","status":2}
        ///   {"id":null,"chainName":"evrmore_mainnet","height":107222}
        // if height do x
        // if balance update do y, etc.
        print(message);
        if (message is protocol.NotifyChainStatus) {
          print('status!');
        } else if (message is protocol.NotifyChainHeight) {
          await pros.blocks.save(Block.fromNotification(message));
          print('pros.blocks.records ${pros.blocks.records.first}');
        } else if (message is protocol.NotifyChainH160Balance) {
          print('H160 balance!');
        } else if (message is protocol.NotifyChainWalletBalance) {
          print('wallet balance!');
        } else {
          print(message.runtimeType);
        }
      });
    } on StateError {
      print('listeners already setup');
    } catch (e) {
      print(e);
    }
  }

  Future<void> specifySubscription({
    required List<String> chains,
    required List<String> roots,
    required List<String> h160s,
  }) async {
    try {
      await client.subscription
          .sendStreamMessage(protocol.ChainWalletH160Subscription(
        chains: chains,
        walletPubKeys: roots,
        h160s: h160s,
      ));
    } on ServerpodClientException {
      /// (ServerpodClientException: WebSocket is not connected, statusCode = 0)
      print(
          'ServerpodClientException: WebSocket is not connected, trying again');
      await setupClient(monitor);
      await specifySubscription(chains: chains, roots: roots, h160s: h160s);
    } catch (e) {
      print(e);
    }
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
      roots = await (wallet as LeaderWallet).roots;
    } else if (wallet is SingleWallet) {
      h160s = wallet.addresses.map((e) => e.h160String).toList();
    }
    final subscriptionVoid =

        /// MOCK SERVER
        //await Future.delayed(Duration(seconds: 1), spoofNothing);

        /// SERVER
        await services.subscription.specifySubscription(
            chains: [ChainNet(chain, net).chaindata.name],
            roots: roots,
            h160s: h160s);

    return subscriptionVoid;
  }

  void spoofNothing() {}
}
