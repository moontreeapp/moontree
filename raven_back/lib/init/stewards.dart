import 'package:raven/reservoirs.dart';
import 'package:raven/services.dart';
import 'package:raven/stewards.dart';

void makeStewards() {
  ReservoirsSteward();
  ServicesSteward();
}

void fillReservoirsSteward(
  AccountReservoir accounts,
  AddressReservoir addresses,
  HistoryReservoir histories,
  WalletReservoir wallets,
  BalanceReservoir balances,
  ExchangeRateReservoir rates,
) {
  ReservoirsSteward().accounts = accounts;
  ReservoirsSteward().addresses = addresses;
  ReservoirsSteward().histories = histories;
  ReservoirsSteward().wallets = wallets;
  ReservoirsSteward().balances = balances;
  ReservoirsSteward().rates = rates;
}

void fillServicesSteward(
  LeadersService? leadersService,
  SinglesService? singlesService,
  AddressSubscriptionService? addressSubscriptionService,
  AddressesService? addressesService,
  AccountBalanceService? accountBalanceService,
  ExchangeRateService? exchangeRateService,
) {
  ServicesSteward().leadersService = leadersService!;
  ServicesSteward().singlesService = singlesService!;
  ServicesSteward().addressSubscriptionService = addressSubscriptionService!;
  ServicesSteward().addressesService = addressesService!;
  ServicesSteward().accountBalanceService = accountBalanceService!;
  ServicesSteward().exchangeRateService = exchangeRateService!;
}
