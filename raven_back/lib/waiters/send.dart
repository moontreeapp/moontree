import 'package:raven_back/streams/app.dart';

import 'waiter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction_maker.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' as ravencoin;

class SendWaiter extends Waiter {
  void init() {
    streams.spend.make.listen((SendRequest? sendRequest) async {
      if (sendRequest != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        var tuple;
        print('MAKING');
        try {
          tuple = services.transaction.make.transactionBy(sendRequest);
          print('WORKED');
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
        ravencoin.Transaction tx = tuple.item1;
        SendEstimate estimate = tuple.item2;
        print('ESATIME:');
        print(estimate);
        streams.spend.made.add(tx.toHex());
        streams.spend.estimate.add(estimate);
        streams.spend.make.add(null);
      }
    });

    streams.spend.send.listen((String? transactionHex) async {
      if (transactionHex != null) {
        var txid = await services.client.api.sendTransaction(transactionHex);
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
        streams.spend.made.add(null);
        streams.spend.estimate.add(null);
        streams.spend.send.add(null);
      }
    });
  }
}
