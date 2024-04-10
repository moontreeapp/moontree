List<int> range(int count, {int start = 0, int Function(int)? generator}) =>
    List<int>.generate(count, generator ?? (int i) => i + start);
