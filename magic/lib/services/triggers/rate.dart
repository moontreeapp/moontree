import 'dart:async';

import 'package:magic/cubits/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/money/currency.dart' as currency;
import 'package:magic/domain/concepts/money/security.dart';
import 'package:magic/services/rate.dart';
import 'package:magic/domain/concepts/money/rate.dart';
import 'package:moontree_utils/moontree_utils.dart' show Trigger;

class RateWaiter extends Trigger {
  // eventually (once swaps matter) we should push this to the device rather than pull every 10 minutes
  static const Duration _rateWait = Duration(minutes: 10);
  Rate? usdRvnRate;

  void init(RVNtoFiat rvnRate) {
    _saveRate(rvnRate);
    when(
      thereIsA: Stream<dynamic>.periodic(_rateWait),
      doThis: (_) async => _saveRate(rvnRate), // only gets USD/RVN right now
    );
  }

  Future<double> _rate(RVNtoFiat rvnRate) async =>
      await rvnRate.get() ?? usdRvnRate?.rate ?? 0.0;

  Future<void> _save(double rate) async {
    usdRvnRate = Rate(
      base: const Security(symbol: 'RVN', blockchain: Blockchain.ravencoinMain),
      quote: currency.Currency.usd,
      rate: rate,
    );
    cubits.wallet.newRate(rate: usdRvnRate!);
  }

  Future<void> _saveRate(RVNtoFiat rvnRate) async =>
      _save(await _rate(rvnRate));
}
