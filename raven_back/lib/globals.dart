import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:rxdart/rxdart.dart';

import 'reservoirs/reservoirs.dart';
import 'security/security.dart';
import 'waiters/waiters.dart';

// Client

final ravenClientSubject = BehaviorSubject<RavenElectrumClient?>();

// CIPHERS

final CipherRegistry cipherRegistry = CipherRegistry();

// RESERVOIRS

final AccountReservoir accounts = AccountReservoir();
final AddressReservoir addresses = AddressReservoir();
final HistoryReservoir histories = HistoryReservoir();
final WalletReservoir wallets = WalletReservoir();
final BalanceReservoir balances = BalanceReservoir();
final ExchangeRateReservoir rates = ExchangeRateReservoir();
final SettingReservoir settings = SettingReservoir();
final BlockReservoir blocks = BlockReservoir();
final PasswordReservoir passwords = PasswordReservoir();

// WAITERS

final AccountWaiter accountWaiter = AccountWaiter();
final AddressWaiter addressWaiter = AddressWaiter();
final AddressSubscriptionWaiter addressSubscriptionWaiter =
    AddressSubscriptionWaiter();
final BalanceWaiter balanceWaiter = BalanceWaiter();
final BlockWaiter blockWaiter = BlockWaiter();
final RateWaiter rateWaiter = RateWaiter();
final RavenClientWaiter ravenClientWaiter = RavenClientWaiter();
final SettingWaiter settingWaiter = SettingWaiter();
// Wallets
final LeaderWaiter leaderWaiter = LeaderWaiter();
final SingleWaiter singleWaiter = SingleWaiter();

///we have to register ciphers before we register accounts...?
///E/flutter ( 5148): [ERROR:flutter/lib/ui/ui_dart_state.cc(209)] Unhandled Exception: Null check operator used on a null value
///E/flutter ( 5148): #0      CipherRegistry.currentCipher (package:raven/security/cipher_registry.dart:37:37)
///E/flutter ( 5148): #1      AccountWaiter.init (package:raven/waiters/account.dart:13:26)
///E/flutter ( 5148): #2      initWaiters (package:raven/init.dart:5:17)
///E/flutter ( 5148): #3      _LoadingState.setup (package:raven_mobile/pages/loading.dart:25:11)
///E/flutter ( 5148): <asynchronous suspension>