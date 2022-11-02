const exportedLeaderType = 'Leader';
const exportedSingleType = 'Single';

enum ImportFormat {
  json,
  jsonWif, // unused
  jsonMt, // unused
  mnemonic,
  encryptedBip38, //unused
  WIF,
  seed, // unused
  privateKey,
  masterKey,
  invalid,
}

enum WalletType {
  leader,
  single,
  none,
}
