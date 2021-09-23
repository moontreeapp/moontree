enum LingoKey {
  leaderWalletType,
  leaderWalletSecretType,
  singleWalletType,
  singleWalletSecretType,
  walletType,
  walletSecretType,
}

class Lingo {
  static Map<LingoKey, String> get english => {
        LingoKey.walletType: 'Wallet',
        LingoKey.walletSecretType: 'Secret',
        LingoKey.leaderWalletType: 'HD Wallet',
        LingoKey.leaderWalletSecretType: 'Mnemonic',
        LingoKey.singleWalletType: 'Private Key Wallet',
        LingoKey.singleWalletSecretType: 'Wallet Import Format',
      };
  static Map<LingoKey, String> get spanish => {
        LingoKey.walletType: 'Billetera',
        LingoKey.walletSecretType: 'Secreto',
        LingoKey.leaderWalletType: 'Billetera Determinista Herárquica',
        LingoKey.leaderWalletSecretType: 'Mnemotécnico',
        LingoKey.singleWalletType: 'Billetera de Clave Privada',
        LingoKey.singleWalletSecretType: 'Formato de Importación de Billetera',
      };

  // ideal
  //static String getLanguage(LingoKey key) => english[key]!;

  static String getEnglish(LingoKey key) => english[key]!;
  static String getSpanish(LingoKey key) => spanish[key]!;
}
