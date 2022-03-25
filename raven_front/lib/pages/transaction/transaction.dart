import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:raven_back/services/transaction.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/utils/data.dart';

class TransactionPage extends StatefulWidget {
  final dynamic data;
  const TransactionPage({this.data}) : super();

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  dynamic data = {};
  Address? address;
  List<StreamSubscription> listeners = [];
  TransactionRecord? transactionRecord;
  Transaction? transaction;

  @override
  void initState() {
    super.initState();
    listeners.add(res.blocks.changes.listen((changes) {
      setState(() {});
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    transactionRecord = data['transactionRecord'];
    transaction = transactionRecord!.transaction;
    //address = addresses.primaryIndex.getOne(transaction!.addresses);
    print(transaction!.note);
    return detailsBody();
  }

  String element(String humanName) {
    switch (humanName) {
      case 'Date':
        return getDateBetweenHelper();
      case 'Confirmations':
        return getConfirmationsBetweenHelper();
      case 'Type':
        return transactionRecord!.toSelf
            ? 'Back to Self'
            : transactionRecord!.totalIn <= transactionRecord!.totalOut
                ? 'In'
                : 'Out';
      case 'ID':
        return transaction!.id.cutOutMiddle();
      case 'Memo/IPFS':
        return (String humanName) {
          var txMemo = (transactionMemo ?? '');
          if (txMemo.isIpfs) {
            return txMemo.cutOutMiddle();
          }
          if (txMemo.length > 30) {
            return txMemo.cutOutMiddle(length: 12);
          }
          return txMemo;
        }(humanName);
      case 'Note':
        return transaction!.note ?? '';
      case 'Fee':
        return transactionRecord!.fee.toAmount().toCommaString() + ' RVN';
      default:
        return 'unknown';
    }
  }

  String? get transactionMemo => transaction!.memos.isNotEmpty
      ? transaction!.memos.first.hexToAscii
      : transaction!.assetMemos.isNotEmpty
          ? transaction!.assetMemos.first /*.hexToAscii ?*/
          : null;

  String elementFull(String humanName) {
    switch (humanName) {
      case 'ID':
        return transaction!.id;
      case 'Memo/IPFS':
        return transactionMemo ?? '';
      case 'Note':
        return transaction!.note ?? '';
      default:
        return 'unknown';
    }
  }

  Widget plain(String text, String value) => ListTile(
        dense: true,
        title: Text(text, style: Theme.of(context).textTheme.bodyText1),
        trailing: GestureDetector(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: value));
            streams.app.snack
                .add(Snack(message: 'Copied to Clipboard', atBottom: true));
          },
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyText1,
            maxLines: text == 'Memo/IPFS' && !value.isIpfs ? 3 : null,
          ),
        ),
      );

  Widget link(String text, String link) => ListTile(
        dense: true,
        title: Text(text, style: Theme.of(context).textTheme.bodyText1),
        onTap: () => launch(link + elementFull(text)),
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: elementFull(text)));
          streams.app.snack
              .add(Snack(message: 'Copied to Clipboard', atBottom: true));
        },
        trailing: Text(element(text), style: Theme.of(context).textTheme.link),
      );

  Widget detailsBody() => ListView(
        padding: EdgeInsets.only(top: 8, bottom: 112),
        children: <Widget>[
              for (var text in ['Date', 'Confirmations', 'Type', 'Fee'])
                plain(text, element(text))
            ] +
            [
              link('ID', 'https://rvnt.cryptoscope.io/tx/?txid='),
              if (transactionMemo != null)
                transactionMemo!.isIpfs
                    ? link('Memo/IPFS', 'https://gateway.ipfs.io/ipfs/')
                    : plain('Memo/IPFS', element('Memo/IPFS')),
            ] +
            (transaction!.note == null || transaction!.note == ''
                ? []
                : [plain('Note', element('Note'))]),
      );

  int? getBlocksBetweenHelper({Transaction? tx, Block? current}) {
    tx = tx ?? transaction!;
    current = current ?? res.blocks.latest;
    return (current != null && tx.height != null)
        ? current.height - tx.height!
        : null;
  }

  String getDateBetweenHelper() => 'Date: ' + transaction!.formattedDatetime;
  //(getBlocksBetweenHelper() != null
  //    ? formatDate(
  //        DateTime.now().subtract(Duration(
  //          days: (getBlocksBetweenHelper()! / 1440).floor(),
  //          hours:
  //              (((getBlocksBetweenHelper()! / 1440) % 1440) / 60).floor(),
  //        )),
  //        [MM, ' ', d, ', ', yyyy])
  //    : 'unknown');

  String getConfirmationsBetweenHelper() =>
      'Confirmations: ' +
      (getBlocksBetweenHelper() != null
          ? getBlocksBetweenHelper().toString()
          : 'unknown');
}
