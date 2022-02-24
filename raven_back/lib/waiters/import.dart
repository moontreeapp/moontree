import 'waiter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/import.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_back/streams/import.dart';

class ImportWaiter extends Waiter {
  void init() {
    streams.import.attempt.listen((ImportRequest? importRequest) async {
      if (importRequest != null) {
        services.busy.createWalletOn('importing wallet');
        await Future.delayed(const Duration(milliseconds: 250));
        var importFrom = ImportFrom(text: importRequest.text);
        if (await importFrom.handleImport()) {
          streams.app.snack.add(Snack(
              message: 'Sucessful Import', details: importFrom.importedMsg!));
        } else {
          streams.app.snack.add(Snack(
              message: 'Error Importing',
              details: importFrom.importedMsg!,
              positive: false));
        }
        streams.import.attempt.add(null);
        services.busy.createWalletOff('done importing wallet');
      }
    });
  }
}
