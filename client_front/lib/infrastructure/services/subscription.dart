import 'package:client_back/streams/client.dart';
import 'package:serverpod_client/serverpod_client.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart' as server;
import 'package:client_back/server/src/protocol/protocol.dart' as protocol;
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:client_front/presentation/components/components.dart';

class SubscriptionService {
  //'https://api.moontree.com';
  static const String moontreeUrl = 'http://24.199.68.139:8080';
  final server.Client client;
  late server.ConnectivityMonitor monitor;
  bool isConnected = false;
  late final StreamingConnectionHandler connectionHandler;

  SubscriptionService() : client = server.Client('$moontreeUrl/');

  Future<void> setupClient(server.ConnectivityMonitor givenMonitor) async {
    monitor = givenMonitor;
    client.connectivityMonitor = givenMonitor;
    //await client.openStreamingConnection(
    //    disconnectOnLostInternetConnection: true);
    connectionHandler = StreamingConnectionHandler(
      client: client,
      listener: (connectionState) {
        print('connection state: ${connectionState.status}');
        // todo: make connection light dependent upon this (cubit)
        // StreamingConnectionStatus.connecting
        // StreamingConnectionStatus.connected
        // StreamingConnectionStatus.waitingToRetry
        if (connectionState.status == StreamingConnectionStatus.connected) {
          streams.client.connected.add(ConnectionStatus.connected);
        } else if (connectionState.status ==
                StreamingConnectionStatus.connecting ||
            connectionState.status ==
                StreamingConnectionStatus.waitingToRetry) {
          streams.client.connected.add(ConnectionStatus.connecting);
        } else if (connectionState.status ==
            StreamingConnectionStatus.disconnected) {
          streams.client.connected.add(ConnectionStatus.disconnected);
        }
      },
    );
    connectionHandler.connect();
    await setupListeners();
  }

  Future<void> setupListeners() async {
    void triggerBalanceUpdates() {
      // update holdings list
      components.cubits.holdingsViewCubit
          .setHoldingViews(Current.wallet, Current.chainNet, force: true);
      // update receive address
      components.cubits.receiveViewCubit
          .setAddress(Current.wallet, force: true);
      // if we're on the transactions list, update that too:
      if (components.cubits.transactionsViewCubit.state.ranWallet != null) {
        components.cubits.transactionsViewCubit.setInitial();
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
        print(message);
        if (message is protocol.NotifyChainStatus) {
          print('status! ${message.toJson()}');
        } else if (message is protocol.NotifyChainHeight) {
          await pros.blocks.save(Block.fromNotification(message));
          print('pros.blocks.records ${pros.blocks.records.first}');
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
