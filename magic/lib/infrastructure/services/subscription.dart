import 'dart:async';
import 'package:magic/cubits/cubit.dart';
import 'package:serverpod_client/serverpod_client.dart';
import 'package:magic/infrastructure/server/serverv2_client.dart' as server;
import 'package:magic/infrastructure/server/protocol/protocol.dart' as protocol;

class SubscriptionService {
  //static const String moontreeUrl = 'http://24.199.68.139:8080';
  //static const String moontreeUrl = 'https://app.moontree.com/ws';
  static const String moontreeUrl = 'https://app.moontree.com';
  final server.Client client;
  late server.ConnectivityMonitor monitor;
  bool isConnected = false;
  late StreamingConnectionHandler connectionHandler;
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];

  SubscriptionService() : client = server.Client('$moontreeUrl/');

  Future<void> setupClient(server.ConnectivityMonitor givenMonitor) async {
    monitor = givenMonitor;
    client.connectivityMonitor = givenMonitor;
    //await client.openStreamingConnection(
    //    disconnectOnLostInternetConnection: true);
    connectionHandler = StreamingConnectionHandler(
      client: client,
      retryEverySeconds: 10,
      listener: (StreamingConnectionHandlerState connectionState) {
        print('connection state: ${connectionState.status.name}');
        cubits.app.update(connection: connectionState.status);
      },
    );
    print('connecting!');
    try {
      connectionHandler.connect();
    } catch (e) {
      print(e);
    }
    await setupListeners();
  }

  Future<void> setupListeners() async {
    /// TODO: implement triggerBalanceUpdates - after we setup repos for holdings:
    void triggerBalanceUpdates() {
      print('triggerBalanceUpdates - not implemented');
      /*
      // update holdings list
      cubits.holdingsView.setHoldingViews(
          wallet: Current.wallet, chainNet: Current.chainNet, force: true);
      // update receive address
      cubits.receiveView.setAddress(Current.wallet, force: true);
      // if we're on the transactions list, update that too:
      if (cubits.transactionsView.state.ranWallet != null) {
        cubits.transactionsView.setInitial(force: true);
      }
      */
    }

    try {
      client.subscription.stream.listen((message) async {
        /// # status means the state of the synchronizer (2 means up to date)
        /// examples:
        ///   {"id":null,"chainName":"evrmore_mainnet","status":2}
        ///   {"id":null,"chainName":"evrmore_mainnet","height":107222}
        // if height do x
        // if balance update do y, etc.
        //print(message);
        if (message is protocol.NotifyChainStatus) {
        } else if (message is protocol.NotifyChainHeight) {
          if (message.height > 0) {
            cubits.app.update(blockheight: message.height);
          }
        } else if (message is protocol.NotifyChainH160Balance) {
          triggerBalanceUpdates();
        } else if (message is protocol.NotifyChainWalletBalance) {
          triggerBalanceUpdates();
        } else {
          print('unknown subscription message: ${message.runtimeType}');
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

  /// TODO: implement setupSubscription
  Future<void> setupSubscription() async {
    //  Wallet? wallet,
    //  Chain? chain,
    //  Net? net,
    //}) async {
    /* how to call:
        await subscription.setupSubscription(
          wallet: pros.wallets.currentWallet,
          chain: value.chain,
          net: value.net,
        );
      */
    //  wallet ??= pros.wallets.currentWallet;
    //  chain ??= pros.settings.chain;
    //  net ??= pros.settings.net;
    //  List<String> roots = [];
    //  List<String> h160s = [];
    //  if (wallet is LeaderWallet) {
    //    roots = await (wallet).roots;
    //  } else if (wallet is SingleWallet) {
    //    h160s = wallet.addresses.map((e) => e.h160AsString).toList();
    //  }
    //  final subscriptionVoid =
    //      /// MOCK SERVER
    //      //await Future.delayed(Duration(seconds: 1), spoofNothing);
    //      /// SERVER
    //      await subscription.specifySubscription(
    //          chains: [ChainNet(chain, net).chaindata.name],
    //          roots: roots,
    //          h160s: h160s);
    //  return subscriptionVoid;
  }

  void spoofNothing() {}
}

final SubscriptionService subscription = SubscriptionService();
