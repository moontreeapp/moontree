/// here we verify that a transaction is what we though it should be
import 'package:tuple/tuple.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart'
    show satsPerCoin, parseSendAmountAndFeeFromSerializedTransaction;
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/transaction/maker.dart';

class FeeGuardException extends CustomException {
  FeeGuardException([String? message]) : super('FeeGuard', message);
}

class FeeGuard {
  const FeeGuard(this.tx, this.estimate);
  final String tx;
  final SendEstimate estimate;

  bool check() => explicit() && inferred() && calculated() && parsed();

  bool explicit() {
    if (estimate.fees > 2 * satsPerCoin) {
      throw FeeGuardException('Explicit fee is too large.');
    }
    return true;
  }

  bool inferred() {
    if (estimate.inferredTransactionFee > 2 * satsPerCoin) {
      throw FeeGuardException('Inferred fee is too large.');
    }
    return true;
  }

  bool calculated() {
    if (estimate.sendAll) {
      if (((estimate.security == null ||
                  estimate.security == pros.securities.currentCoin) &&
              estimate.utxoCoinTotal > estimate.total) ||
          ((estimate.security != null &&
                  estimate.security == pros.securities.currentCoin) &&
              estimate.utxoCoinTotal > estimate.total + estimate.changeDue)) {
        throw FeeGuardException(
            'total ins and total outs do not match during a send all transaction.');
      }
    }
    return true;
  }

  bool parsed() {
    final Map<String, Tuple2<String?, int>> cryptoAssetSatsByVinTxPos =
        <String, Tuple2<String?, int>>{};
    for (final Vout utxo in estimate.utxos) {
      cryptoAssetSatsByVinTxPos['${utxo.transactionId}:${utxo.position}'] =
          Tuple2<String?, int>(
              utxo.isAsset ? utxo.security!.symbol : null, utxo.coinValue);
    }
    final Tuple2<Map<String?, int>, int> result =
        parseSendAmountAndFeeFromSerializedTransaction(
      cryptoAssetSatsByVinTxPos,
      tx.hexDecode,
    );
    if (result.item2 > 2 * satsPerCoin) {
      throw FeeGuardException('Parsed fee too large.');
    }
    return true;
  }
}
