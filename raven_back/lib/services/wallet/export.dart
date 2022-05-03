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
  Map<String, Map<String, dynamic>> structureForExport() =>
      {'wallets': walletsForExport()};

  Map<String, Map<String, dynamic>> walletsToExportFormat(
          Iterable<Wallet> wallets) =>
      {
        for (final wallet in wallets) ...{
          if (wallet.cipher != null)
            wallet.id: {
              'secret': wallet.secret(wallet.cipher!),
              'type': typeForExport(wallet),
              'cipherUpdate': wallet.cipherUpdate.toMap,
            }
        }
      };

  Map<String, Map<String, dynamic>> walletsForExport() =>
      walletsToExportFormat(res.wallets);

  String typeForExport(Wallet wallet) => wallet is LeaderWallet
      ? exportedLeaderType
      : wallet is SingleWallet
          ? exportedSingleType
          : throw ArgumentError('Wallet must be leader or single');
}
