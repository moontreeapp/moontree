/// An Electrum client for RavenCoin.
///
/// Connects with https://github.com/Electrum-RVN-SIG/electrumx-ravencoin
library raven_electrum_client;

import 'dart:async';

import 'connect.dart' as conn;
import 'client/subscribing_client.dart';
import 'methods/server_version.dart';

export 'methods/features.dart';
export 'methods/get_balance.dart';
export 'methods/server_stats.dart';
export 'methods/get_transaction.dart';
export 'methods/get_memo.dart';
export 'methods/get_history.dart';
export 'methods/get_unspent.dart';
export 'methods/server_version.dart';

export 'subscriptions/subscribe_headers.dart';
export 'subscriptions/subscribe_asset.dart';
export 'subscriptions/subscribe_scripthash.dart';

export 'connect.dart';

class Header {
  String hex;
  int height;
  Header(this.hex, this.height);
}

/// Methods on RavenElectrumClient are defined in the `methods` directory.
/// See https://electrumx-ravencoin.readthedocs.io/en/latest/protocol-methods.html
class RavenElectrumClient extends SubscribingClient {
  RavenElectrumClient(channel) : super(channel);
  String clientName = 'MTWallet';
  String host = '';
  String protocolVersion = '1.9';
  int port = 50002;

  static Future<RavenElectrumClient> connect(dynamic host,
      {port = 50002,
      connectionTimeout = conn.connectionTimeout,
      aliveTimerDuration = conn.aliveTimerDuration,
      acceptUnverified = true,
      clientName = 'MTWallet',
      protocolVersion = '1.9'}) async {
    var client = RavenElectrumClient(await conn.connect(host,
        port: port,
        connectionTimeout: connectionTimeout,
        aliveTimerDuration: aliveTimerDuration,
        acceptUnverified: acceptUnverified));
    client.clientName = clientName;
    client.host = host;
    client.protocolVersion = protocolVersion;
    client.port = port;
    await client.serverVersion(
        clientName: clientName, protocolVersion: protocolVersion);
    return client;
  }

  @override
  String toString() => 'RavenElectrumClient connected to $host:$port';
}
