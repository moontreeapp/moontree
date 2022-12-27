/// a service to hit the serverv2 transactions endpoints: mempool and confirmed
/// compiles info to be sent to the endpoint, gets values for front end
/// rough draft:
/*
//import 'package:ravencoin_back/consent/consent_client.dart';
import 'dart:typed_data';

import 'package:ravencoin_back/joins/joins.dart';
import 'package:ravencoin_back/records/types/chain.dart';
import 'package:ravencoin_back/records/types/net.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:moontree_utils/moontree_utils.dart';

class TransactionHistory {
  TransactionHistory() : client = Client('$moontreeUrl/');
  static const String moontreeUrl = 'https://api.moontree.com';
  static const String textUrl = 'https://moontree.com';

  final Client client;

  List<TransactionView> transactionHistoryBy({
    String symbol,
    Chaindata chain,
    List<String> roots,
    List<ByteData> h160s,
  }) async =>
      client.transactionHistory.get(
        symbol: symbol,
        chain: chain,
        pubkeys: roots,
        addresses: h160s,
      );
}

Future<List<TransactionView>> discoverTransactionHistory(String symbol) async {
  final TransactionHistory transactionHistory = TransactionHistory();
  final roots = await Current.wallet.roots;
  final List<TransactionView> history =
      await transactionHistory.transactionHistoryBy(
          symbol: symbol,
          chain: getChaindataFor(Current.chain, Current.net),
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

*/