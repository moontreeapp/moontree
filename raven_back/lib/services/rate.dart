import 'package:raven_back/raven_back.dart';

class RateService {
  double? get rvnToUSD => res.rates.primaryIndex
      .getOne(res.securities.RVN, res.securities.USD)
      ?.rate;
}
