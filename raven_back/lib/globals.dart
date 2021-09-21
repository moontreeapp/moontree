import 'package:raven_electrum_client/raven_electrum_client.dart';

import 'reservoirs/reservoirs.dart';
import 'security/security.dart';
import 'waiters/waiters.dart';
import 'services/services.dart';

// Client

//final RavenElectrumClient ravenClient = await services.settings.createClient();

// CIPHERS

final CipherRegistry cipherRegistry = CipherRegistry();

// RESERVOIRS

final AccountReservoir accounts = AccountReservoir();
final AddressReservoir addresses = AddressReservoir(cipherRegistry);
final HistoryReservoir histories = HistoryReservoir();
final WalletReservoir wallets = WalletReservoir(cipherRegistry);
final BalanceReservoir balances = BalanceReservoir();
final ExchangeRateReservoir rates = ExchangeRateReservoir();
final SettingReservoir settings = SettingReservoir();
final BlockReservoir blocks = BlockReservoir();

// WAITERS

final AccountWaiter accountWaiter = AccountWaiter();
final AddressWaiter addressWaiter = AddressWaiter();
final AddressSubscriptionWaiter addressSubscriptionWaiter =
    AddressSubscriptionWaiter();
final BalanceWaiter balanceWaiter = BalanceWaiter();
final BlockWaiter blockWaiter = BlockWaiter();
final LeaderWaiter leaderWaiter = LeaderWaiter();
final RateWaiter rateWaiter = RateWaiter();
final SettingWaiter settingWaiter = SettingWaiter();
final SingleWaiter singleWaiter = SingleWaiter();
