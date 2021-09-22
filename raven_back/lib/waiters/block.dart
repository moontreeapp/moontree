/// this waiter subscribes to blockchain updates such as blockheaders
/// using electrum client.
/// if block headers was not a subscribe, but a function we could call on
/// demand I believe we could save the electrumx server some bandwidth costs...

import 'dart:async';

import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'package:raven/raven.dart';
import 'waiter.dart';

class BlockWaiter extends Waiter {
  final Map<String, StreamSubscription> subscriptionHandles = {};

  RavenElectrumClient? client;

  void init(RavenElectrumClient client) {
    this.client = client;
    subscribe();
  }

  void subscribe() {
    var stream = client!.subscribeHeaders();
    listeners.add(stream.listen((blockHeader) async =>
        await blocks.save(Block.fromBlockHeader(blockHeader))));
  }
}