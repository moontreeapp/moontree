import 'package:raven_back/streams/app.dart';

import 'waiter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction_maker.dart';

class SendWaiter extends Waiter {
  void init() {
    streams.spend.send.listen((SendRequest? sendRequest) async {
      if (sendRequest != null) {
        /// this needs to be removed, and moved to the send page itself
        var tuple;
        try {
          tuple = services.transaction.make.transactionBy(sendRequest);
        } on InsufficientFunds catch (e) {
          streams.app.snack.add(Snack(
            message: 'Send Failure',
            details: 'Insufficient Funds',
          ));
          streams.spend.success.add(false);
        } catch (e) {
          streams.app.snack.add(Snack(
            message: 'Send Failure',
            details: 'Unable to create transaction: $e',
          ));
          streams.spend.success.add(false);
        }

        ///

        var txid =
            await services.client.api.sendTransaction(tuple.item1.toHex());
        if (txid != '') {
          streams.app.snack.add(Snack(
              message: 'Send Successful',
              label: 'Transaction ID',
              link: 'https://rvnt.cryptoscope.io/tx/?txid=$txid'));
          streams.spend.success.add(true);
        } else {
          streams.app.snack.add(Snack(
            message: 'Send Failure',
            details: 'Unable to verify the transaction succeeded, '
                'please try again later.',
          ));
          streams.spend.success.add(false);
        }
        streams.spend.send.add(null);
      }
    });
  }
}
