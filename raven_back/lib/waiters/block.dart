/// this waiter subscribes to blockchain updates such as blockheaders
/// using electrum client.
/// if block headers was not a subscribe, but a function we could call on
/// demand I believe we could save the electrumx server some bandwidth costs...

import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'package:raven/raven.dart';
import 'waiter.dart';

class BlockWaiter extends Waiter {
  void init() {
    listen('subjects.client', subjects.client.stream, (ravenClient) {
      if (ravenClient == null) {
        deinitKey('ravenClient.subscribeHeaders');
      } else {
        subscribe(ravenClient as RavenElectrumClient);
      }
    });
  }

  void subscribe(RavenElectrumClient ravenClient) {
    try {
      listen(
          'ravenClient.subscribeHeaders',
          ravenClient.subscribeHeaders(),
          (blockHeader) async => await blocks
              .save(Block.fromBlockHeader(blockHeader! as BlockHeader)));
    } catch (e) {
      /*
      E/flutter ( 8787): [ERROR:flutter/lib/ui/ui_dart_state.cc(209)] Unhandled Exception: Concurrent modification during iteration: _LinkedHashMap len:0.
      E/flutter ( 8787): #0      _CompactIterator.moveNext (dart:collection-patch/compact_hash.dart:601:7)
      E/flutter ( 8787): #1      AddressSubscriptionWaiter.deinitSubscriptionHandles (package:raven/waiters/address_subscription.dart:30:46)  
      E/flutter ( 8787): <asynchronous suspension>
      E/flutter ( 8787): #2      AddressSubscriptionWaiter.setupClientListener.<anonymous closure> (package:raven/waiters/address_subscription.dart:39:9)
      E/flutter ( 8787): <asynchronous suspension>
      E/flutter ( 8787): 
      E/flutter ( 8787): [ERROR:flutter/lib/ui/ui_dart_state.cc(209)] Unhandled Exception: Already listening: ravenClient.subscribeHeaders already listening
      E/flutter ( 8787): #0      Waiter.listen (package:raven/waiters/waiter.dart:16:7)
      E/flutter ( 8787): #1      BlockWaiter.subscribe (package:raven/waiters/block.dart:23:5)
      E/flutter ( 8787): #2      BlockWaiter.init.<anonymous closure> (package:raven/waiters/block.dart:17:9)       
      E/flutter ( 8787): #3      _rootRunUnary (dart:async/zone.dart:1436:47)
      E/flutter ( 8787): #4      _CustomZone.runUnary (dart:async/zone.dart:1335:19)
      E/flutter ( 8787): #5      _CustomZone.runUnaryGuarded (dart:async/zone.dart:1244:7)
      E/flutter ( 8787): #6      _BufferingStreamSubscription._sendData (dart:async/stream_impl.dart:341:11)        
      E/flutter ( 8787): #7      _BufferingStreamSubscription._add (dart:async/stream_impl.dart:271:7)
      E/flutter ( 8787): #8      _MultiStreamController.addSync (dart:async/stream_impl.dart:1129:36)
      E/flutter ( 8787): #9      _MultiControllerSink.add (package:rxdart/src/utils/forwarding_stream.dart:135:35)  
      E/flutter ( 8787): #10     _StartWithStreamSink.onData (package:rxdart/src/transformers/start_with.dart:12:31)
      E/flutter ( 8787): #11     _rootRunUnary (dart:async/zone.dart:1436:47)
      E/flutter ( 8787): #12     _CustomZone.runUnary (dart:async/zone.dart:1335:19)
      E/flutter ( 8787): #13     _CustomZone.runUnaryGuarded (dart:async/zone.dart:1244:7)
      E/flutter ( 8787): #14     _BufferingStreamSubscription._sendData (dart:async/stream_impl.dart:341:11)        
      E/flutter ( 8787): #15     _DelayedData.perform (dart:async/stream_impl.dart:591:14)
      E/flutter ( 8787): #16     _StreamImplEvents.handleNext (dart:async/stream_impl.dart:706:11)
      E/flutter ( 8787): #17     _PendingEvents.schedule.<anonymous closure> (dart:async/stream_impl.dart:663:7)    
      E/flutter ( 8787): #18     _rootRun (dart:async/zone.dart:1420:47)
      E/flutter ( 8787): #19     _CustomZone.run (dart:async/zone.dart:1328:19)
      E/flutter ( 8787): #20     _CustomZone.runGuarded (dart:async/zone.dart:1236:7)
      E/flutter ( 8787): #21     _CustomZone.bindCallbackGuarded.<anonymous closure> (dart:async/zone.dart:1276:23) 
      E/flutter ( 8787): #22     _rootRun (dart:async/zone.dart:1428:13)
      E/flutter ( 8787): #23     _CustomZone.run (dart:async/zone.dart:1328:19)
      E/flutter ( 8787): #24     _CustomZone.runGuarded (dart:async/zone.dart:1236:7)
      E/flutter ( 8787): #25     _CustomZone.bindCallbackGuarded.<anonymous closure> (dart:async/zone.dart:1276:23) 
      E/flutter ( 8787): #26     _microtaskLoop (dart:async/schedule_microtask.dart:40:21)
      E/flutter ( 8787): #27     _startMicrotaskLoop (dart:async/schedule_microtask.dart:49:5)
      */
    }

    // update existing mempool transactions each block
    listen<Change<Block>>('blocks.changes', blocks.changes, (change) {
      services.address.getAndSaveMempoolTransactions();
    });
  }
}
