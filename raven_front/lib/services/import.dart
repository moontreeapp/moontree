import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/wallet/constants.dart';
import 'package:raven_back/utils/hex.dart' as hexx;
import 'package:raven_front/services/lookup.dart';

class ImportFrom {
  late String text;
  late String accountId;
  late ImportFormat importFormat;
  late String? importedTitle;
  late String? importedMsg;

  ImportFrom(this.text, {importFormat, accountId})
      : this.importFormat =
            importFormat ?? services.wallet.import.detectImportType(text),
        this.accountId = accountId ?? Current.account.accountId;

  Future<bool> handleImport() async {
    var results = await services.wallet.import
        .handleImport(importFormat, text, accountId);
    for (var result in results) {
      importedMsg =
          Lingo.getEnglish(result.message).replaceAll('{0}', result.location);
      if (result.success) {
        importedTitle = 'Success!';
      } else {
        importedTitle = 'Unable to Import';
        break;
      }
    }
    return results
        .map((result) => result.success)
        .every((bool element) => element);
  }

  // returns null if unable to decrypt, otherwise, the decrypted String
  static String? maybeDecrypt({
    required String text,
    required CipherBase cipher,
  }) {
    var decrypted =
        services.password.required && text.contains(RegExp(r'^[a-fA-F0-9]+$'))
            ? hexx.hexToAscii(hexx.decrypt(text, cipher))
            : text;
    if (services.wallet.import.detectImportType(decrypted) == null) {
      return null;
    }
    return decrypted;
  }
}
