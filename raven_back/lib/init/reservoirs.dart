import 'package:raven/reservoirs.dart';

late AccountReservoir accounts;
late AddressReservoir addresses;
late HistoryReservoir histories;
late WalletReservoir wallets;
late BalanceReservoir balances;
late ExchangeRateReservoir rates;

void makeReservoirs() {
  accounts = AccountReservoir();
  addresses = AddressReservoir();
  histories = HistoryReservoir();
  wallets = WalletReservoir();
  rates = ExchangeRateReservoir();
}
