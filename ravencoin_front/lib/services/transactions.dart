/// a service to hit the serverv2 transactions endpoints: mempool and confirmed
/// compiles info to be sent to the endpoint, gets values for front end
/// rough draft:
/*
*/
//import 'package:ravencoin_back/consent/consent_client.dart';
import 'dart:typed_data';

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/server/serverv2_client.dart' as server;
import 'package:ravencoin_front/services/lookup.dart';
import 'package:moontree_utils/moontree_utils.dart';

class TransactionHistory {
  static const String moontreeUrl =
      'https://24.199.68.139'; //'https://api.moontree.com';
  final server.Client client;

  TransactionHistory() : client = server.Client('$moontreeUrl/');

  Future<List<server.TransactionView>> transactionHistoryBy({
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

Future<List<server.TransactionView>> discoverTransactionHistory({
  Wallet? wallet,
  String? symbol,
  Security? security,
}) async {
  final TransactionHistory transactionHistory = TransactionHistory();
  Chain chain = security?.chain ?? Current.chain;
  Net net = security?.net ?? Current.net;
  symbol ??= (security?.isCoin ?? true ? null : security?.symbol);
  symbol == pros.securities.coinOf(chain, net) ? null : symbol;
  final roots = await wallet?.roots ?? await Current.wallet.roots;
  final List<server.TransactionView> history =
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
Chaindata getChaindataFor(Chain chain, Net net) {
  if (chain == Chain.ravencoin) {
    if (net == Net.main) {
      return ravencoinMainnetChaindata;
    } else if (net == Net.test) {
      return ravencoinTestnetChaindata;
    }
  } else if (chain == Chain.evrmore) {
    if (net == Net.main) {
      return evrmoreMainnetChaindata;
    } else if (net == Net.test) {
      return evrmoreTestnetChaindata;
    }
  }
  return ravencoinMainnetChaindata;
}
