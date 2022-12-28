/// a service to hit the serverv2 transactions endpoints: mempool and confirmed
/// compiles info to be sent to the endpoint, gets values for front end
/// rough draft:
/*
*/
//import 'package:ravencoin_back/consent/consent_client.dart';
import 'dart:typed_data';

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/records/types/chain.dart' as typeChain;
import 'package:ravencoin_back/server/serverv2_client.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:moontree_utils/moontree_utils.dart';

class TransactionHistory {
  static const String moontreeUrl =
      'https://24.199.68.139'; //'https://api.moontree.com';
  final Client client;

  TransactionHistory() : client = Client('$moontreeUrl/');

  Future<List<TransactionView>> transactionHistoryBy({
    String? symbol,
    required Chaindata chain,
    required List<String> roots,
    required List<ByteData> h160s,
  }) async =>
      await client.transactions.get(
        symbol: symbol,
        chain: chain,
        xpubkeys: roots,
        h160s: h160s,
      );
}

Future<List<TransactionView>> discoverTransactionHistory({
  String? symbol,
  Security? security,
}) async {
  final TransactionHistory transactionHistory = TransactionHistory();
  typeChain.Chain chain = Current.chain;
  Net net = Current.net;
  if (security != null) {
    symbol ??= security.isCoin ? null : security.symbol;
    chain = security.chain;
    net = security.net;
  } else {
    symbol == pros.securities.coinOf(chain, net) ? null : symbol;
  }
  final roots = await Current.wallet.roots;
  final List<TransactionView> history =
      await transactionHistory.transactionHistoryBy(
          symbol: symbol,
          chain: getChaindataFor(chain, net),
          roots: roots,
          h160s: roots.isEmpty
              ? Current.wallet.addresses.map((e) => e.h160).toList()
              : []);
  return history;
}

/// convert chain and net to Chaindata
Chaindata getChaindataFor(typeChain.Chain chain, Net net) {
  if (chain == typeChain.Chain.ravencoin) {
    if (net == Net.main) {
      return ravencoinMainnetChaindata;
    } else if (net == Net.test) {
      return ravencoinTestnetChaindata;
    }
  } else if (chain == typeChain.Chain.evrmore) {
    if (net == Net.main) {
      return evrmoreMainnetChaindata;
    } else if (net == Net.test) {
      return evrmoreTestnetChaindata;
    }
  }
  return ravencoinMainnetChaindata;
}
