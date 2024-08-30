extension NumericSum on Iterable<dynamic> {
  double sumNumbers() => where((element) => element != null && element is num)
      .map((element) => element as double)
      .fold(0, (previousValue, element) => previousValue + element);
}
