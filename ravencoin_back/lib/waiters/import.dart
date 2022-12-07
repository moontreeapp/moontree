import 'package:ravencoin_back/services/wallet/constants.dart';
import 'package:tuple/tuple.dart';

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
        int x = 0;
        while (services.wallet.leader.newLeaderProcessRunning && x < 10) {
          await Future<void>.delayed(const Duration(seconds: 1));
          x += 1;
        }
        bool firstWallet = false;
        if (pros.wallets.records.length == 1 && pros.balances.records.isEmpty) {
          /// don't remove just set it as preferred.
          //await pros.wallets.remove(pros.wallets.records.first);
          firstWallet = true;
        }
        final ImportFrom importFrom = ImportFrom(text: importRequest.text);
        if (importFrom.importFormat != ImportFormat.invalid) {
          streams.client.busy.add(true);
          final Tuple3<bool, List<String?>, List<String?>> tuple3 =
              await importFrom.handleImport(
            importRequest.getEntropy,
            importRequest.saveSecret,
          ); // success, title, msg
          if (tuple3.item1) {
            if (firstWallet) {
              await pros.settings
                  .savePreferredWalletId(pros.wallets.records.first.id);
              firstWallet = false;
            }
            // send user to see new wallet
            services.wallet.leader.newLeaderProcessRunning = true;
            streams.import.success.add(null);
            // instead of broadcasting original importRequest which has the sensitive text, we'll just broadcast an empty one since all the login on this merely looks at the null status anyway
            //streams.import.result.add(importRequest);
            streams.import.result.add(ImportRequest(text: 'sensitive'));
            streams.app.setting.add(null);

            /// wait till balances show to show successful import...
            //streams.app.snack.add(Snack(message: 'Sucessful Import: downloading transactions'));
          } else if (tuple3.item3.isNotEmpty &&
              tuple3.item3.first != 'Success!') {
            if (importRequest.onSuccess != null) {
              await importRequest.onSuccess!();
            }
            streams.app.snack.add(Snack(
                message: tuple3.item3
                        .firstWhere((String? element) => element != null)
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
