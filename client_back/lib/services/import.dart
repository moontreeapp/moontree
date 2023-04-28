import 'package:tuple/tuple.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/services/wallet/constants.dart';

import 'wallet/import.dart';

class ImportFrom {
  ImportFrom({required this.text, ImportFormat? importFormat})
      : importFormat =
            importFormat ?? services.wallet.import.detectImportType(text);

  late String text;
  late ImportFormat importFormat;
  late String? importedTitle;
  late String? importedMsg;

  //Future<bool> handleImport() async {
  Future<Tuple3<List<bool>, List<String?>, List<String?>>> handleImport(
    Future<String> Function(String id)? getEntropy,
    Future<void> Function(Secret secret)? saveSecret,
  ) async {
    final List<HandleResult> results =
        await services.wallet.import.handleImport(
      importFormat,
      text,
      getEntropy,
      saveSecret,
    );
    final List<String?> importedTitles = <String?>[];
    final List<String?> importedMsgs = <String?>[];
    for (final HandleResult result in results) {
      importedMsg =
          Lingo.getEnglish(result.message).replaceAll('{0}', result.location);
      importedMsgs.add(importedMsg);
      if (result.success) {
        importedTitle = 'Success!';
        importedTitles.add(importedTitle);
      } else {
        importedTitle = 'Unable to Import';
        importedTitles.add(importedTitle);
        break;
      }
    }
    return Tuple3<List<bool>, List<String?>, List<String?>>(
        results.map((HandleResult result) => result.success).toList(),
        importedTitles,
        importedMsgs);
    //return results
    //    .map((result) => result.success)
    //    .every((bool element) => element);
  }

  // returns null if unable to decrypt, otherwise, the decrypted String
  static String maybeDecrypt({
    required String text,
    required CipherBase cipher,
  }) {
    final String decrypted =
        services.password.required && text.contains(RegExp(r'^[a-fA-F0-9]+$'))
            ? hexToAscii(decrypt(text, cipher))
            : text;
    return decrypted;
  }
}
