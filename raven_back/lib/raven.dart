import 'package:raven/reservoirs.dart';
import 'package:raven/services/accounts.dart';
import 'package:raven/services/address_subscription.dart';
import 'package:raven/services/addresses.dart';

void init() {
  makeReservoirs();
  AccountsService(accounts, addresses).init();
  AddressesService(accounts, addresses).init();
  AddressSubscriptionService(accounts, addresses, client);
}
