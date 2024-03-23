/// balances from electrum server to check against.

import 'package:client_back/records/types/chain.dart';
import 'package:client_back/services/eclient.dart';
import 'package:moontree_utils/moontree_utils.dart';

Future<int> getElectrumxBalancesInBackground({
  required List<String> scripthashes,
  Chain chain = Chain.ravencoin,
}) async {
  EClientService eClientService = EClientService();
  await eClientService.createClient(chain: chain);
  return (await eClientService.getBalances(scripthashes))
      .map((b) => b.value)
      .sumInt();
}
