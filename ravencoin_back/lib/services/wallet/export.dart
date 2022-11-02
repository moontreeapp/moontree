/*
export json string example: 
{
  "wallets":{
    "03d992f22d9e178a4de02e99ffffe885bd5135e65d183200da3b566502eca79342":{
      "wallet name":"1",
      "wallet type":"Leader",
      "backed up":false,
      "secret":"c66dbb68916e32d273f415186507782fc14ade7cd0cb580bbba8d301db428a30a80377b0440c85a612b716395801f8d28dd31b97e603dd642a951c301305af5ea163e5bec7020557960f95e56e6d88e0",
      "secret type":"8bbd7639ec6288bcf700667f5b3817f1",
      "cipher encryption":{
        "CipherType":"AES",
        "PasswordId":"0"}}}}
*/

import 'package:ravencoin_back/ravencoin_back.dart';

import 'constants.dart';

import 'package:convert/convert.dart' as convert;
import 'package:ravencoin_back/utilities/hex.dart' as hex;

class ExportWalletService {
  /// entire file is encrypted
  /// export format:
  /// {
  ///   wallets: {wallets.id: values}
  /// }
  /// simply a json map with wallets as keys.
  /// values in our system is another map with id as key,
  /// other systems could use list or whatever.
  Future<Map<String, Map<String, dynamic>>> structureForExport(
    Iterable<Wallet> wallets,
  ) async =>
      {'wallets': await walletsToExportFormat(wallets)};

  Future<Map<String, Map<String, dynamic>>> walletsToExportFormat(
    Iterable<Wallet> wallets,
  ) async =>
      {
        for (final wallet in wallets) ...{
          wallet.id: {
            'wallet name': wallet.name,
            'wallet type': typeForExport(wallet),
            'backed up': wallet.backedUp,
            'secret': services.password.required
                ? hex.encrypt(
                    convert.hex.encode(
                        (await wallet.secret(wallet.cipher!)).codeUnits),
                    services.cipher.currentCipher!)
                : wallet.secret(wallet.cipher!), //encrypted,
            // For now:
            // Leaderwallets are always mnemonics
            // Singlewallets are always WIFs
            'secret type': services.password.required
                ? hex.encrypt(
                    convert.hex.encode(wallet.secretTypeToString.codeUnits),
                    services.cipher.currentCipher!)
                : wallet.secretTypeToString,
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
