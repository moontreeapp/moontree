/// todo move to utils
extension OrNull on Iterable<String> {
  String? get firstOrNull => isEmpty ? null : first;
  String? get lastOrNull => isEmpty ? null : last;
}
