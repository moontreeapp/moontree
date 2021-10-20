import 'package:raven/raven.dart';
import 'package:raven/services/wallet/constants.dart';
import 'package:raven_mobile/services/lookup.dart';

class ImportFrom {
  late String text;
  late String accountId;
  late ImportFormat importFormat;
  late String? importedTitle;
  late String? importedMsg;

  ImportFrom(this.text, {importFormat, accountId})
      : this.importFormat =
            importFormat ?? services.wallets.import.detectImportType(text),
        this.accountId = accountId ?? Current.account.accountId;

  Future<bool> handleImport() async {
    var result = await services.wallets.import
        .handleImport(importFormat, text, accountId);
    if (result.success) {
      importedTitle = 'Success!';
    } else {
      importedTitle = 'Unable to Import';
    }
    importedMsg =
        Lingo.getEnglish(result.message).replaceAll('{0}', result.location);
    return result.success;
  }
}
