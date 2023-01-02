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
import 'package:wallet_utils/wallet_utils.dart';

class TransactionHistory {
  static const String moontreeUrl =
      'http://24.199.68.139:8080'; //'https://api.moontree.com';
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
        chain: chain.name,
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
  List<String>? roots;
  if (wallet is LeaderWallet) {
    roots = await wallet.roots;
    //} else if (wallet is SingleWallet) {
    //  roots = wallet.roots; ?? await Current.wallet.roots;
  }
  roots ??= await Current.wallet.roots;
  final List<server.TransactionView> history =

      /// MOCK SERVER
      //await Future.delayed(Duration(seconds: 5), spoofTransactionView);

      /// SERVER
      await transactionHistory.transactionHistoryBy(
          symbol: symbol,
          chain: ChainNet(chain, net).chaindata,
          roots: roots,
          h160s: roots.isEmpty
              ? Current.wallet.addresses.map((e) => e.h160).toList()
              : []);

  for (final txView in history) {
    txView.chain = chain.name + '_' + net.name + 'net';
    txView.symbol = symbol;
  }

  return history;
}

List<server.TransactionView> spoofTransactionView() {
  final views = <server.TransactionView>[
    server.TransactionView(
        // send transaction
        symbol: 'RVN',
        chain: 'ravencoin_mainnet',
        hash: ByteData(0),
        datetime: DateTime.now(),
        height: 0,
        fee: 1,
        vsize: 100,
        iProvided: 27 * satsPerCoin,
        //otherProvided: 4 * satsPerCoin,
        iReceived: 20 * satsPerCoin,
        //otherReceived: 10 * satsPerCoin,
        issueMainBurned: 0,
        reissueBurned: 0,
        issueSubBurned: 0,
        issueUniqueBurned: 0,
        issueMessageBurned: 0,
        issueQualifierBurned: 0,
        issueSubQualifierBurned: 0,
        issueRestrictedBurned: 0,
        addTagBurned: 0,
        burnBurned: 0),
    server.TransactionView(
        // send transaction
        symbol: 'RVN',
        chain: 'ravencoin_mainnet',
        hash: ByteData(0),
        datetime: DateTime.now(),
        height: 0,
        fee: 1,
        vsize: 100,
        iProvided: 27 * satsPerCoin,
        //otherProvided: 0,
        iReceived: 19 * satsPerCoin,
        //otherReceived: 7 * satsPerCoin,
        issueMainBurned: 0,
        reissueBurned: 0,
        issueSubBurned: 0,
        issueUniqueBurned: 0,
        issueMessageBurned: 0,
        issueQualifierBurned: 0,
        issueSubQualifierBurned: 0,
        issueRestrictedBurned: 0,
        addTagBurned: 0,
        burnBurned: 0),
    server.TransactionView(
        // receive
        symbol: 'RVN',
        chain: 'ravencoin_mainnet',
        hash: ByteData(0),
        datetime: DateTime.now(),
        height: 0,
        fee: 1,
        vsize: 100,
        iProvided: 1 * satsPerCoin,
        //otherProvided: 26 * satsPerCoin,
        iReceived: 26 * satsPerCoin,
        //otherReceived: 0,
        issueMainBurned: 0,
        reissueBurned: 0,
        issueSubBurned: 0,
        issueUniqueBurned: 0,
        issueMessageBurned: 0,
        issueQualifierBurned: 0,
        issueSubQualifierBurned: 0,
        issueRestrictedBurned: 0,
        addTagBurned: 0,
        burnBurned: 0),
    server.TransactionView(
        // sent to self
        symbol: 'RVN',
        chain: 'ravencoin_mainnet',
        hash: ByteData(0),
        datetime: DateTime.now(),
        height: 0,
        fee: 1,
        vsize: 100,
        iProvided: 27 * satsPerCoin,
        //otherProvided: 0,
        iReceived: 26 * satsPerCoin,
        //otherReceived: 0,
        issueMainBurned: 0,
        reissueBurned: 0,
        issueSubBurned: 0,
        issueUniqueBurned: 0,
        issueMessageBurned: 0,
        issueQualifierBurned: 0,
        issueSubQualifierBurned: 0,
        issueRestrictedBurned: 0,
        addTagBurned: 0,
        burnBurned: 0),
    server.TransactionView(
        // asset creation
        symbol: 'RVN',
        chain: 'ravencoin_mainnet',
        hash: ByteData(1),
        datetime: DateTime.now(),
        height: 1,
        fee: 1,
        vsize: 100,
        iProvided: 600 * satsPerCoin,
        //otherProvided: 0,
        iReceived: 99 * satsPerCoin,
        //otherReceived: 0,
        issueMainBurned: 500 * satsPerCoin,
        reissueBurned: 0,
        issueSubBurned: 0,
        issueUniqueBurned: 0,
        issueMessageBurned: 0,
        issueQualifierBurned: 0,
        issueSubQualifierBurned: 0,
        issueRestrictedBurned: 0,
        addTagBurned: 0,
        burnBurned: 0),
  ];

  return views + views;
}
