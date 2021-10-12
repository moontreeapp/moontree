import 'package:flutter/widgets.dart';

Map<String, dynamic> populateData(BuildContext context, data) =>
    data != null && data.isNotEmpty
        ? data
        : ModalRoute.of(context)!.settings.arguments ?? {};

extension SumAList on List {
  //int get sumInt => reduce((a, b) => a + b);
  //int sumInt(List<int> l) =>
  //    l.fold(0, (previousValue, element) => previousValue + element);
  num sumInt() => fold(0, (previousValue, element) => previousValue + element);
}
