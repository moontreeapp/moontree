import 'waiter.dart';
import 'package:raven_back/services/import.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_back/raven_back.dart';

class ImportWaiter extends Waiter {
  void init() {
    streams.app.import.attempt.listen((ImportRequest? importRequest) async {
      if (importRequest != null) {
        services.busy.createWalletOn('importing wallet');
        await Future.delayed(const Duration(milliseconds: 250));
        var importFrom = ImportFrom(
            text: importRequest.text, accountId: importRequest.accountId);
        var success = await importFrom.handleImport();
        if (success) {
          streams.app.snack.add(Snack(
              message: 'Sucessful Import', details: importFrom.importedMsg!));
          streams.app.import.success.add(true);
        } else {
          streams.app.snack.add(Snack(
              message: 'Error Importing',
              details: importFrom.importedMsg!,
              positive: false));
          streams.app.import.success.add(false);
        }
        services.busy.createWalletOff('done importing wallet');
      }
    });
  }
}
