/// transaction details
import 'dart:typed_data';

import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart' as server;
import 'package:client_front/infrastructure/calls/mock_flag.dart';
import 'package:client_front/infrastructure/calls/server_call.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:moontree_utils/moontree_utils.dart';

class TransactionDetailsCall extends ServerCall {
  late Wallet wallet;
  final ByteData hash;
  late Chain chain;
  late Net net;

  TransactionDetailsCall({
    Wallet? wallet,
    required this.hash,
    Chain? chain,
    Net? net,
  }) : super() {
    this.chain = chain ?? Current.chain;
    this.net = net ?? Current.net;
    this.wallet = wallet ?? Current.wallet;
  }

  Future<server.TransactionDetailsView> transactionDetailsBy({
    required Chaindata chain,
    required ByteData hash,
  }) async =>
      await client.transactionDetails.get(hash: hash, chainName: chain.name);

  Future<server.TransactionDetailsView> call() async {
    final server.TransactionDetailsView tx = mockFlag

        /// MOCK SERVER
        ? await Future.delayed(Duration(seconds: 1), spoof)

        /// SERVER
        : await transactionDetailsBy(
            hash: hash, chain: ChainNet(chain, net).chaindata);

    if (tx.error != null) {
      return tx;
    }
    return tx;
  }
}

server.TransactionDetailsView spoof() {
  return server.TransactionDetailsView(
    //memo: null,
    memo: 'Qmb86hqUJNCUrpwukZtuWUqunL7GhrkwjZErmWNMbhf5HE'.base58ToByteData,
    containsAssets: 'ASSETNAME',
  );
}
