import 'package:raven/init/reservoirs.dart';
import 'package:raven/services.dart';

late BalanceService balanceService;
late AddressSubscriptionService addressSubscriptionService;
late RatesService ratesService;
late LeaderWalletDerivationService leaderWalletDerivationService;
late SingleWalletService singleWalletService;
late LeaderWalletGenerationService leaderWalletGenerationService;
late AccountGenerationService accountGenerationService;

void makeServices() {
  balanceService = BalanceService(balances, histories);
  addressSubscriptionService = AddressSubscriptionService(balances, histories);
  ratesService = RatesService(balances, rates);
  leaderWalletDerivationService =
      LeaderWalletDerivationService(accounts, wallets, addresses, histories);
  singleWalletService = SingleWalletService(accounts);
  leaderWalletGenerationService = LeaderWalletGenerationService(wallets);
  accountGenerationService = AccountGenerationService(accounts);
}
