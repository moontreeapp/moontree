import 'package:raven/reservoirs.dart';
import 'package:raven/services/accounts.dart';
import 'package:raven/services/address_subscription.dart';
import 'package:raven/services/addresses.dart';

void init() {
  makeReservoirs();
  var accountService = AccountsService(accounts, addresses, histories);
  accountService.init();
  AddressesService(accounts, addresses).init();
  AddressSubscriptionService(
      accounts, addresses, histories, client, accountService);
}
