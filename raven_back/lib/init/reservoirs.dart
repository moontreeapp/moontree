import 'package:raven/reservoirs.dart';

// are does this make this file act as a singleton if imported?
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
  balances = BalanceReservoir();
  rates = ExchangeRateReservoir();
}
