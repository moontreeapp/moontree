enum LingoKey {
  leaderWalletType,
  leaderWalletSecretType,
  singleWalletType,
  singleWalletSecretType,
  walletType,
  walletSecretType,
  walletImportedAs,
  walletAlreadyExists,
  walletUnableToCreate,
}

class Lingo {
  static Map<LingoKey, String> get english => {
        LingoKey.walletType: 'Wallet',
        LingoKey.walletSecretType: 'Secret',
        LingoKey.leaderWalletType: 'HD Wallet',
        LingoKey.leaderWalletSecretType: 'Mnemonic',
        LingoKey.singleWalletType: 'Private Key Wallet',
        LingoKey.singleWalletSecretType: 'Wallet Import Format',
        LingoKey.walletImportedAs: 'Successfully imported as {0}.',
        LingoKey.walletAlreadyExists: 'Wallet already exists as {0}',
        LingoKey.walletUnableToCreate:
            'Wallet was unable to be created for an unknown reason...',
      };
  static Map<LingoKey, String> get spanish => {
        LingoKey.walletType: 'Billetera',
        LingoKey.walletSecretType: 'Secreto',
        LingoKey.leaderWalletType: 'Billetera Determinista Herárquica',
        LingoKey.leaderWalletSecretType: 'Mnemotécnico',
        LingoKey.singleWalletType: 'Billetera de Clave Privada',
        LingoKey.singleWalletSecretType: 'Formato de Importación de Billetera',
        LingoKey.walletImportedAs: 'Wallet successfully imported: {0}.',
        LingoKey.walletAlreadyExists: 'Wallet already exists: {0}',
        LingoKey.walletUnableToCreate:
            'Wallet was unable to be created for an unknown reason...',
      };

  // ideal
  //static String getLanguage(LingoKey key) => english[key]!;

  static String getEnglish(LingoKey key) => english[key]!;
  static String getSpanish(LingoKey key) => spanish[key]!;
}
