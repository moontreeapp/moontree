extension SumAList on List {
  num sum() => fold(0, (previousValue, element) => previousValue + element);
  int sumInt() => sum().toInt();
  double sumDouble() => sum().toDouble();
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
  String toTitleCase([bool underscoreAsSpace = false]) =>
      replaceAll(RegExp(' +'), ' ')
          // for enums especially:
          .replaceAll(underscoreAsSpace ? RegExp('_+') : ' ', ' ')
          .split(' ')
          .map((str) => str.toCapitalized())
          .join(' ');
}
