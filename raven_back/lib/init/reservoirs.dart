import 'package:raven/models.dart' as models;
import 'package:raven/records.dart' as records;
import 'package:raven/reservoirs.dart';

late AccountReservoir<records.Account, models.Account> accounts;
late AddressReservoir<records.Address, models.Address> addresses;
late HistoryReservoir histories;
late WalletReservoir wallets;
late BalanceReservoir balances;
late ConversionRateReservoir rates;

void makeReservoirs() {
  accounts = AccountReservoir();
  addresses = AddressReservoir();
  histories = HistoryReservoir();
  wallets = WalletReservoir();
  rates = ConversionRateReservoir();
}
