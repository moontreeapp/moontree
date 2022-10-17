// ignore_for_file: omit_local_variable_types

import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/streams/spend.dart';
import 'package:tuple/tuple.dart';

import 'waiter.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/transaction/maker.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' as ravencoin;

class SendWaiter extends Waiter {
  void init() {
    streams.spend.make.listen((SendRequest? sendRequest) async {
      if (sendRequest != null) {
        print('SEND REQUEST $sendRequest');
        Tuple2<ravencoin.Transaction, SendEstimate> tuple;
        try {
          tuple = await services.transaction.make.transactionBy(sendRequest);
          ravencoin.Transaction tx = tuple.item1;
          SendEstimate estimate = tuple.item2;

          /// extra safety - fee guard clause
          if (estimate.fees > 2 * 100000000) {
            throw Exception(
                'FEE IS TOO LARGE! NO FEE SHOULD EVER BE THIS BIG!');
          }

          streams.spend.made.add(TransactionNote(
            txHex: tx.toHex(),
            note: sendRequest.note,
          ));
          streams.spend.estimate.add(estimate);
          streams.spend.make.add(null);
        } on InsufficientFunds {
          streams.app.snack.add(Snack(
              message: 'Send Failure: Insufficient Funds', positive: false));
          streams.spend.success.add(false);
        }
        // catch (e) {
        //  print('Send:');
        //  print(e);
        //  streams.app.snack.add(Snack(
        //    message: 'Error Generating Transaction: $e',
        //    atBottom: true,
        //    positive: false,
        //    //details: 'Unable to create transaction: $e',
        //  ));
        //  streams.spend.success.add(false);
        //}
      }
    });

    streams.spend.send.listen((TransactionNote? transactionNote) async {
      // tx + note
      if (transactionNote != null) {
        //try {
        var txid =
            await services.client.api.sendTransaction(transactionNote.txHex);
        if (transactionNote.note != null) {
          await pros.notes
              .save(Note(transactionId: txid, note: transactionNote.note!));
        }
        print('txid');
        print(txid);
        if (txid != '') {
          streams.app.snack.add(Snack(
            message: 'Successfully Sent', //: ${txid.cutOutMiddle(length: 3)}
            //label: 'Transaction ID',
            //link: 'https://rvn${pros.settings.mainnet ? '' : 't'}.cryptoscope.io/tx/?txid=$txid'
          ));
          streams.spend.success.add(true);
        } else {
          streams.app.snack.add(Snack(
            message: 'Send Failure',
            details: 'Unable to verify the transaction succeeded, '
                'please try again later.',
          ));
          streams.spend.success.add(false);
        }
        //} catch (e) {
        //  streams.app.snack.add(Snack(message: 'Send Failure'));
        //  rethrow;
        //}
        streams.spend.made.add(null);
        streams.spend.estimate.add(null);
        streams.spend.send.add(null);
      }
    });
  }
}
