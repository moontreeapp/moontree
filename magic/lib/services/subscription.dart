import 'dart:async';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/wallet/wallets.dart';
import 'package:serverpod_client/serverpod_client.dart';
import 'package:magic/domain/server/serverv2_client.dart' as server;
import 'package:magic/domain/server/protocol/protocol.dart' as protocol;

class SubscriptionService {
  //static const String moontreeUrl = 'http://24.199.68.139:8080';
  //static const String moontreeUrl = 'https://app.moontree.com/ws';
  static const String moontreeUrl = 'https://app.moontree.com';
  final server.Client client;
  late server.ConnectivityMonitor monitor;
  bool isConnected = false;
  late StreamingConnectionHandler connectionHandler;
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];

  DateTime? _starttime;

  SubscriptionService() : client = server.Client('$moontreeUrl/');

  DateTime get starttime {
    _starttime = _starttime ?? DateTime.now().toUtc();
    return _starttime!;
  }

  Future<void> setupClient(
    server.ConnectivityMonitor givenMonitor, {
    int retryCount = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    monitor = givenMonitor;
    client.connectivityMonitor = givenMonitor;
    connectionHandler = StreamingConnectionHandler(
      client: client,
      retryEverySeconds: retryDelay.inSeconds,
      listener: (StreamingConnectionHandlerState connectionState) {
        print('connection state: ${connectionState.status.name}');
        cubits.app.update(connection: connectionState.status);
      },
    );

    print('Connecting...');
    for (int attempt = 1; attempt <= retryCount; attempt++) {
      try {
        connectionHandler.connect();

        // Wait for connection to be established (up to 10 seconds)
        final stopwatch = Stopwatch()..start();
        while (connectionHandler.status.status !=
                StreamingConnectionStatus.connected &&
            stopwatch.elapsed < const Duration(seconds: 10)) {
          await Future.delayed(const Duration(milliseconds: 100));
        }

        if (connectionHandler.status.status ==
            StreamingConnectionStatus.connected) {
          print('Connected successfully on attempt $attempt');
          await setupListeners();
          return;
        } else {
          print('Failed to connect on attempt $attempt');
        }
      } catch (e) {
        print('Error during connection setup on attempt $attempt: $e');
      }

      if (attempt < retryCount) {
        print('Retrying in ${retryDelay.inSeconds} seconds...');
        await Future.delayed(retryDelay);
      }
    }

    print('Failed to connect after $retryCount attempts');
    // Handle connection failure (e.g., show an error message to the user)
  }

  Future<void> setupListeners() async {
    /// TODO: implement triggerBalanceUpdates - after we setup repos for holdings:
    void triggerBalanceUpdates() {
      print('triggerBalanceUpdates - not implemented');
      cubits.wallet.populateAssets();
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
        if (message is protocol.NotifyChainStatus) {
        } else if (message is protocol.NotifyChainHeight) {
          if (message.height > 0) {
            print(message);
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

  Future<void> ensureConnected() async {
    if (connectionHandler.status.status ==
        StreamingConnectionStatus.connected) {
      return; // Already connected, no action needed
    }

    // Check if a connection attempt is already in progress
    if (connectionHandler.status.status ==
        StreamingConnectionStatus.connecting) {
      // Wait for the existing connection attempt to complete
      await _waitForConnection();
      return;
    }

    // If not connected and not connecting, initiate a new connection
    try {
      connectionHandler.connect();
    } catch (e) {
      print('Failed to connect: $e');
      // Handle connection error (e.g., throw an exception or return an error status)
    }
  }

  Future<void> _waitForConnection() async {
    final stopwatch = Stopwatch()..start();
    while (connectionHandler.status.status !=
            StreamingConnectionStatus.connected &&
        stopwatch.elapsed < const Duration(seconds: 10)) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (connectionHandler.status.status !=
        StreamingConnectionStatus.connected) {
      throw TimeoutException('Connection attempt timed out');
    }
  }

  Future<void> specifySubscription({
    required List<String> chains,
    required List<String> roots,
    required List<String> h160s,
  }) async {
    await ensureConnected();
    try {
      await client.subscription
          .sendStreamMessage(protocol.ChainWalletH160Subscription(
        chains: chains,
        walletPubKeys: roots,
        h160s: h160s,
      ));
    } catch (e) {
      print('Failed to send subscription: $e');
      // Implement proper error handling
    }
  }

  Future<void> setupSubscriptions(MasterWallet master) async {
    final roots = <String>[];
    final h160s = <String>[];
    // todo: add evrmoreMain
    for (final mnemonicWallet in master.mnemonicWallets) {
      roots.addAll(mnemonicWallet.roots(Blockchain.ravencoinMain));
      //roots.addAll(mnemonicWallet.roots(Blockchain.evrmoreMain));
    }
    for (final keypairWallet in master.keypairWallets) {
      h160s.add(keypairWallet.h160AsString(Blockchain.ravencoinMain));
      //h160s.add(keypairWallet.h160AsString(Blockchain.evrmoreMain));
    }
    final subscriptionVoid =

        /// MOCK SERVER
        //await Future.delayed(Duration(seconds: 1), spoofNothing);
        /// SERVER
        await specifySubscription(chains: [
      Blockchain.ravencoinMain.chaindata.name,
      //Blockchain.evrmoreMain.chaindata.name,
    ], roots: roots, h160s: h160s);
    return subscriptionVoid;
  }

  /// TODO: implement setupSubscription
  //Future<void> setupSubscription() async {
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
  //}

  void spoofNothing() {}
}
