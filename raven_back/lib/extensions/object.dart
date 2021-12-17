extension DescribeEnum on Object {
  String get enumString {
    var description = toString();
    var indexOfDot = description.indexOf('.');
    assert(
      indexOfDot != -1 && indexOfDot < description.length - 1,
      'The provided object "$this" is not an enum.',
    );
    return description.substring(indexOfDot + 1);
  }
}
