/// creating assets
// ignore_for_file: omit_local_variable_types

import 'package:tuple/tuple.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart' as wu;
import 'package:ravencoin_back/waiters/waiter.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/services/transaction/maker.dart';

class CreateWaiter extends Waiter {
  void init() {
    streams.create.request.listen((GenericCreateRequest? createRequest) async {
      if (createRequest != null) {
        await Future<void>.delayed(
            const Duration(milliseconds: 500)); // wait for please wait
        Tuple2<wu.Transaction, SendEstimate> tuple;
        try {
          tuple = await services.transaction.make
              .createTransactionBy(createRequest);
          final wu.Transaction tx = tuple.item1;
          final SendEstimate estimate = tuple.item2;

          /// extra safety - fee guard clause
          if (estimate.fees > 2 * wu.satsPerCoin) {
            throw Exception(
                'FEE IS TOO LARGE! NO FEE SHOULD EVER BE THIS BIG!');
          }

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
          print('Create');
          print(e);
          streams.app.snack.add(Snack(
            message: 'Error Generating Transaction: $e',
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
        final txid = await services.client.api.sendTransaction(txHex);
        print('txid');
        print(txid);
        if (txid != '') {
          streams.app.snack.add(Snack(
            message:
                'Asset Creation Successful: ${txid.cutOutMiddle(length: 2)}',
            //label: 'Transaction ID',
            //link: 'https://rvn${pros.settings.mainnet ? '' : 't'}.cryptoscope.io/tx/?txid=$txid'
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
