import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/money/security.dart';
import 'package:magic/domain/concepts/transaction.dart';
import 'package:magic/domain/server/serverv2_client.dart';
import 'package:magic/domain/server/wrappers/unsigned_tx_result.dart';
import 'package:magic/domain/wallet/wallets.dart';
import 'package:magic/services/calls/server.dart';
import 'package:moontree_utils/moontree_utils.dart';

class UnsignedTransactionCall extends ServerCall {
  late List<MnemonicWallet> mnemonicWallets;
  late List<KeypairWallet> keypairWallets;
  late Blockchain blockchain;
  late String symbol;
  final String changeAddress;
  final String address;
  final int sats;
  final String? memo;
  UnsignedTransactionCall({
    required this.mnemonicWallets,
    required this.keypairWallets,
    required this.blockchain,
    required this.address,
    required this.sats,
    required this.symbol,
    required this.changeAddress,
    this.memo,
  });

  Future<List<UnsignedTransactionResult>> unsignedTransaction({
    double? feeRatePerByte,
    required Chaindata chain,
    required List<String> roots,
    required List<String> h160s,
    required List<String> addresses,
    required List<String?> serverAssets,
    required List<int> satsToSend,
  }) async =>
      await runCall(() async =>
          await client.unsignedTransaction.generateUnsignedTransaction(
              chainName: chain.name,
              request: UnsignedTransactionRequest(
                myH106s: h160s,
                myPubkeys: roots,
                feeRateKb:
                    feeRatePerByte == null ? null : feeRatePerByte * 1000,
                changeSource: changeAddress,
                eachOutputAddress: addresses,
                eachOutputAsset: serverAssets,
                eachOutputAmount: satsToSend,
                eachOutputAssetMemo: [for (final _ in addresses) null],
                eachOutputAssetMemoTimestamp: [for (final _ in addresses) null],
                opReturnMemo: memo == "" || memo == null
                    ? null
                    : memo!.utf8ToHex, // should be hex string
              )));

  Future<UnsignedTransactionResultCalled?> call() async {
    final String? serverSymbol = (blockchain.isCoin(symbol) ? null : symbol);
    final List<UnsignedTransactionResult> unsigned = await unsignedTransaction(
      chain: blockchain.chaindata,
      roots: mnemonicWallets
          .map((e) => e.roots(blockchain))
          .expand((e) => e)
          .toList(),
      h160s: keypairWallets.map((e) => e.h160AsString(blockchain)).toList(),
      addresses: [address],
      serverAssets: [serverSymbol],
      satsToSend: [sats],
    );

    if (unsigned.length == 1 && unsigned.first.error != null) {
      // handle
      return null;
    }

    return translate(unsigned, blockchain);
  }

  UnsignedTransactionResultCalled translate(
    List<UnsignedTransactionResult> records,
    Blockchain blockchain,
  ) =>
      UnsignedTransactionResultCalled(
        unsignedTransactionResults: records,
        mnemonicWallets: mnemonicWallets,
        keypairWallets: keypairWallets,
        blockchain: blockchain,
        address: address,
        sats: sats,
        symbol: symbol,
        changeAddress: changeAddress,
        memo: memo,
      );
}
