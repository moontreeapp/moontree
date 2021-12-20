import 'dart:math';

double satToAmount(int x, {int divisibility = 8}) =>
    (x / divisor(divisibility));
int amountToSat(double x, {int divisibility = 8}) =>
    (x * divisor(divisibility)).floor().toInt();

int divisor(int divisibility) => int.parse('1' + ('0' * min(divisibility, 8)));
