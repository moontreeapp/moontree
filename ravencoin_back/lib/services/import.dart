import 'package:tuple/tuple.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/wallet/constants.dart';

class ImportFrom {
  late String text;
  late ImportFormat importFormat;
  late String? importedTitle;
  late String? importedMsg;

  ImportFrom({required this.text, ImportFormat? importFormat})
      : importFormat =
            importFormat ?? services.wallet.import.detectImportType(text);

  //Future<bool> handleImport() async {
  Future<Tuple3<bool, List<String?>, List<String?>>> handleImport(
    Future<String> Function(String id)? getEntropy,
    Future<void> Function(Secret secret)? saveSecret,
  ) async {
    var results = await services.wallet.import.handleImport(
      importFormat,
      text,
      getEntropy,
      saveSecret,
    );
    var importedTitles = <String?>[];
    var importedMsgs = <String?>[];
    for (var result in results) {
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
    return Tuple3(
        results
            .map((result) => result.success)
            .every((bool element) => element),
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
    var decrypted =
        services.password.required && text.contains(RegExp(r'^[a-fA-F0-9]+$'))
            ? hexToAscii(decrypt(text, cipher))
            : text;
    return decrypted;
  }
}
