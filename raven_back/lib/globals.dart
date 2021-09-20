import 'reservoirs/reservoirs.dart';
import 'services/services.dart';
import 'security/security.dart';
import 'waiters/waiters.dart';

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

// SERVICES

final AccountsService accountService =
    AccountsService(accounts, wallets, settings);
final BalanceService balanceService = BalanceService(balances, histories);
final AddressSubscriptionService addressSubscriptionService =
    AddressSubscriptionService(balances, histories);
final RatesService ratesService = RatesService(rates);
final LeaderWalletDerivationService leaderWalletDerivationService =
    LeaderWalletDerivationService(accounts, wallets, addresses, histories);
final SingleWalletService singleWalletService = SingleWalletService(accounts);
final SingleWalletGenerationService singleWalletGenerationService =
    SingleWalletGenerationService(wallets, accounts);
final LeaderWalletGenerationService leaderWalletGenerationService =
    LeaderWalletGenerationService(wallets);
final AccountGenerationService accountGenerationService =
    AccountGenerationService(accounts);
final SettingService settingsService = SettingService(settings);
final HistoryService historyService = HistoryService(histories);

// WAITERS

final WalletBalanceWaiter walletBalanceWaiter = WalletBalanceWaiter(
  wallets,
  histories,
  balanceService,
);
final AccountsWaiter accountsWaiter = AccountsWaiter(
  cipherRegistry,
  accounts,
  wallets,
  leaderWalletGenerationService,
);
final LeadersWaiter leadersWaiter = LeadersWaiter(
  cipherRegistry,
  wallets,
  addresses,
  leaderWalletDerivationService,
);
final SinglesWaiter singlesWaiter = SinglesWaiter(
  cipherRegistry,
  wallets,
  addresses,
  singleWalletService,
);
final AddressSubscriptionWaiter addressSubscriptionWaiter =
    AddressSubscriptionWaiter(
  cipherRegistry,
  addresses,
  addressSubscriptionService,
  leaderWalletDerivationService,
);
final AddressesWaiter addressesWaiter = AddressesWaiter(addresses, histories);
final ExchangeRateWaiter exchangeRateWaiter = ExchangeRateWaiter(ratesService);
final SettingsWaiter settingsWaiter = SettingsWaiter(settings, settingsService);
final BlockSubscriptionWaiter blockSubscriptionWaiter =
    BlockSubscriptionWaiter(blocks);
