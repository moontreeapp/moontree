/// derives subwallets (address) when a wallet shows up empty

import 'dart:async';

import 'package:reservoir/reservoir.dart';

import 'package:raven/raven.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'waiter.dart';

/// new wallet -> if empty derive x number of wallets per exposure

class WalletWaiter extends Waiter {
  Set<Address> backlogAddressCipher = {};

  void setupCipherListener() {
    listen('subjects.cipher.stream', subjects.cipher.stream, (cipher) async {
      // listen to the wallets
      // on new
      //  if it doesn't have 20 (empty) addresses
      //  make new ones
      // put in address subscription:
      // listen to subscriptions, when address is filled, derive a new one
      //  if (backlogAddressCipher.isNotEmpty) {
      //    backlogAddressCipher = (await services.wallets.leaders
      //            .maybeDeriveNewAddresses(backlogAddressCipher.toList()))
      //        .toSet();
      //  }
    });
  }

  void init() {
    setupCipherListener();
  }
}
