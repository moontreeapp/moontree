import 'package:raven/raven.dart';
import 'package:raven/services/wallet/constants.dart';
import 'package:raven/utils/transform.dart';
import 'package:raven_mobile/services/lookup.dart';

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
    //bool handleImport() {
    print('--------importFormat');
    print(importFormat);
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
    return all(results.map((result) => result.success));
  }
}
