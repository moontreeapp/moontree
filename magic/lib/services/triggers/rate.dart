import 'dart:async';

import 'package:magic/cubits/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/money/currency.dart' as currency;
import 'package:magic/domain/concepts/money/security.dart';
import 'package:magic/domain/storage/secure.dart';
import 'package:magic/services/rate.dart';
import 'package:magic/domain/concepts/money/rate.dart';
import 'package:magic/services/services.dart';
import 'package:magic/utils/log.dart';
import 'package:moontree_utils/moontree_utils.dart' show Trigger;

class RateWaiter extends Trigger {
  final RateGrabber evrGrabber;
  final RateGrabber rvnGrabber;
  // eventually (once swaps matter) we should push this to the device rather than pull every 10 minutes
  static const Duration _rateWait = Duration(minutes: 10);
  Rate? rvnUsdRate;
  Rate? evrUsdRate;

  RateWaiter({required this.evrGrabber, required this.rvnGrabber});

  void init() {
    void saveRates() {
      _saveRate(evrGrabber);
      _saveRate(rvnGrabber);
    }

    saveRates();
    when(
      thereIsA: Stream<dynamic>.periodic(_rateWait),
      doThis: (_) async => saveRates(),
    );
  }

  Future<void> _saveRate(RateGrabber rateGrabber) async =>
      _save(rateGrabber: rateGrabber, rate: await _rate(rateGrabber));

  Future<double?> _getExistingRate(RateGrabber rateGrabber) async {
    Future<double?> fromCache() async => double.tryParse((await storage()).read(
            key: StorageKey.rate
                .key(_toRate(rateGrabber: rateGrabber, rate: 0)!.id)) ??
        '');

    switch (rateGrabber.symbol) {
      case 'EVR':
        return evrUsdRate?.rate ?? (await fromCache());
      case 'RVN':
        return rvnUsdRate?.rate ?? (await fromCache());
      default:
        return null;
    }
  }

  Future<double> _rate(RateGrabber rateGrabber) async =>
      (await rateGrabber.get()) ?? await _getExistingRate(rateGrabber) ?? 0;

  Future<double?> getRateOf(String symbol) async {
    if (symbol == 'EVR') {
      return await _rate(evrGrabber);
    }
    if (symbol == 'RVN') {
      return await _rate(rvnGrabber);
    }
    return null;
  }

  Rate? _toRate({required RateGrabber rateGrabber, required double rate}) {
    switch (rateGrabber.symbol) {
      case 'EVR':
        return Rate(
          rate: rate,
          quote: currency.Currency.usd,
          base: Security(
            symbol: rateGrabber.symbol,
            blockchain: Blockchain.evrmoreMain,
          ),
        );
      case 'RVN':
        return Rate(
          rate: rate,
          quote: currency.Currency.usd,
          base: Security(
            symbol: rateGrabber.symbol,
            blockchain: Blockchain.ravencoinMain,
          ),
        );
      default:
        return null;
    }
  }

  void _save({required RateGrabber rateGrabber, required double rate}) {
    see('saving ${rateGrabber.symbol}, rate: $rate');
    switch (rateGrabber.symbol) {
      case 'EVR':
        evrUsdRate = _toRate(rateGrabber: rateGrabber, rate: rate);
        cubits.wallet.newRate(rate: evrUsdRate!);
        return;
      case 'RVN':
        rvnUsdRate = _toRate(rateGrabber: rateGrabber, rate: rate);
        cubits.wallet.newRate(rate: rvnUsdRate!);
        return;
      default:
        return;
    }
  }
}
