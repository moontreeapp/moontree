/// creating assets
// ignore_for_file: omit_local_variable_types

import 'package:raven_back/streams/app.dart';
import 'package:tuple/tuple.dart';

import 'waiter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction/maker.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' as ravencoin;

class ReissueWaiter extends Waiter {
  void init() {
    streams.reissue.request
        .listen((GenericReissueRequest? reissueRequest) async {
      if (reissueRequest != null) {
        await Future.delayed(
            const Duration(milliseconds: 500)); // wait for please wait
        Tuple2<ravencoin.Transaction, SendEstimate> tuple;
        try {
          tuple = await services.transaction.make
              .reissueTransactionBy(reissueRequest);
          ravencoin.Transaction tx = tuple.item1;
          SendEstimate estimate = tuple.item2;
          streams.reissue.made.add(tx.toHex());
          streams.reissue.estimate.add(estimate);
          streams.reissue.request.add(null);
        } on InsufficientFunds {
          streams.app.snack.add(Snack(
            message: 'Send Failure',
            details: 'Insufficient Funds',
          ));
          streams.reissue.success.add(false);
        } catch (e) {
          streams.app.snack.add(Snack(
            message: 'Error Generating Transaction: $e',
            atBottom: true,
            positive: false,
            //details: 'Unable to reissue transaction: $e',
          ));
          streams.reissue.success.add(false);
        }
      }
    });

    streams.reissue.send.listen((String? txHex) async {
      if (txHex != null) {
        //try {
        var txid = await services.client.api.sendTransaction(txHex);
        print('txid');
        print(txid);
        if (txid != '') {
          streams.app.snack.add(Snack(
            message:
                'Asset Creation Successful: ${txid.cutOutMiddle(length: 2)}',
            //label: 'Transaction ID',
            //link: 'https://rvnt.cryptoscope.io/tx/?txid=$txid'
          ));
          streams.reissue.success.add(true);
        } else {
          streams.app.snack.add(Snack(
            message: 'Asset Creation Failure',
            details: 'Unable to verify the transaction succeeded, '
                'please try again later.',
          ));
          streams.reissue.success.add(false);
        }
        //} catch (e) {
        //  streams.app.snack.add(Snack(message: 'Send Failure'));
        //  rethrow;
        //}
        streams.reissue.made.add(null);
        streams.reissue.estimate.add(null);
        streams.reissue.send.add(null);
      }
    });
  }
}
