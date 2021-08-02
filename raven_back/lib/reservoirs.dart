import 'package:raven/reservoir/reservoir.dart';
import 'package:raven/reservoirs/addresses.dart';
import 'package:raven/models.dart' as models;
import 'package:raven/records.dart' as records;

late Reservoir<records.Account, models.Account> accounts;
late AddressReservoir<records.Address, models.Address> addresses;
late Reservoir<records.History, models.History> histories;

void makeReservoirs() {
  accounts =
      Reservoir(HiveBoxSource('accounts'), (account) => account.accountId);
  histories =
      Reservoir(HiveBoxSource('histories'), (histories) => histories.txHash)
        ..addIndex('account', (history) => history.accountId)
        ..addIndex('scripthash', (history) => history.scripthash);
  addresses = AddressReservoir(
      HiveBoxSource('addresses'), (address) => address.scripthash);
}
