import 'package:equatable/equatable.dart';

import '../client/subscribing_client.dart';
import '../raven_electrum_client.dart';

class BlockHeader extends Equatable {
  final String hex;
  final int height;

  BlockHeader(this.hex, this.height);

  @override
  List<Object> get props => [hex, height];
}

extension SubscribeHeadersMethod on RavenElectrumClient {
  Stream<BlockHeader> subscribeHeaders() {
    var methodPrefix = 'blockchain.headers';

    // If this is the first time, register
    registerSubscribable(methodPrefix, 0);

    return subscribe(methodPrefix)
        .asyncMap((item) => BlockHeader(item['hex'], item['height']));
  }
}
