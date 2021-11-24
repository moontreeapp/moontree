import 'reservoirs/reservoirs.dart';
import 'waiters/waiters.dart';

// RESERVOIRS

final AccountReservoir accounts = AccountReservoir();
final AddressReservoir addresses = AddressReservoir();
final AssetReservoir assets = AssetReservoir();
final BlockReservoir blocks = BlockReservoir();
final BalanceReservoir balances = BalanceReservoir();
final CipherReservoir ciphers = CipherReservoir();
final MetadataReservoir metadata = MetadataReservoir();
final PasswordReservoir passwords = PasswordReservoir();
final ExchangeRateReservoir rates = ExchangeRateReservoir();
final SecurityReservoir securities = SecurityReservoir();
final SettingReservoir settings = SettingReservoir();
final TransactionReservoir transactions = TransactionReservoir();
final WalletReservoir wallets = WalletReservoir();
final VinReservoir vins = VinReservoir();
final VoutReservoir vouts = VoutReservoir();

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
