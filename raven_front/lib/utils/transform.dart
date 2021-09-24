// returns a map who's values are altered according to a new map.
Map mapMap(Map map, Map mapmap, {bool onKey = false}) => {
      for (var e in map.entries)
        e.key: mapmap[onKey ? e.key : e.value] ?? e.value
    };

List enumerate(String text) {
  return List<int>.generate(text.length, (i) => i + 1);
}

List characters(String text) {
  return text.split('');
}

bool stringIsInt(String text) {
  try {
    int.parse(text);
    return true;
  } catch (e) {
    return false;
  }
}
