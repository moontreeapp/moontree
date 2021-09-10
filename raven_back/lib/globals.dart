import 'reservoirs/reservoirs.dart';
import 'services/services.dart';
import 'waiters/waiters.dart';

// RESERVOIRS

final AccountReservoir accounts = AccountReservoir();
final AddressReservoir addresses = AddressReservoir();
final HistoryReservoir histories = HistoryReservoir();
final WalletReservoir wallets = WalletReservoir();
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
final RatesService ratesService = RatesService(
    rates); // really convienent if services could refer to other services...
final LeaderWalletDerivationService leaderWalletDerivationService =
    LeaderWalletDerivationService(accounts, wallets, addresses, histories);
final SingleWalletService singleWalletService = SingleWalletService(accounts);
final SingleWalletGenerationService singleWalletGenerationService =
    SingleWalletGenerationService(wallets);
final LeaderWalletGenerationService leaderWalletGenerationService =
    LeaderWalletGenerationService(wallets);
final AccountGenerationService accountGenerationService =
    AccountGenerationService(accounts);
final SettingService settingsService = SettingService(settings);
final HistoryService historyService = HistoryService(histories);

// WAITERS

final AccountsWaiter accountsWaiter = AccountsWaiter(
  accounts,
  wallets,
  leaderWalletGenerationService,
);
final LeadersWaiter leadersWaiter = LeadersWaiter(
  wallets,
  addresses,
  leaderWalletDerivationService,
);
final SinglesWaiter singlesWaiter = SinglesWaiter(
  wallets,
  addresses,
  singleWalletService,
);
final AddressSubscriptionWaiter addressSubscriptionWaiter =
    AddressSubscriptionWaiter(
  addresses,
  addressSubscriptionService,
  leaderWalletDerivationService,
);
final AddressesWaiter addressesWaiter = AddressesWaiter(addresses, histories);

final ExchangeRateWaiter exchangeRateWaiter = ExchangeRateWaiter(ratesService);
final SettingsWaiter settingsWaiter = SettingsWaiter(settings, settingsService);
final BlockSubscriptionWaiter blockSubscriptionWaiter =
    BlockSubscriptionWaiter(blocks);
