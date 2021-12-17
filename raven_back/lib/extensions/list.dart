extension SumAList on List {
  num sum() => fold(0, (previousValue, element) => previousValue + element);
  int sumInt() => sum().toInt();
  double sumDouble() => sum().toDouble();
}
