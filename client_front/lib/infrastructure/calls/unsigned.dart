/// does this endpoint take into consideration the need to grab enough rvn for
/// the asset?
import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart' as server;
import 'package:client_front/infrastructure/calls/mock_flag.dart';
import 'package:client_front/infrastructure/calls/server_call.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart';

class UnsignedTransactionCall extends ServerCall {
  late Wallet wallet;
  late String? symbol;
  late Security? security;
  late FeeRate? feeRate;
  final int sats;
  final String address;
  late Chain chain;
  late Net net;

  UnsignedTransactionCall({
    Wallet? wallet,
    this.symbol,
    this.security,
    this.feeRate,
    required this.sats,
    required this.address,
    Chain? chain,
    Net? net,
  }) : super() {
    this.chain = chain ?? security?.chain ?? Current.chain;
    this.net = net ?? security?.net ?? Current.net;
    this.wallet = wallet ?? Current.wallet;
  }

  Future<server.UnsignedTransactionResult> unsignedTransactionBy({
    double? feeRateKb,
    required Chaindata chain,
    required List<String> roots,
    required List<String> h160s,
    required List<String> addresses,
    required List<String?> serverAssets,
    required List<int> satsToSend,
  }) async =>
      await client.unsignedTransaction.generateUnsignedTransaction(
          chainName: chain.name,
          request: server.UnsignedTransactionRequest(
            myH106s: h160s,
            myPubkeys: roots,
            feeRateKb: feeRateKb,
            eachOutputAddress: addresses,
            eachOutputAsset: serverAssets,
            eachOutputAmount: satsToSend,
          ));

  /// this simple version of the request handles sending one asset to one address.
  Future<server.UnsignedTransactionResult> call() async {
    final String? serverSymbol = ((security?.isCoin ?? true) &&
            (symbol == null ||
                symbol == pros.securities.coinOf(chain, net).symbol)
        ? null
        : security?.symbol ?? symbol);
    symbol ??= serverSymbol == null
        ? pros.securities.coinOf(chain, net).symbol
        : security?.symbol ?? symbol;

    List<String>? roots;
    List<String> h160s = [];
    if (wallet is LeaderWallet) {
      roots = await (wallet as LeaderWallet).roots;
    } else if (wallet is SingleWallet) {
      h160s = wallet.addresses.map((e) => e.h160).toList();
    }
    roots ??= await Current.wallet.roots;
    final server.UnsignedTransactionResult unsignedTx = mockFlag

        /// MOCK SERVER
        ? await Future.delayed(Duration(seconds: 1), spoof)

        /// SERVER
        : await unsignedTransactionBy(
            feeRateKb: feeRate?.rate ?? FeeRates.cheap.rate,
            addresses: [address],
            serverAssets: [serverSymbol],
            satsToSend: [sats],
            chain: ChainNet(chain, net).chaindata,
            roots: roots,
            h160s: h160s);

    //unsignedTx.chain = chain.name + '_' + net.name + 'net';
    //unsignedTx.symbol = symbol;

    return unsignedTx;
  }
}

server.UnsignedTransactionResult spoof() => server.UnsignedTransactionResult(
      rawHex: '0x00',
      vinPrivateKeySource: [''],
      vinLockingScriptType: [0],
    );
