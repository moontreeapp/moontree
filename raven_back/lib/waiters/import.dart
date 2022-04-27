import 'waiter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/import.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_back/streams/import.dart';

class ImportWaiter extends Waiter {
  void init() {
    streams.import.attempt.listen((ImportRequest? importRequest) async {
      if (importRequest != null) {
        var firstWallet = false;
        await Future.delayed(const Duration(milliseconds: 250));
        if (res.wallets.data.length == 1 && streams.app.wallet.isEmpty.value) {
          await res.wallets.remove(res.wallets.data.first);
          firstWallet = true;
        }
        var importFrom = ImportFrom(text: importRequest.text);
        if (await importFrom.handleImport()) {
          if (firstWallet) {
            await res.settings.savePreferredWalletId(res.wallets.data.first.id);
            firstWallet = false;
          }
          // send user to see new wallet
          streams.import.success.add(null);
          streams.app.setting.add(null);
          streams.app.snack.add(Snack(message: 'Sucessful Import'));
        } else {
          // todo: recognize if it's an existing wallet already,
          //       currenlty it just errors in that case.
          streams.app.snack.add(Snack(
              message: 'Error Importing',
              //details: importFrom.importedMsg!, // good usecase for details
              positive: false));
        }
        streams.import.attempt.add(null);
      }
    });
  }
}
