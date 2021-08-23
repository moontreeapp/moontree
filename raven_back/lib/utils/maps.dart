// https://pub.dev/documentation/collection/latest/collection/mergeMaps.html
Map<K, V> mergeMaps<K, V>(Map<K, V> map1, Map<K, V> map2,
    {V Function(V, V)? value}) {
  var result = Map<K, V>.of(map1);
  if (value == null) return result..addAll(map2);

  map2.forEach((key, mapValue) {
    result[key] =
        result.containsKey(key) ? value(result[key] as V, mapValue) : mapValue;
  });
  return result;
}
