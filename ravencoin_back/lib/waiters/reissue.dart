/// creating assets
// ignore_for_file: omit_local_variable_types

import 'package:tuple/tuple.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart' as wu;
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/services/transaction/maker.dart';

class ReissueWaiter extends Trigger {
  void init() {
    when(
        thereIsA: streams.reissue.request.where(
            (GenericReissueRequest? reissueRequest) =>
                reissueRequest != null) as Stream<GenericReissueRequest>,
        doThis: (GenericReissueRequest reissueRequest) async {
          await Future<void>.delayed(
              const Duration(milliseconds: 500)); // wait for please wait
          Tuple2<wu.Transaction, SendEstimate> tuple;
          print(reissueRequest.isRestricted);
          try {
            tuple = await services.transaction.make
                .reissueTransactionBy(reissueRequest);
            final wu.Transaction tx = tuple.item1;
            final SendEstimate estimate = tuple.item2;

            /// extra safety - fee guard clause
            if (estimate.fees > 2 * wu.satsPerCoin) {
              throw Exception(
                  'FEE IS TOO LARGE! NO FEE SHOULD EVER BE THIS BIG!');
            }

            streams.reissue.made.add(tx.toHex());
            streams.reissue.estimate.add(estimate);
            streams.reissue.request.add(null);
          } on InsufficientFunds {
            streams.app.snack.add(Snack(
              message: 'Send Failure',
              details: 'Insufficient Funds',
            ));
            streams.reissue.success.add(false);
          } catch (e, stack) {
            print(stack);
            streams.app.snack.add(Snack(
              message: 'Error Generating Transaction: $e',
              positive: false,
              //details: 'Unable to reissue transaction: $e',
            ));
            streams.reissue.success.add(false);
          }
        });

    when(
        thereIsA: streams.reissue.send.where((String? txHex) => txHex != null)
            as Stream<String>,
        doThis: (String txHex) async {
          //try {
          final String txid = await services.client.api.sendTransaction(txHex);
          print('txid');
          print(txid);
          if (txid != '') {
            streams.app.snack.add(Snack(
              message:
                  'Asset Creation Successful: ${txid.cutOutMiddle(length: 2)}',
              //label: 'Transaction ID',
              //link: 'https://rvn${pros.settings.mainnet ? '' : 't'}.cryptoscope.io/tx/?txid=$txid'
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
        });
  }
}
