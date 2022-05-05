import 'package:raven_back/raven_back.dart';

import 'constants.dart';

import 'package:convert/convert.dart' as convert;
import 'package:raven_back/utilities/hex.dart' as hex;

class ExportWalletService {
  /// entire file is encrypted
  /// export format:
  /// {
  ///   wallets: {wallets.id: values}
  /// }
  /// simply a json map with wallets as keys.
  /// values in our system is another map with id as key,
  /// other systems could use list or whatever.
  Map<String, Map<String, dynamic>> structureForExport(
    Iterable<Wallet> wallets,
  ) =>
      {'wallets': walletsToExportFormat(wallets)};

  Map<String, Map<String, dynamic>> walletsToExportFormat(
    Iterable<Wallet> wallets,
  ) =>
      {
        for (final wallet in wallets) ...{
          wallet.id: {
            'wallet name': wallet.name,
            'wallet type': typeForExport(wallet),
            'backed up': wallet.backedUp,
            'secret': services.password.required
                ? hex.encrypt(convert.hex.encode(wallet.encrypted.codeUnits),
                    services.cipher.currentCipher!)
                : wallet.encrypted, //.secret(wallet.cipher!),
            'secret type': services.password.required
                ? hex.encrypt(convert.hex.encode(wallet.encrypted.codeUnits),
                    services.cipher.currentCipher!)
                : wallet.secretTypeToString,
            // For now:
            // Leaderwallets are always mnemonics
            // Singlewallets are always WIFs
            'cipher encryption': wallet.cipherUpdate.toMap,
          }
        }
      };

  String typeForExport(Wallet wallet) => wallet is LeaderWallet
      ? exportedLeaderType
      : wallet is SingleWallet
          ? exportedSingleType
          : throw ArgumentError('Wallet must be leader or single');
}
