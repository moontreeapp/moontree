import 'package:raven_back/raven_back.dart';

abstract class RateServiceInterface {
  double? get rvnToUSD;
}

class RateService implements RateServiceInterface {
  @override
  double? get rvnToUSD => res.rates.primaryIndex
      .getOne(res.securities.RVN, res.securities.USD)
      ?.rate;
}
