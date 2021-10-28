const exportedLeaderType = 'Leader';
const exportedSingleType = 'Single';

enum ImportFormat {
  json,
  jsonWif,
  jsonMt,
  mnemonic12,
  mnemonic24, // valid for rvn?
  encryptedBip38, // 58?
  WIF,
  seed,
  privateKey,
}

enum WalletType {
  leader,
  single,
  none,
}
