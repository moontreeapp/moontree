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
        if (res.wallets.data.length == 1 && streams.app.wallet.isEmpty.value) {
          await res.wallets.remove(res.wallets.data.first);
          firstWallet = true;
        }
        var importFrom = ImportFrom(text: importRequest.text);
        var tuple3 = await importFrom.handleImport(); // success, title, msg
        if (tuple3.item1) {
          if (firstWallet) {
            await res.settings.savePreferredWalletId(res.wallets.data.first.id);
            firstWallet = false;
          }
          // send user to see new wallet
          streams.import.success.add(null);
          streams.app.setting.add(null);

          /// wait till balances show to show successful import...
          //streams.app.snack.add(Snack(message: 'Sucessful Import: downloading transactions'));
        } else if (tuple3.item3.isNotEmpty &&
            tuple3.item3.first != 'Success!') {
          streams.app.snack.add(Snack(
              message: tuple3.item3.firstWhere((element) => element != null)
                  //?.split(': ')
                  //.first
                  ??
                  'Error Importing',
              //details: importFrom.importedMsg!, // good usecase for details
              positive: true));
        } else {
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
