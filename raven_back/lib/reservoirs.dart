import 'package:raven/reservoirs/account.dart';
import 'package:raven/reservoirs/address.dart';
import 'package:raven/models.dart' as models;
import 'package:raven/records.dart' as records;
import 'package:raven/reservoirs/history.dart';
import 'package:raven/reservoirs/wallet.dart';

late WalletReservoir wallets;
late AccountReservoir<records.Account, models.Account> accounts;
late AddressReservoir<records.Address, models.Address> addresses;
late HistoryReservoir<records.History, models.History> histories;

void makeReservoirs() {
  wallets = WalletReservoir();
  accounts = AccountReservoir();
  addresses = AddressReservoir();
  histories = HistoryReservoir();
}
