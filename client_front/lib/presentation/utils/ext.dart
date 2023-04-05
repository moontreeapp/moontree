import 'package:client_back/server/src/protocol/comm_balance_view.dart';

extension OrNull on Iterable<String> {
  String? get firstOrNull => isEmpty ? null : first;
  String? get lastOrNull => isEmpty ? null : last;
}

extension FunctionsForBalanceView on BalanceView {
  int get sats => satsConfirmed + satsUnconfirmed;
}
