import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/src/utilities/validation_ext.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/theme/extensions.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:ravencoin_back/services/transaction/transaction.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/utils/data.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:wallet_utils/wallet_utils.dart' show SatsToAmountExtension;

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  Map<String, dynamic> data = <String, dynamic>{};
  Address? address;
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  TransactionRecord? transactionRecord;
  Transaction? transaction;

  @override
  void initState() {
    super.initState();
    listeners.add(pros.blocks.changes.listen((Change<Block> changes) {
      setState(() {});
    }));
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    transactionRecord = data['transactionRecord'] as TransactionRecord?;
    transaction =
        transactionRecord!.transaction; // transactionRecord.hash.toHex();
    //address = addresses.primaryIndex.getOne(transaction!.addresses);
    return BackdropLayers(
      back: const BlankBack(),
      front: FrontCurve(child: detailsBody()),
    );
  }

  String element(String humanName) {
    switch (humanName) {
      case 'Date':
        return getDateBetweenHelper();
      case 'Confirmations':
        return getConfirmationsBetweenHelper();
      case 'Type':
        switch (transactionRecord!.type) {
          case TransactionViewType.self:
            return 'to Self';
          case TransactionViewType.fee:
            return 'Asset Transfer Fee';
          case TransactionViewType.create:
            return 'Asset Creation';
          case TransactionViewType.burn:
            return 'Burned';
          case TransactionViewType.reissue:
            return 'Reissue';
          case TransactionViewType.tag:
            return 'Tag';
          case TransactionViewType.incoming:
            return 'In';
          case TransactionViewType.outgoing:
            //default:
            return 'Out';
          case TransactionViewType.claim:
            //default:
            return 'Claim';
          default:
            return 'Transaction';
        }
      case 'ID':
        return transaction!.id.cutOutMiddle();
      case 'Memo/IPFS':
        return (String humanName) {
          final String txMemo = transactionMemo ?? '';
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
        return () {
          if (transactionRecord!.fee == 0) {
            transactionRecord!.getVouts();
            return 'calculating...';
          } else {
            return '${transactionRecord!.fee.asCoin.toSatsCommaString()} ${pros.settings.chain.symbol}';
          }
        }();

      default:
        return 'unknown';
    }
  }

  String? get transactionMemo {
    // should do this logic on the back / in the record
    return transaction!.memos.isNotEmpty
        ? transaction!.memos.first.substring(2).hexToUTF8
        : transaction!.assetMemos.isNotEmpty
            ? transaction!.assetMemos.first /*.hexToAscii ?*/
            : null;
  }

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
            streams.app.snack.add(Snack(message: 'copied to clipboard'));
          },
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyText1,
            maxLines: text == 'Memo/IPFS' && !value.isIpfs ? 3 : null,
          ),
        ),
      );

  Widget link({
    required String title,
    required String text,
    required String url,
    required String description,
  }) =>
      ListTile(
        dense: true,
        title: Text(text, style: Theme.of(context).textTheme.bodyText1),
        onTap: () => components.message.giveChoices(
          context,
          title: title,
          content: 'View $description in external browser?',
          behaviors: <String, void Function()>{
            'Cancel'.toUpperCase(): Navigator.of(context).pop,
            'Browser'.toUpperCase(): () {
              Navigator.of(context).pop();
              //launch(url + elementFull(text));
              streams.app.browsing.add(true);
              launchUrl(Uri.parse(url + elementFull(text)));
            },
          },
        ),
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: elementFull(text)));
          streams.app.snack.add(Snack(message: 'copied to clipboard'));
        },
        trailing: Text(element(text), style: Theme.of(context).textTheme.link),
      );

  Widget detailsBody() => ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 112),
        children: <Widget>[
              for (String text in <String>[
                'Date',
                'Confirmations',
                'Type',
                'Fee'
              ])
                if (element(text) != 'calculating...')
                  plain(text, element(text))
            ] +
            <Widget>[
              link(
                title: 'Transaction Info',
                text: 'ID',
                url:
                    'https://${pros.settings.chain.symbol}${pros.settings.mainnet ? '' : 't'}.cryptoscope.io/tx/?txid=',
                description: 'info',
              ),
              if (transactionMemo != null)
                transactionMemo!.isIpfs
                    ? link(
                        title: 'IPFS',
                        text: 'Memo/IPFS',
                        url: 'https://gateway.ipfs.io/ipfs/',
                        description: 'data',
                      )
                    : plain('Memo/IPFS', element('Memo/IPFS')),
            ] +
            (transaction!.note == null || transaction!.note == ''
                ? <Widget>[]
                : <Widget>[plain('Note', element('Note'))]),
      );

  int? getBlocksBetweenHelper({Transaction? tx, Block? current}) {
    tx = tx ?? transaction!;
    current = current ?? pros.blocks.latest;
    return (current != null && tx.height != null)
        ? current.height - tx.height!
        : null;
  }

  String getDateBetweenHelper() => 'Date: ${transaction!.formattedDatetime}';
  //(getBlocksBetweenHelper() != null
  //    ? formatDate(
  //        DateTime.now().subtract(Duration(
  //          days: (getBlocksBetweenHelper()! / 1440).floor(),
  //          hours:
  //              (((getBlocksBetweenHelper()! / 1440) % 1440) / 60).floor(),
  //        )),
  //        [MM, ' ', d, ', ', yyyy])
  //    : 'unknown');

  String getConfirmationsBetweenHelper() => getBlocksBetweenHelper() != null
      ? getBlocksBetweenHelper().toString()
      : 'unknown';
}
