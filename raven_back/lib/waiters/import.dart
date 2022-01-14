import 'waiter.dart';
import 'package:raven_back/services/import.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_back/raven_back.dart';

class ImportWaiter extends Waiter {
  void init() {
    streams.app.import.listen((ImportRequest? importRequest) async {
      print(importRequest);
      if (importRequest != null) {
        var importFrom = ImportFrom(
            text: importRequest.text, accountId: importRequest.accountId);
        var success = await importFrom.handleImport();
        // snackbar message - we should have a snack bar stream all that a widget on all pages listens to I guess...
        //confirmMessage(tx: tuple.item1, estimate: tuple.item2);

        /// TODO: move this to snackbar
        //await alertImported(importFrom.importedTitle!, importFrom.importedMsg!);
        print(success);
        if (success) {
          streams.app.snack.add(Snack(
              message: 'Sucessful Import', details: importFrom.importedMsg!));
        } else {
          streams.app.snack.add(Snack(
              message: 'Error Importing', details: importFrom.importedMsg!));
        }
        //if (success) {
        //  Navigator.popUntil(context, ModalRoute.withName('/home'));
        //} else {
        //  Navigator.of(context).pop();
        //}
      }
    });
  }
}
