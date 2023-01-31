/// a service to hit the serverv2 transactions endpoints: mempool and confirmed
/// compiles info to be sent to the endpoint, gets values for front end
/// rough draft:
/*
*/
//import 'package:client_back/consent/consent_client.dart';
import 'dart:typed_data';

import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart' as server;
import 'package:client_front/infrastructure/calls/mock_flag.dart';
import 'package:client_front/infrastructure/calls/server_call.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart';

class TransactionHistoryCall extends ServerCall {
  late Wallet wallet;
  late String? symbol;
  late Security? security;
  final int? height;
  late Chain chain;
  late Net net;
  TransactionHistoryCall({
    Wallet? wallet,
    this.symbol,
    this.security,
    this.height,
    Chain? chain,
    Net? net,
  }) : super() {
    this.wallet = wallet ?? Current.wallet;
    this.chain = chain ?? security?.chain ?? Current.chain;
    this.net = net ?? security?.net ?? Current.net;
  }

  Future<List<server.TransactionView>> transactionHistoryBy({
    String? symbol,
    int? height,
    required Chaindata chain,
    required List<String> roots,
    required List<ByteData> h160s,
  }) async =>
      await client.transactions.get(
        symbol: symbol,
        backFromHeight: height,
        chainName: chain.name,
        xpubkeys: roots,
        h160s: h160s,
      );

  Future<List<server.TransactionView>> call() async {
    final String? serverSymbol = ((security?.isCoin ?? true) &&
            (symbol == null ||
                symbol == pros.securities.coinOf(chain, net).symbol)
        ? null
        : security?.symbol ?? symbol);
    symbol ??= serverSymbol == null
        ? pros.securities.coinOf(chain, net).symbol
        : security?.symbol ?? symbol;

    List<String>? roots;
    if (wallet is LeaderWallet) {
      roots = await wallet.roots;
      //} else if (wallet is SingleWallet) {
      //  roots = wallet.roots; ?? await Current.wallet.roots;
    }
    roots ??= await Current.wallet.roots;
    final List<server.TransactionView> history = mockFlag

        /// MOCK SERVER
        ? await Future.delayed(Duration(seconds: 1), spoof)

        /// SERVER
        : await transactionHistoryBy(
            symbol: serverSymbol,
            height: height,
            chain: ChainNet(chain, net).chaindata,
            roots: roots,
            h160s: roots.isEmpty
                ? Current.wallet.addresses.map((e) => e.h160).toList()
                : []);

    if (history.length == 1 && history.first.error != null) {
      // handle
      return [];
    }

    for (final txView in history) {
      txView.chain = chain.name + '_' + net.name + 'net';
      txView.symbol = symbol;
    }

    return history;
  }
}

List<server.TransactionView> spoof() {
  final views = <server.TransactionView>[
    server.TransactionView(
        // send transaction
        symbol: null,
        chain: null,
        containsAssets: false,
        consolidation: true,
        hash: ByteData(0),
        datetime: DateTime.now(),
        height: 0,
        fee: 500000,
        vsize: 100,
        iProvided: 27 * satsPerCoin,
        //otherProvided: 4 * satsPerCoin,
        iReceived: 2699500000,
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
        symbol: null,
        chain: null,
        containsAssets: false,
        consolidation: true,
        hash: ByteData(0),
        datetime: DateTime.now(),
        height: 0,
        fee: 1 * satsPerCoin,
        vsize: 100,
        iProvided: 27 * satsPerCoin,
        //otherProvided: 4 * satsPerCoin,
        iReceived: 27 * satsPerCoin,
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
        symbol: null,
        chain: null,
        containsAssets: false,
        consolidation: false,
        hash: ByteData(0),
        datetime: DateTime.now(),
        height: 0,
        //10 decimal package has a problem here. instead of 0.0000001 we get 0.00000001
        fee: 1,
        vsize: 100,
        iProvided: 27000 * satsPerCoin,
        //otherProvided: 0,
        iReceived: 19000 * satsPerCoin,
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
        symbol: null,
        chain: null,
        containsAssets: false,
        consolidation: false,
        hash: ByteData(0),
        datetime: DateTime.now(),
        height: 0,
        fee: 266000,
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
        symbol: null,
        chain: null,
        containsAssets: false,
        consolidation: false,
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
        symbol: null,
        chain: null,
        containsAssets: true,
        consolidation: true,
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
