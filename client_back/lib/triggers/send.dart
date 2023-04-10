/// new send process:
/// hit endpoint on server with details of send
/// it creates transaction
/// it tells you what addresses are included in which inputs
/// you derive those particular addresses
/// you sign the inputs
/// you send or broadcast the signed transaction

// ignore_for_file: omit_local_variable_types

import 'package:tuple/tuple.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart' as wu show Transaction;
import 'package:client_back/streams/app.dart';
import 'package:client_back/streams/spend.dart';
import 'package:client_back/services/transaction/verify.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/services/transaction/maker.dart';

class SendWaiter extends Trigger {
  void init() {
    when(
        thereIsA: streams.spend.make
            .where((SendRequest? sendRequest) => sendRequest != null),
        doThis: (SendRequest? sendRequest) async {
          print('SEND REQUEST $sendRequest');
          Tuple2<wu.Transaction, SendEstimate> tuple;
          try {
            tuple = await services.transaction.make.transactionBy(sendRequest!);
            final wu.Transaction tx = tuple.item1;
            final SendEstimate estimate = tuple.item2;
            if (FeeGuard(tx.toHex(), estimate).check()) {
              streams.spend.made.add(TransactionNote(
                txHex: tx.toHex(),
                note: sendRequest.note,
              ));
              streams.spend.estimate.add(estimate);
              streams.spend.make.add(null);
            }
          } on InsufficientFunds {
            streams.app.snack.add(Snack(
                message: 'Send Failure: Insufficient Funds', positive: false));
            streams.spend.success.add(false);
          } on FeeGuardException catch (e) {
            streams.app.snack
                .add(Snack(message: 'Send Failure: $e', positive: false));
            streams.spend.success.add(false);
          } on Exception catch (e) {
            print(e);
            streams.app.snack.add(Snack(
              message: 'Error Generating Transaction',
              copy: '$e',
              positive: false,
            ));
            streams.spend.success.add(false);
          }
        });

    when(
        thereIsA: streams.spend.send.where(
            (TransactionNote? transactionNote) => transactionNote != null),
        doThis: (TransactionNote? transactionNote) async {
          // tx + note
          //try {

          final String txid =
              await services.client.api.sendTransaction(transactionNote!.txHex);
          if (transactionNote.note != null) {
            await pros.notes
                .save(Note(transactionId: txid, note: transactionNote.note!));
          }
          print('txid');
          print(txid);
          if (txid != '') {
            // delete utxos if they're specified
            if (transactionNote.usedUtxos != null) {
              for (Vout vout in transactionNote.usedUtxos!) {
                final Unspent? unspent = vout.unspent;
                if (unspent != null) {
                  await pros.unspents.remove(unspent);
                }
              }
              await pros.vouts.removeAll(transactionNote.usedUtxos!);
            }
            // able to disable snack
            if (transactionNote.successMsg != '') {
              streams.app.snack.add(Snack(
                message: transactionNote.successMsg ?? 'Successfully Sent',
                label: txid.cutOutMiddle(length: 3),
                copy: txid,
                //label: 'Transaction ID',
                //link: 'https://rvn${pros.settings.mainnet ? '' : 't'}.cryptoscope.io/tx/?txid=$txid'
              ));
            }
            streams.spend.success.add(true);
          } else {
            streams.app.snack.add(Snack(
              message: 'Send Failure',
              copy: 'Unable to verify the transaction succeeded, '
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
        });
  }
}
