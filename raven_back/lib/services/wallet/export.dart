import 'package:raven_back/raven_back.dart';

import 'constants.dart';

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
          Iterable<Wallet> wallets) =>
      {'wallets': walletsToExportFormat(wallets)};

  Map<String, Map<String, dynamic>> walletsToExportFormat(
          Iterable<Wallet> wallets) =>
      {
        for (final wallet in wallets) ...{
          wallet.id: {
            'secret': wallet.encrypted, //.secret(wallet.cipher!),
            // For now:
            // Leaderwallets are always mnemonics
            // Singlewallets are always WIFs
            'type': typeForExport(wallet),
            'cipherUpdate': wallet.cipherUpdate.toMap,
            'name': wallet.name,
            'backedUp': wallet.backedUp,
          }
        }
      };

  String typeForExport(Wallet wallet) => wallet is LeaderWallet
      ? exportedLeaderType
      : wallet is SingleWallet
          ? exportedSingleType
          : throw ArgumentError('Wallet must be leader or single');
}
