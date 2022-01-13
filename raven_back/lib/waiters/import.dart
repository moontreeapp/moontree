import 'waiter.dart';
import 'package:raven_back/services/import.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_back/raven_back.dart';

class ImportWaiter extends Waiter {
  void init() {
    streams.app.import.listen((ImportRequest? importRequest) {
      if (importRequest != null) {
        var importFrom = ImportFrom(
            text: importRequest.text, accountId: importRequest.accountId);
        // snackbar message - we should have a snack bar stream all that a widget on all pages listens to I guess...
        //confirmMessage(tx: tuple.item1, estimate: tuple.item2);

        /// TODO: move this to snackbar
        //var success = await importFrom.handleImport();
        //await alertImported(importFrom.importedTitle!, importFrom.importedMsg!);
        //if (success) {
        //  Navigator.popUntil(context, ModalRoute.withName('/home'));
        //} else {
        //  Navigator.of(context).pop();
        //}
      }
    });
  }
}
