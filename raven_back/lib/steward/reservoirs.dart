import 'package:raven/reservoirs.dart';

class ReservoirsSteward /*extends Steward*/ {
  late final AccountReservoir accounts;
  late final AddressReservoir addresses;
  late final HistoryReservoir histories;
  late final WalletReservoir wallets;
  late final BalanceReservoir balances;
  late final ExchangeRateReservoir rates;

  ReservoirsSteward._();
  static final ReservoirsSteward _instance = ReservoirsSteward._();
  factory ReservoirsSteward() {
    return _instance;
  }

  set accounts(AccountReservoir accountsReservoir) =>
      accounts = accountsReservoir;

  set addresses(AddressReservoir addressesReservoir) =>
      addresses = addressesReservoir;

  set histories(HistoryReservoir historiesReservoir) =>
      histories = historiesReservoir;

  set wallets(WalletReservoir walletsReservoir) => wallets = walletsReservoir;

  set balances(BalanceReservoir balancesReservoir) =>
      balances = balancesReservoir;

  set rates(ExchangeRateReservoir exchangeRatesReservoir) =>
      rates = exchangeRatesReservoir;
}
