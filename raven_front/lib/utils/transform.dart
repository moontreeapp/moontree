Map reverseMap(Map map) => {for (var e in map.entries) e.value: e.key};

List enumerate(String text) {
  return List<int>.generate(text.length, (i) => i + 1);
}

List characters(String text) {
  return text.split('');
}
