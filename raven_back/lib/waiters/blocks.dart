/// this waiter subscribes to blockchain updates such as blockheaders
/// using electrum client.
/// if block headers was not a subscribe, but a function we could call on
/// demand I believe we could save the electrumx server some bandwidth costs...

import 'dart:async';

import 'package:raven/records/records.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/waiters/waiter.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

class BlockSubscriptionWaiter extends Waiter {
  final BlockReservoir blocks;
  final Map<String, StreamSubscription> subscriptionHandles = {};

  RavenElectrumClient? client;

  BlockSubscriptionWaiter(this.blocks) : super();

  void init(RavenElectrumClient client) {
    this.client = client;
    subscribe();
  }

  void subscribe() {
    var stream = client!.subscribeHeaders();
    listeners.add(stream.listen(
        (blockHeader) => blocks.save(Block.fromBlockHeader(blockHeader))));
  }
}
