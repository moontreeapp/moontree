import 'package:flutter/material.dart';
import 'package:raven/init/reservoirs.dart' as res;
import 'package:raven_mobile/theme/extensions.dart';

Text rvnUSDBalance(context, int balance) =>
    Text('\n\$ ${balance * res.rates.rvnToUSD}',
        style: Theme.of(context).textTheme.headline3);

class RavenText {
  RavenText();

  static Text rvnUSD(context, balance) => rvnUSDBalance(context, balance);
}
