/// here we verify that a transaction is what we though it should be
import 'dart:typed_data';
import 'package:tuple/tuple.dart';
import 'package:convert/convert.dart' show hex;
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart'
    show satsPerCoin, parseSendAmountAndFeeFromSerializedTransaction;
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/records/records.dart';
import 'package:ravencoin_back/services/transaction/maker.dart';

class FeeGuardException extends CustomException {
  FeeGuardException([String? message]) : super('FeeGuard', message);
}

class FeeGuard {
  const FeeGuard(this.tx, this.estimate);
  final String tx;
  final SendEstimate estimate;

  bool check() => explicit() && inferred() && parsed();

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

  bool parsed() {
    final Map<String, Tuple2<String?, int>> inputs =
        <String, Tuple2<String?, int>>{};
    for (final Vout utxo in estimate.utxos) {
      //if (!utxo.isAsset) { // I don't think there's a need to filter down to the coin, but idk
      inputs['${utxo.transactionId}:${utxo.position}'] =
          Tuple2<String?, int>(null, utxo.coinValue);
      //}
    }
    final Tuple2<Map<String?, int>, int> result =
        parseSendAmountAndFeeFromSerializedTransaction(
      inputs,
      Uint8List.fromList(hex.decode(tx)),
    );
    if (result.item2 > 2 * satsPerCoin) {
      throw FeeGuardException('Parsed fee too large.');
    }
    return true;
  }
}
