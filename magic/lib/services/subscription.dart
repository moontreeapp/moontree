import 'dart:async';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/domain/concepts/numbers/coin.dart';
import 'package:magic/domain/utils/extensions/string.dart';
import 'package:magic/domain/wallet/wallets.dart';
import 'package:magic/utils/log.dart';
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
  VoidCallback? onConnection;
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];

  SubscriptionService() : client = server.Client('$moontreeUrl/');

  Future<void> setupClient({
    required server.ConnectivityMonitor givenMonitor,
    VoidCallback? onConnection,
  }) async {
    this.onConnection = onConnection;
    client.connectivityMonitor = givenMonitor;
    client.connectivityMonitor?.addListener((connected) {
      if (!connected) {
        see('Disconnected, attempting to reconnect...');
        _attemptReconnect();
      }
    });
    await _setupConnection();
  }

  Future<void> _setupConnection() async {
    // Prevent multiple connection attempts
    if (cubits.app.state.connection == StreamingConnectionStatus.connected) {
      return;
    }

    await _cancelListeners();

    connectionHandler = StreamingConnectionHandler(
      client: client,
      retryEverySeconds: 1,
      listener: (StreamingConnectionHandlerState connectionState) async {
        see('connection state: ${connectionState.status.name}');
        cubits.app.update(connection: connectionState.status);
        if (connectionState.status == StreamingConnectionStatus.connected) {
          while (cubits.keys.master.derivationRoots.isEmpty) {
            see('waiting for keys', '---', AnsiColors.yellow);
            await Future.delayed(const Duration(seconds: 30));
          }
          see(
            cubits.keys.state.mnemonics.isEmpty,
            cubits.keys.master.derivationRoots,
            AnsiColors.green,
          );
          onConnection?.call();
          setupListeners();
        }
      },
    );
    see('connecting...', '', AnsiColors.green);

    connectionHandler.connect();
  }

  Future<void> _cancelListeners() async {
    for (final listener in listeners) {
      await listener.cancel();
    }
    listeners.clear();
  }

  Future<void> _attemptReconnect() async {
    connectionHandler.close();
    connectionHandler.connect();
    //await _cancelListeners(); // Clear previous listeners
    //await _setupConnection(); // Re-establish connection
  }

  Future<void> setupListeners() async {
    setupSubscriptions(cubits.keys.master);
    try {
      final subscription = client.subscription.stream
          .asBroadcastStream()
          .listen((message) async {
        /// # status means the state of the synchronizer (2 means up to date)
        /// examples:
        ///   {"id":null,"chainName":"evrmore_mainnet","status":2}
        ///   {"id":null,"chainName":"evrmore_mainnet","height":107222}
        // if height do x
        // if balance update do y, etc.
        see(message);
        if (message is protocol.NotifyChainStatus) {
        } else if (message is protocol.NotifyChainHeight) {
          if (message.height > 0) {
            cubits.app.update(blockheight: message.height);
          }
        } else if (message is protocol.NotifyChainH160Balance) {
          see('NotifyChainWalletBalance H160 update: ${message.symbol} ${message.satsConfirmed} ${message.satsUnconfirmed}');
          await triggerBalanceUpdates(
              symbol: message.symbol ??
                  message.chainName.split('_').first.toTitleCase(),
              satsConfirmed: message.satsConfirmed,
              satsUnconfirmed: message.satsUnconfirmed,
              chainName: message.chainName);
        } else if (message is protocol.NotifyChainWalletBalance) {
          see('NotifyChainWalletBalance Wallet update: ${message.symbol} ${message.satsConfirmed} ${message.satsUnconfirmed}');
          await triggerBalanceUpdates(
              symbol: message.symbol ??
                  message.chainName.split('_').first.toTitleCase(),
              satsConfirmed: message.satsConfirmed,
              satsUnconfirmed: message.satsUnconfirmed,
              chainName: message.chainName);
        } else {
          see('unknown subscription message: ${message.runtimeType}');
        }
      });
      // Add the subscription to the list of listeners to manage later
      listeners.add(subscription);
    } on StateError catch (e) {
      see('listeners already setup: $e');
    } catch (e) {
      see(e);
    }
  }

  Future<void> setupSubscriptions(MasterWallet master) async {
    final roots = <String>[];
    final h160s = <String>[];
    for (final derivationWallet in master.derivationWallets) {
      roots.addAll(derivationWallet.roots(Blockchain.ravencoinMain));
      roots.addAll(derivationWallet.roots(Blockchain.evrmoreMain));
    }
    for (final keypairWallet in master.keypairWallets) {
      h160s.add(keypairWallet.h160AsString(Blockchain.ravencoinMain));
      h160s.add(keypairWallet.h160AsString(Blockchain.evrmoreMain));
    }
    final subscriptionVoid = await specifySubscription(
      chains: Blockchain.mainnetNames,
      roots: roots.toSet().toList(),
      h160s: h160s.toSet().toList(),
    );
    return subscriptionVoid;
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
    } catch (e) {
      see('Failed to send subscription: $e');
      // Implement proper error handling
    }
  }

  Future<void> ensureConnected() async {
    if (connectionHandler.status.status ==
        StreamingConnectionStatus.connected) {
      return;
    }
    see('awaiting connection...');
    await _waitForConnection();
    return;
  }

  Future<void> _waitForConnection() async {
    int stillWaiting = 0;
    while (connectionHandler.status.status !=
        StreamingConnectionStatus.connected) {
      await Future.delayed(const Duration(seconds: 1));
      stillWaiting += 1;
      if (stillWaiting == 10) {
        cubits.toast.flash(
            msg: const ToastMessage(
                duration: Duration(seconds: 7),
                title: 'Connection Failed:',
                text: 'please check connection',
                force: false));
      }
    }
  }

  Future<void> triggerBalanceUpdates({
    required String symbol,
    required int satsConfirmed,
    required int satsUnconfirmed,
    required String chainName,
  }) async {
    see('triggerBalanceUpdates: $symbol, $satsConfirmed, $satsUnconfirmed, $chainName');
    final realSymbol = chainName.startsWith(symbol.toLowerCase())
        ? symbol == 'Evrmore'
            ? 'EVR'
            : 'RVN'
        : symbol;
    if (satsConfirmed + satsUnconfirmed > 0) {
      cubits.toast.flash(
          msg: ToastMessage(
        duration: const Duration(seconds: 7),
        title: 'Received $symbol:',
        text: '+${Coin.fromInt(satsConfirmed + satsUnconfirmed).humanString()}',
      ));
    }
    await Future.delayed(const Duration(seconds: 1));
    await cubits.wallet.populateAssets(); // chain specific
    see('refresh: $chainName, $symbol, ${cubits.holding.state.holding.symbol}, $realSymbol, ${cubits.transactions.state.active}');
    see(cubits.holding.state.holding);
    see('refreshing holding ${cubits.holding.state.holding.symbol} ${[
      for (final x in cubits.wallet.state.holdings) x.symbol
    ]}');
    if (cubits.holding.state.holding != const Holding.empty() &&
        cubits.wallet.state.holdings.isNotEmpty) {
      cubits.holding.update(
          holding: cubits.wallet
              .getHoldingFrom(holding: cubits.holding.state.holding));
    }
    if ( //cubits.holding.state.holding.symbol == realSymbol &&
        cubits.transactions.state.active) {
      cubits.transactions.clearTransactions();
      cubits.transactions
          .populateAllTransactions(holding: cubits.holding.state.holding);
    }
  }
}
