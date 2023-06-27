import 'package:client_back/proclaim/proclaim.dart';
import 'package:client_back/server/src/protocol/comm_balance_view.dart';

extension OrNull on Iterable<String> {
  String? get firstOrNull => isEmpty ? null : first;
  String? get lastOrNull => isEmpty ? null : last;
}

extension FunctionsForBalanceView on BalanceView {
  int get sats => satsConfirmed + satsUnconfirmed;
  bool get isCoin => symbol == pros.settings.chainNet.symbol || chain == null;
  //chain == null ? true : false; Security(symbol: symbol, chain: chain, net: net);
}
