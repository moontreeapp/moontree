import 'dart:async';

import 'package:client_front/application/infrastructure/connection/cubit.dart';
import 'package:serverpod_client/serverpod_client.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart' as server;
import 'package:client_back/server/src/protocol/protocol.dart' as protocol;
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/infrastructure/services/lookup.dart';

class SubscriptionService {
  //static const String moontreeUrl = 'http://24.199.68.139:8080';
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
      listener: (StreamingConnectionHandlerState connectionState) {
        print('connection state: ${connectionState.status.name}');
        if (!streams.app.loc.splash.value) {
          if (connectionState.status == StreamingConnectionStatus.connected) {
            components.cubits.connection
                .update(status: ConnectionStatus.connected);
          } else if ([
            StreamingConnectionStatus.connecting,
            StreamingConnectionStatus.waitingToRetry,
          ].contains(connectionState.status)) {
            components.cubits.connection
                .update(status: ConnectionStatus.connecting);
          } else if (connectionState.status ==
              StreamingConnectionStatus.disconnected) {
            components.cubits.connection
                .update(status: ConnectionStatus.disconnected);
          }
        }
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
    void triggerBalanceUpdates() {
      // update holdings list
      components.cubits.holdingsView.setHoldingViews(
          wallet: Current.wallet, chainNet: Current.chainNet, force: true);
      // update receive address
      components.cubits.receiveView.setAddress(Current.wallet, force: true);
      // if we're on the transactions list, update that too:
      if (components.cubits.transactionsView.state.ranWallet != null) {
        components.cubits.transactionsView.setInitial(force: true);
      }
    }

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
        //print(message);
        if (message is protocol.NotifyChainStatus) {
          //print('status! ${message.toJson()}');
        } else if (message is protocol.NotifyChainHeight) {
          if (message.height > 0) {
            await pros.blocks.save(Block.fromNotification(message));
            //print('pros.blocks.records ${pros.blocks.records.first}');
          } else {
            //print('message was weird: ${message.toJson()}');
          }
        } else if (message is protocol.NotifyChainH160Balance) {
          // print('H160 (SingleWallet) balance updated!');
          triggerBalanceUpdates();
        } else if (message is protocol.NotifyChainWalletBalance) {
          // print('LeaderWallet balance updated!');
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

    listeners.add(streams.app.loc.splash.listen((bool value) {
      if (!value) {
        if (connectionHandler.status.status ==
            StreamingConnectionStatus.connected) {
          components.cubits.connection
              .update(status: ConnectionStatus.connected);
        } else if ([
          StreamingConnectionStatus.connecting,
          StreamingConnectionStatus.waitingToRetry
        ].contains(connectionHandler.status.status)) {
          components.cubits.connection
              .update(status: ConnectionStatus.connecting);
        } else if (connectionHandler.status.status ==
            StreamingConnectionStatus.disconnected) {
          components.cubits.connection
              .update(status: ConnectionStatus.disconnected);
        }
      }
    }));
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
      roots = await (wallet).roots;
    } else if (wallet is SingleWallet) {
      h160s = wallet.addresses.map((e) => e.h160AsString).toList();
    }
    final subscriptionVoid =

        /// MOCK SERVER
        //await Future.delayed(Duration(seconds: 1), spoofNothing);

        /// SERVER
        await subscription.specifySubscription(
            chains: [ChainNet(chain, net).chaindata.name],
            roots: roots,
            h160s: h160s);

    return subscriptionVoid;
  }

  void spoofNothing() {}
}

final SubscriptionService subscription = SubscriptionService();
