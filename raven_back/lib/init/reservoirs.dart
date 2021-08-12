import 'package:raven/reservoirs.dart';

late AccountReservoir accounts;
late AddressReservoir addresses;
late HistoryReservoir histories;
late LeaderWalletReservoir leaders;
late SingleWalletReservoir singles;
late BalanceReservoir balances;
late ExchangeRateReservoir rates;

void makeReservoirs() {
  accounts = AccountReservoir();
  addresses = AddressReservoir();
  histories = HistoryReservoir();
  leaders = LeaderWalletReservoir();
  singles = SingleWalletReservoir();
  rates = ExchangeRateReservoir();
}
