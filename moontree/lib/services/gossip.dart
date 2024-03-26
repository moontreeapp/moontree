/* 
// neat, we can listen to cubit changes without BlockBuilder but I think 
// there's a simpler way, moving away from this pattern, putting BlockBuilder
// widgets for each cubit on the pane (or wherever) itself.

import 'dart:async';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/cubits/wallet/cubit.dart';
import 'package:moontree/presentation/ui/wallet/feed/page.dart';

class Gossip {
  final Map<String, StreamSubscription?> _subscriptions = {};

  Gossip() {
    _subscriptions[cubits.walletLayer.key] =
        cubits.walletLayer.stream.listen((WalletLayerState state) {
      print('GOSSIP WalletLayerCubit: ${state.active}');
      if (state.prior?.active == null && state.active) {
        print('wallet 1');
        cubits.pane.update(child: const WalletFeedPage());
      }
      if ((state.prior?.active == null || !state.prior!.active) &&
          !state.active) {
        print('wallet 2');
        cubits.pane.removeChildren();
      }
      if ((state.prior?.active == true) && !state.active) {
        print('wallet 3');
        cubits.pane.removeChildren();
      }
      print('wallet 4');
      cubits.pane.update(child: const WalletFeedPage());
    });
  }

  void cancelSubscriptions() =>
      _subscriptions.forEach((key, value) => value?.cancel());

  void cancelSubscription(String key) => _subscriptions[key]?.cancel();
}

*/