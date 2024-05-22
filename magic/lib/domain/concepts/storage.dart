/* a place to hold all the keys we use to store data on the device. */

enum StorageKey {
  mnemonics,
  wifs,
  rate,
  cache;

  String key([String? id]) {
    switch (this) {
      case StorageKey.mnemonics:
        return 'mnemonics';
      case StorageKey.wifs:
        return 'wifs';
      case StorageKey.cache:
        return 'cache-$id';
      case StorageKey.rate:
        return 'rate-$id';
      default:
        return name;
    }
  }
}
