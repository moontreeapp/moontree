import 'package:ravencoin_back/services/wallet/constants.dart';

import 'waiter.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/import.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/streams/import.dart';

class ImportWaiter extends Waiter {
  void init() {
    streams.import.attempt.listen((ImportRequest? importRequest) async {
      if (importRequest != null) {
        /// if import is currently occuring, wait til its finished.
        while (services.wallet.leader.newLeaderProcessRunning) {
          await Future.delayed(Duration(seconds: 10));
        }
        var firstWallet = false;
        if (pros.wallets.records.length == 1 &&
            streams.app.wallet.isEmpty.value) {
          await pros.wallets.remove(pros.wallets.records.first);
          firstWallet = true;
        }
        var importFrom = ImportFrom(text: importRequest.text);
        if (importFrom.importFormat != ImportFormat.invalid) {
          var tuple3 = await importFrom.handleImport(); // success, title, msg
          if (tuple3.item1) {
            if (firstWallet) {
              await pros.settings
                  .savePreferredWalletId(pros.wallets.records.first.id);
              firstWallet = false;
            }
            // send user to see new wallet
            streams.import.success.add(null);
            streams.import.result.add(importRequest);
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
        }
        streams.import.attempt.add(null);
      }
    });
  }
}
