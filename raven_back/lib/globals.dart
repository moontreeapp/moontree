import 'reservoirs/reservoirs.dart';
import 'security/security.dart';
import 'waiters/waiters.dart';

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
