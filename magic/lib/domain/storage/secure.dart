/* a place to hold all the keys we use to store data on the device. */

enum SecureStorageKey {
  mnemonics,
  wifs,
  authed;

  String key([String? id]) {
    switch (this) {
      case SecureStorageKey.mnemonics:
        return 'mnemonics';
      case SecureStorageKey.wifs:
        return 'wifs';
      case SecureStorageKey.authed:
        return 'authed';
      default:
        return name;
    }
  }
}
