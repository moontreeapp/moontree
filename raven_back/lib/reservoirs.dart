import 'package:raven/reservoir/reservoir.dart';
import 'package:raven/reservoirs/account.dart';
import 'package:raven/reservoirs/address.dart';
import 'package:raven/reservoirs/conversion.dart';
import 'package:raven/models.dart' as models;
import 'package:raven/records.dart' as records;
import 'package:raven/reservoirs/history.dart';

late AccountReservoir<records.Account, models.Account> accounts;
late AddressReservoir<records.Address, models.Address> addresses;
late HistoryReservoir histories;
late ConversionRateReservoir rates;

Map<String, Reservoir> makeReservoirs() {
  accounts = AccountReservoir();
  addresses = AddressReservoir();
  histories = HistoryReservoir();
  rates = ConversionRateReservoir();
  return {'accounts': accounts, 'addresses': addresses, 'histories': histories};
}
