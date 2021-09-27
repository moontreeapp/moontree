Function mapGet(String key, Map<String, Function> map,
    {Function? defaultFunction}) {
  defaultFunction = defaultFunction ?? () {};
  if (map.containsKey(key)) {
    return map[key]!;
  }
  return defaultFunction;
}
