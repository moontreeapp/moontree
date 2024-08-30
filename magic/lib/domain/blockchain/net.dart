enum Net {
  main,
  test;

  String get symbolModifier {
    switch (this) {
      case Net.main:
        return '';
      case Net.test:
        return 't';
    }
  }

  //String get readable => 'net: $name';
}
