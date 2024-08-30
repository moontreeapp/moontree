/* a place to hold all the keys we use to store data on the device. */

enum StorageKey {
  mnemonics,
  wifs,
  authed;

  String key([String? id]) {
    switch (this) {
      case StorageKey.mnemonics:
        return 'mnemonics';
      case StorageKey.wifs:
        return 'wifs';
      case StorageKey.authed:
        return 'authed';
      default:
        return name;
    }
  }
}
