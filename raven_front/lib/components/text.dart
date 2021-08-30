import 'package:raven/init/reservoirs.dart' as res;

// in raven
String rvnUSDBalance(double balance) => balance == 0
    ? '\$ 0'
    : '\$ ${(balance * res.rates.rvnToUSD).toStringAsFixed(2)}';

int rvnAsSats(double amount) => (amount * 100000000).toInt();
double satsToRVN(int amount) => (amount / 100000000);

class RavenText {
  RavenText();

  static String rvnUSD(double balance) => rvnUSDBalance(balance);
  static int rvnSats(double amount) => rvnAsSats(amount);
  static double satsRVN(int amount) => satsToRVN(amount);
}
