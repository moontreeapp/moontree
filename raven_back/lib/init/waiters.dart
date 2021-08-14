import 'package:raven/init/reservoirs.dart';
import 'package:raven/waiters.dart';

late BalanceWaiter balanceWaiter;
late AddressSubscriptionWaiter addressSubscriptionWaiter;
late RatesWaiter ratesWaiter;
late LeaderWalletDerivationWaiter leaderWalletDerivationWaiter;
late SingleWalletWaiter singleWalletWaiter;

void makeWaiters(
    //AccountReservoir accounts,
    //AddressReservoir addresses,
    //HistoryReservoir histories,
    //WalletReservoir wallets,
    //BalanceReservoir balances,
    //ExchangeRateReservoir rates,
    ) {
  balanceWaiter = BalanceWaiter(balances, histories);
  addressSubscriptionWaiter = AddressSubscriptionWaiter(balances, histories);
  ratesWaiter = RatesWaiter(balances, rates);
  leaderWalletDerivationWaiter =
      LeaderWalletDerivationWaiter(accounts, wallets, addresses, histories);
  singleWalletWaiter = SingleWalletWaiter(accounts);
}
