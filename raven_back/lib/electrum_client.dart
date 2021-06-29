import 'dart:async';

import 'electrum_client/client/subscribing_client.dart';
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
    registerSubscribable(Subscribable('blockchain.headers'));
    registerSubscribable(
        Subscribable('blockchain.scripthash', (params) => params.asList.first));
    registerSubscribable(
        Subscribable('blockchain.asset', (params) => params.asList.first));
  }

  Future<Map<String, dynamic>> features() async {
    var proc = 'server.features';
    return await request(proc);
  }
}
