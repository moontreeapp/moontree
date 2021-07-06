/// An Electrum client for RavenCoin.
///
/// Connects with https://github.com/Electrum-RVN-SIG/electrumx-ravencoin
library raven_electrum_client;

import 'dart:async';

import 'client/subscribing_client.dart';
import 'connect.dart' as conn;
import 'methods/server_version.dart';

export 'methods/features.dart';
export 'methods/get_balance.dart';
export 'methods/get_history.dart';
export 'methods/get_unspent.dart';
export 'methods/server_version.dart';

export 'connect.dart';

class Header {
  String hex;
  int height;
  Header(this.hex, this.height);
}

/// Methods on RavenElectrumClient are defined in the `methods` directory.
/// See https://electrumx-ravencoin.readthedocs.io/en/latest/protocol-methods.html
class RavenElectrumClient extends SubscribingClient {
  RavenElectrumClient(channel) : super(channel) {
    // registerSubscribable(Subscribable('blockchain.headers'));
    // registerSubscribable(
    //     Subscribable('blockchain.scripthash', (params) => params.asList.first));
    // registerSubscribable(
    //     Subscribable('blockchain.asset', (params) => params.asList.first));
  }

  static Future<RavenElectrumClient> connect(dynamic host,
      {port = 50002,
      connectionTimeout = conn.connectionTimeout,
      aliveTimerDuration = conn.aliveTimerDuration,
      acceptUnverified = true,
      clientName = 'MTWallet',
      protocolVersion = '1.8'}) async {
    var client = RavenElectrumClient(await conn.connect(host,
        port: port,
        connectionTimeout: connectionTimeout,
        aliveTimerDuration: aliveTimerDuration,
        acceptUnverified: acceptUnverified));
    await client.serverVersion(
        clientName: clientName, protocolVersion: protocolVersion);
    return client;
  }
}
