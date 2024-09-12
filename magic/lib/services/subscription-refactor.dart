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
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];

  SubscriptionService() : client = server.Client('$moontreeUrl/');

  Future<void> setupClient(server.ConnectivityMonitor givenMonitor) async {
    monitor = givenMonitor;
    client.connectivityMonitor = givenMonitor;

    monitor.addListener((connected) {
      if (!connected) {
        _attemptReconnect();
      }
    });

    await _setupConnection();
  }

  Future<void> _setupConnection() async {
    await _cancelListeners(); // Clear previous listeners

    connectionHandler = StreamingConnectionHandler(
      client: client,
      retryEverySeconds: 5,
      listener: (StreamingConnectionHandlerState connectionState) {
        see('connection state: ${connectionState.status.name}');
        cubits.app.update(connection: connectionState.status);
        if (connectionState.status == StreamingConnectionStatus.connected) {
          setupListeners();
        }
      },
    );

    connectionHandler.connect();
  }

  Future<void> _cancelListeners() async {
    for (final listener in listeners) {
      await listener.cancel();
    }
    listeners.clear();
  }

  Future<void> _attemptReconnect() async {
    await _cancelListeners(); // Clear previous listeners
    await _setupConnection(); // Re-establish connection
  }

  Future<void> setupListeners() async {
    final subscription = client.subscription.stream.listen((message) {
      see('subscription message: $message', message.runtimeType,
          LogColors.magenta);
    });
    listeners.add(subscription);
  }
}
