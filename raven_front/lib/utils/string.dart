List enumerate(String text) {
  return List<int>.generate(text.length, (i) => i + 1);
}

List characters(String text) {
  return text.split('');
}
