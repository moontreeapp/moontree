import 'package:raven/init/reservoirs.dart';
import 'package:raven/services.dart';

late BalanceService balanceService;
late AddressSubscriptionService addressSubscriptionService;
late RatesService ratesService;
late LeaderWalletDerivationService leaderWalletDerivationService;
late SingleWalletService singleWalletService;

void makeServices(
    //AccountReservoir accounts,
    //AddressReservoir addresses,
    //HistoryReservoir histories,
    //WalletReservoir wallets,
    //BalanceReservoir balances,
    //ExchangeRateReservoir rates,
    ) {
  balanceService = BalanceService(balances, histories);
  addressSubscriptionService = AddressSubscriptionService(balances, histories);
  ratesService = RatesService(balances, rates);
  leaderWalletDerivationService =
      LeaderWalletDerivationService(accounts, wallets, addresses, histories);
  singleWalletService = SingleWalletService(accounts);
}
