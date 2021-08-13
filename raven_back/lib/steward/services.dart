import 'package:raven/services.dart';

class ServicesSteward /*extends Steward*/ {
  // should these be final? they can get set again...
  late final LeadersService leadersService;
  late final SinglesService singlesService;
  late final AddressSubscriptionService addressSubscriptionService;
  late final AddressesService addressesService;
  late final AccountBalanceService accountBalanceService;
  late final ExchangeRateService exchangeRateService;

  ServicesSteward._();
  static final ServicesSteward _instance = ServicesSteward._();
  factory ServicesSteward() {
    return _instance;
  }

  set leadersService(LeadersService givenLeadersService) =>
      leadersService = givenLeadersService;

  set singlesService(SinglesService givenSinglesService) =>
      singlesService = givenSinglesService;

  set addressSubscriptionService(
          AddressSubscriptionService givenAddressSubscriptionService) =>
      addressSubscriptionService = givenAddressSubscriptionService;

  set addressesService(AddressesService givenAddressesService) =>
      addressesService = givenAddressesService;

  set accountBalanceService(AccountBalanceService givenAccountBalanceService) =>
      accountBalanceService = givenAccountBalanceService;

  set exchangeRateService(ExchangeRateService givenExchangeRateService) =>
      exchangeRateService = givenExchangeRateService;
}
