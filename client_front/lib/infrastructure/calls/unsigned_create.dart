/// does this endpoint take into consideration the need to grab enough rvn for
/// the asset?
import 'package:client_back/client_back.dart';
import 'package:client_back/server/serverv2_client.dart' as server;
import 'package:client_front/infrastructure/calls/mock_flag.dart';
import 'package:client_front/infrastructure/calls/server_call.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart';

class UnsignedCreateCall extends ServerCall {
  late Wallet wallet;
  late FeeRate? feeRate;
  final String? changeAddress;
  final String? memo;
  late Chain chain;
  late Net net;
  final SymbolType symbolType;
  final String symbol;
  final bool reissuable;
  final String? parentSymbol;
  final int? divisibility;
  final int? quantity;
  final String? assetMemo;
  final String? verifierString;

  UnsignedCreateCall({
    Wallet? wallet,
    this.feeRate,
    this.changeAddress,
    this.memo,
    Chain? chain,
    Net? net,
    required this.symbolType,
    required this.symbol,
    required this.reissuable,
    this.parentSymbol,
    this.divisibility,
    this.quantity,
    this.assetMemo,
    this.verifierString,
  }) : super() {
    this.chain = chain ?? Current.chain;
    this.net = net ?? Current.net;
    this.wallet = wallet ?? Current.wallet;
  }

  Future<server.UnsignedTransactionResult> unsignedCreateTransactionBy({
    double? feeRatePerByte,
    required Chaindata chain,
    required List<String> roots,
    required List<String> h160s,
  }) async =>
      await runCall(() async =>
          await client.createAsset.generateAssetCreationTransaction(
            chainName: chain.name,
            request: server.AssetCreationRequest(
              myH106s: h160s,
              myPubkeys: roots,
              feeRateKb: feeRatePerByte == null ? null : feeRatePerByte * 1000,
              changeSource: changeAddress,
              lockedUtxos: [], // for swaps, currently unused
              assetType: (SymbolType symbolType) {
                switch (symbolType) {
                  case SymbolType.main:
                    return 0;
                  case SymbolType.sub:
                    return 1;
                  case SymbolType.unique:
                    return 2;
                  case SymbolType.channel:
                    return 3;
                  case SymbolType.qualifier:
                    return 4;
                  case SymbolType.qualifierSub:
                    return 5;
                  case SymbolType.restricted:
                    return 6;
                  default:
                    return 0;
                }
              }(symbolType),
              asset: symbol,
              reissuable: reissuable,
              parentAsset: parentSymbol,
              divisibility: divisibility,
              amount: quantity!, // in sats
              verifierString: verifierString,
              associatedData: assetMemo == "" || assetMemo == null
                  ? null
                  : assetMemo!.utf8ToHex,
              opReturnMemo: memo == "" || memo == null
                  ? null
                  : memo!.utf8ToHex, // should be hex string
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
        : await unsignedCreateTransactionBy(
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
