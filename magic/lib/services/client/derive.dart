/* balances from electrum server to check against. */

import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/services/client/electrumx.dart';
import 'package:moontree_utils/moontree_utils.dart';

Future<int> getElectrumxBalancesInBackground({
  required Iterable<String> scripthashes,
  Blockchain blockchain = Blockchain.evrmoreMain,
}) async {
  EClientService eClientService = EClientService();
  await eClientService.createClient(blockchain: blockchain);
  return (await eClientService.getBalances(scripthashes))
      .map((b) => b.value)
      .sumInt();
}
