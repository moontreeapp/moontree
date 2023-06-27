/// does this endpoint take into consideration the need to grab enough rvn for
/// the asset?
import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart' as server;
import 'package:client_front/infrastructure/calls/mock_flag.dart';
import 'package:client_front/infrastructure/calls/server_call.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart';

class UnsignedReissueCall extends ServerCall {
  late Wallet wallet;
  late FeeRate? feeRate;
  final String? changeAddress;
  final String? memo;
  late Chain chain;
  late Net net;
  final String symbol;
  final bool reissuable;
  final int? divisibility;
  final int? quantity;
  final String? assetMemo;
  final String? verifierString;

  UnsignedReissueCall({
    Wallet? wallet,
    this.feeRate,
    this.changeAddress,
    this.memo,
    Chain? chain,
    Net? net,
    required this.symbol,
    required this.reissuable,
    this.divisibility,
    this.quantity,
    this.assetMemo,
    this.verifierString,
  }) : super() {
    this.chain = chain ?? Current.chain;
    this.net = net ?? Current.net;
    this.wallet = wallet ?? Current.wallet;
  }

  Future<server.UnsignedTransactionResult> unsignedReissueTransactionBy({
    double? feeRatePerByte,
    required Chaindata chain,
    required List<String> roots,
    required List<String> h160s,
  }) async =>
      await runCall(() async =>
          await client.reissueAsset.generateAssetReissueTransaction(
            chainName: chain.name,
            request: server.AssetReissueRequest(
              myH106s: h160s,
              myPubkeys: roots,
              feeRateKb: feeRatePerByte == null ? null : feeRatePerByte * 1000,
              changeSource: changeAddress,
              lockedUtxos: [], // for swaps, currently unused
              asset: symbol,
              reissuable: reissuable,
              divisibility: divisibility,
              amount: quantity!, // in sats
              verifierString: verifierString,
              // already decoded
              associatedData: assetMemo,
              // already encoded as hex string
              opReturnMemo: memo,
            ),
          ));

  /// this simple version of the request handles sending one asset to one address.
  Future<server.UnsignedTransactionResult> call() async {
    List<String>? roots;
    List<String> h160s = [];
    if (wallet is LeaderWallet) {
      roots = await (wallet as LeaderWallet).roots;
    } else if (wallet is SingleWallet) {
      h160s = [(await wallet.address).h160AsString];
    }
    roots ??= await Current.wallet.roots;
    final server.UnsignedTransactionResult unsignedTx = mockFlag

        /// MOCK SERVER
        ? await Future.delayed(Duration(seconds: 1), spoof)

        /// SERVER
        : await unsignedReissueTransactionBy(
            // send null to let the server choose
            feeRatePerByte: feeRate?.rate, // ?? FeeRates.cheap.rate
            chain: ChainNet(chain, net).chaindata,
            roots: roots,
            h160s: h160s,
          );

    //unsignedTx.chain = chain.name + '_' + net.name + 'net';
    //unsignedTx.symbol = symbol;

    return unsignedTx;
  }
}

server.UnsignedTransactionResult spoof() => server.UnsignedTransactionResult(
    rawHex: '0x00',
    vinPrivateKeySource: [''],
    vinLockingScriptType: [0],
    changeSource: [''],
    vinScriptOverride: [''],
    vinAmounts: [0],
    vinAssets: [''],
    targetFee: 0);
