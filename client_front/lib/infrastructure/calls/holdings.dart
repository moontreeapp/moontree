/// a service to hit the serverv2 transactions endpoints: mempool and confirmed
/// compiles info to be sent to the endpoint, gets values for front end
/// rough draft:
/*
*/
//import 'package:client_back/consent/consent_client.dart';
import 'dart:typed_data';

import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart' as server;
import 'package:client_back/server/src/protocol/comm_balance_view.dart';
import 'package:client_front/infrastructure/calls/mock_flag.dart';
import 'package:client_front/infrastructure/calls/server_call.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:collection/collection.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart';

class HoldingBalancesCall extends ServerCall {
  late Wallet wallet;
  late Chain chain;
  late Net net;
  HoldingBalancesCall({
    Wallet? wallet,
    Chain? chain,
    Net? net,
  }) : super() {
    this.chain = chain ?? Current.chain;
    this.net = net ?? Current.net;
    this.wallet = wallet ?? Current.wallet;
  }

  Future<List<server.BalanceView>> holdingBalancesBy({
    //server.BalanceView
    required Chaindata chain,
    required List<String> roots,
    required List<ByteData> h160s,
  }) async {
    print('h160s: $chain');
    print('h160s: $h160s');
    print('roots: $roots');
    //xpub6EtVexS6kuhFVjQNB1qGSUGumEnQVF3xp3926wy92W4GJS7ymvhbWkVzBTjXQ4u8EixkRXmE8N538zei6kCdAyZkWKcZBZ7BSdYm9uNPn9i
    //xpub6EtVexS6kuhFZ22PBCWPC97VNkZ9vufPdrTp2ZDDApasumxt8f8CREs4Zv6nDdFKByp8BPZ5tFFj6ZG4eeerNkDM7mJ2PZfBDeB5LjdRiXY
    return await runCall(() async => await client.balances.get(
          chainName: chain.name,
          xpubkeys: roots,
          h160s: h160s,
        ));
  }

  Future<List<server.BalanceView>> call() async {
    List<String>? roots;
    if (wallet is LeaderWallet) {
      roots = await (wallet as LeaderWallet).roots;
      //} else if (wallet is SingleWallet) {
      //  roots = wallet.roots; ?? await Current.wallet.roots;
    }
    roots ??= await Current.wallet.roots;
    final List<server.BalanceView> history = mockFlag

        /// MOCK SERVER
        ? await Future.delayed(Duration(seconds: 1), spoof)

        /// SERVER
        : await holdingBalancesBy(
            chain: ChainNet(chain, net).chaindata,
            roots: roots,
            h160s: roots.isEmpty
                ? [
                    (await (Current.wallet as SingleWallet).address)
                        .h160AsByteData
                  ]
                : []);

    if (history.length == 1 && history.first.error != null) {
      // handle
      return history;
    }

    for (final txView in history) {
      txView.chain = chain.name + '_' + net.name + 'net';
    }
    print('history: $history');
    return sortedHoldings(history, chain.symbol);
  }

  List<BalanceView> sortedHoldings(List<BalanceView> records, String coin) {
    // coin
    final head = records.where((e) => e.symbol == coin).toList();

    // alphabetical by display name (tail of symbol)
    final tail = records
        .where((e) => e.symbol != coin)
        .sorted((a, b) => b.symbol.compareTo(a.symbol))
        .toList();
    return head + tail;
  }
}

List<server.BalanceView> spoof() {
  return <server.BalanceView>[
    server.BalanceView(
        symbol: 'RVN',
        chain: null,
        satsConfirmed: 10 * satsPerCoin,
        satsUnconfirmed: 1),
    server.BalanceView(
        symbol: 'MOONTREE',
        chain: null,
        satsConfirmed: 10 * satsPerCoin,
        satsUnconfirmed: 0),
    server.BalanceView(
        symbol: 'EVR',
        chain: null,
        satsConfirmed: 10 * satsPerCoin,
        satsUnconfirmed: 0),
    server.BalanceView(
        symbol: 'SATORI',
        chain: null,
        satsConfirmed: 10 * satsPerCoin,
        satsUnconfirmed: 0),
    server.BalanceView(
        symbol: 'XYZ',
        chain: null,
        satsConfirmed: 10 * satsPerCoin,
        satsUnconfirmed: 0),
    server.BalanceView(
        symbol: 'Scam',
        chain: null,
        satsConfirmed: 10 * satsPerCoin,
        satsUnconfirmed: 0),
    server.BalanceView(
        symbol: '1RVN',
        chain: null,
        satsConfirmed: 10 * satsPerCoin,
        satsUnconfirmed: 0),
    server.BalanceView(
        symbol: '1MOON',
        chain: null,
        satsConfirmed: 10 * satsPerCoin,
        satsUnconfirmed: 0),
    server.BalanceView(
        symbol: '1ABC',
        chain: null,
        satsConfirmed: 10 * satsPerCoin,
        satsUnconfirmed: 0),
    server.BalanceView(
        symbol: '1DEF',
        chain: null,
        satsConfirmed: 10 * satsPerCoin,
        satsUnconfirmed: 0),
    server.BalanceView(
        symbol: '1XYZ',
        chain: null,
        satsConfirmed: 10 * satsPerCoin,
        satsUnconfirmed: 0),
    server.BalanceView(
        symbol: '1Scam',
        chain: null,
        satsConfirmed: 10 * satsPerCoin,
        satsUnconfirmed: 0),
  ];
}
