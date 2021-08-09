import 'package:raven/records.dart' as records;
import 'package:raven/models/rate.dart';
import 'package:raven/reservoir/index.dart';
import 'package:raven/reservoir/reservoir.dart';

// I think this will eventually hold lots of exchange rates,
// not just RVN to USD or other Fiat but assets to RVN and well.
class ConversionRateReservoir extends Reservoir<String, records.Rate, Rate> {
  late MultipleIndex byFrom;
  late MultipleIndex byTo;
  late MultipleIndex byRate;
  late MultipleIndex byFiat;

  ConversionRateReservoir() : super(HiveSource('conversion')) {
    var paramsToKey = (from, to, rate, fiat) => '$from:$to:$rate:$fiat';
    addPrimaryIndex(
        (rate) => paramsToKey(rate.from, rate.to, rate.rate, rate.fiat));

    byFrom = addMultipleIndex('from', (rate) => rate.from);
    byTo = addMultipleIndex('to', (rate) => rate.to);
    byRate = addMultipleIndex('rate', (rate) => rate.rate.toString());
    byFiat = addMultipleIndex('fiat', (rate) => rate.fiat.toString());
  }

  double get rvnToUSD => byTo
      .getOne('usd')
      .where((rate) => rate.from == '' && rate.fiat == true)
      .rate;

  double rvnToFiat(String fiat) {
    return byFrom
        .getOne('')
        .where((rate) => rate.to == fiat && rate.fiat == true)
        .rate;
  }

  double assetToRVN(String ticker) {
    return byTo
        .getOne('')
        .where((rate) => rate.from == ticker && rate.fiat == false)
        .rate;
  }
}
