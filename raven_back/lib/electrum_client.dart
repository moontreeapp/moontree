import 'dart:async';

import 'electrum_client/client/subscribing_client.dart';
import 'electrum_client/connect.dart' as conn;
import 'electrum_client/methods/server_version.dart';

export 'electrum_client/methods/features.dart';
export 'electrum_client/methods/get_balance.dart';
export 'electrum_client/methods/get_history.dart';
export 'electrum_client/methods/get_unspent.dart';
export 'electrum_client/methods/server_version.dart';

export 'electrum_client/connect.dart';

class Header {
  String hex;
  int height;
  Header(this.hex, this.height);
}

/// Methods on ElectrumClient are defined in the `methods` directory.
/// See https://electrumx-ravencoin.readthedocs.io/en/latest/protocol-methods.html
class ElectrumClient extends SubscribingClient {
  ElectrumClient(channel) : super(channel) {
    // registerSubscribable(Subscribable('blockchain.headers'));
    // registerSubscribable(
    //     Subscribable('blockchain.scripthash', (params) => params.asList.first));
    // registerSubscribable(
    //     Subscribable('blockchain.asset', (params) => params.asList.first));
  }

  static Future<ElectrumClient> connect(dynamic host,
      {port = 50002,
      connectionTimeout = conn.connectionTimeout,
      aliveTimerDuration = conn.aliveTimerDuration,
      acceptUnverified = true,
      clientName = 'MTWallet',
      protocolVersion = '1.8'}) async {
    var client = ElectrumClient(await conn.connect(host,
        port: port,
        connectionTimeout: connectionTimeout,
        aliveTimerDuration: aliveTimerDuration,
        acceptUnverified: acceptUnverified));
    await client.serverVersion(
        clientName: clientName, protocolVersion: protocolVersion);
    return client;
  }
}
