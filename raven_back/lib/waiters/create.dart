/// creating assets
// ignore_for_file: omit_local_variable_types

import 'package:raven_back/streams/app.dart';
import 'package:tuple/tuple.dart';

import 'waiter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction/maker.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' as ravencoin;

class CreateWaiter extends Waiter {
  void init() {
    streams.create.request.listen((GenericCreateRequest? createRequest) async {
      if (createRequest != null) {
        await Future.delayed(
            const Duration(milliseconds: 500)); // wait for please wait
        Tuple2<ravencoin.Transaction, SendEstimate> tuple;
        try {
          tuple = await services.transaction.make
              .createTransactionBy(createRequest);
          ravencoin.Transaction tx = tuple.item1;
          SendEstimate estimate = tuple.item2;
          streams.create.made.add(tx.toHex());
          streams.create.estimate.add(estimate);
          streams.create.request.add(null);
        } on InsufficientFunds {
          streams.app.snack.add(Snack(
            message: 'Send Failure',
            details: 'Insufficient Funds',
          ));
          streams.create.success.add(false);
        } catch (e) {
          streams.app.snack.add(Snack(
            message: 'Error Generating Transaction: $e',
            atBottom: true,
            positive: false,
            //details: 'Unable to create transaction: $e',
          ));
          streams.create.success.add(false);
        }
      }
    });

    streams.create.send.listen((String? txHex) async {
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
          streams.create.success.add(true);
        } else {
          streams.app.snack.add(Snack(
            message: 'Asset Creation Failure',
            details: 'Unable to verify the transaction succeeded, '
                'please try again later.',
          ));
          streams.create.success.add(false);
        }
        //} catch (e) {
        //  streams.app.snack.add(Snack(message: 'Send Failure'));
        //  rethrow;
        //}
        streams.create.made.add(null);
        streams.create.estimate.add(null);
        streams.create.send.add(null);
      }
    });
  }
}
