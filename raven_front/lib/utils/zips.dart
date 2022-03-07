Map zipMap(List names, List values) =>
    {for (int i = 0; i < names.length; i += 1) names[i]: values[i]};

List zipLists(List lists) => [
      for (int i = 0; i < lists.first.length; i += 1)
        [for (var list in lists) list[i]]
    ];

List<int> range(int end) => List<int>.generate(end, (i) => i + 1);

// alternative to quiver
//import 'package:collection/collection.dart';
    //{
    //  for (var pair in IterableZip([
    //      primaryNames + lightPrimaryNames, primaries + lightPrimaries]))
    //    pair[0] as int: pair[1] as Color
    //};