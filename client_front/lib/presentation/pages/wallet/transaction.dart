import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:client_front/application/cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client_back/records/types/transaction_view.dart';
import 'package:client_back/server/src/protocol/comm_transaction_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/src/utilities/validation_ext.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/presentation/theme/extensions.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:client_back/services/transaction/transaction.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/domain/utils/data.dart';
import 'package:client_front/presentation/components/components.dart';
import 'package:wallet_utils/wallet_utils.dart' show SatsToAmountExtension;

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  TransactionPageState createState() => TransactionPageState();
}

class TransactionPageState extends State<TransactionPage> {
  Map<String, dynamic> data = <String, dynamic>{};
  Address? address;
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  late TransactionView transactionView;

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
    final TransactionViewCubit cubit =
        flutter_bloc.BlocProvider.of<TransactionViewCubit>(context);
    data = populateData(context, data);
    transactionView = data['transactionView']! as TransactionView;
    //address = addresses.primaryIndex.getOne(transaction!.addresses);
    cubit.setTransactionDetails(hash: transactionView.hash);
    return TransactionPageContent(
      cubit: cubit,
      transactionView: transactionView,
      parent: this,
    );
  }

  void callSetState(VoidCallback f) {
    setState(() {
      f();
    });
  }
}

class TransactionPageContent extends StatelessWidget {
  final TransactionViewCubit cubit;
  final TransactionView transactionView;
  final TransactionPageState parent;

  const TransactionPageContent({
    Key? key,
    required this.cubit,
    required this.transactionView,
    required this.parent,
  }) : super(key: key);

  Future<void> refresh() async {
    //parent.callSetState(() {
    cubit.setTransactionDetails(hash: transactionView.hash, force: true);
    //});
  }

  @override
  Widget build(BuildContext context) {
    final TransactionViewCubit cubit =
        flutter_bloc.BlocProvider.of<TransactionViewCubit>(context);
    //address = addresses.primaryIndex.getOne(transaction!.addresses);
    // why this get called twice?
    //cubit.setTransactionDetails(hash: transactionView.hash);
    return flutter_bloc.BlocBuilder<TransactionViewCubit, TransactionViewState>(
        bloc: cubit..enter(),
        builder: (BuildContext context, TransactionViewState state) {
          return BackdropLayers(
            back: const BlankBack(),
            front: FrontCurve(child: detailsBody(cubit, context)),
          );
        });
  }

  String element(String humanName, TransactionViewCubit cubit) {
    switch (humanName) {
      case 'Date':
        return getDateBetweenHelper();
      case 'Confirmations':
        return getConfirmationsBetweenHelper();
      case 'Type':
        return transactionView.type.display;
      case 'Asset':
        return transactionView
                    .isCoin && //9520c0f2727c4e94d87c86f66e362653c52e9972666ce76edde223c74a236cc6 df745a3ee1050a9557c3b449df87bdd8942980dff365f7f5a93bc10cb1080188
                transactionView.containsAssets &&
                cubit.state.transactionView?.containsAssets != null &&
                !(cubit.state.transactionView?.containsAssets ?? '')
                    .contains(',')
            ? cubit.state.transactionView?.containsAssets ?? ''
            : '';
      case 'Assets':
        return transactionView.isCoin &&
                transactionView.containsAssets &&
                (cubit.state.transactionView?.containsAssets ?? '')
                    .contains(',')
            ? cubit.state.transactionView?.containsAssets
                    ?.replaceAll(',', ', ') ??
                ''
            : '';
      case 'Create Asset Fee':
        final burned = transactionView.issueMainBurned;
        return burned > 0
            ? '${burned.asCoin.toSatsCommaString()} ${transactionView.symbol}'
            : '';
      case 'Reissue Fee':
        final burned = transactionView.reissueBurned;
        return burned > 0
            ? '${burned.asCoin.toSatsCommaString()} ${transactionView.symbol}'
            : '';
      case 'Create Sub-Asset Fee':
        final burned = transactionView.issueSubBurned;
        return burned > 0
            ? '${burned.asCoin.toSatsCommaString()} ${transactionView.symbol}'
            : '';
      case 'Create NFT Fee':
        final burned = transactionView.issueUniqueBurned;
        return burned > 0
            ? '${burned.asCoin.toSatsCommaString()} ${transactionView.symbol}'
            : '';
      case 'Create Message Fee':
        final burned = transactionView.issueMessageBurned;
        return burned > 0
            ? '${burned.asCoin.toSatsCommaString()} ${transactionView.symbol}'
            : '';
      case 'Create Qualifier Fee':
        final burned = transactionView.issueQualifierBurned;
        return burned > 0
            ? '${burned.asCoin.toSatsCommaString()} ${transactionView.symbol}'
            : '';
      case 'Create Sub-Qualifier Fee':
        final burned = transactionView.issueSubQualifierBurned;
        return burned > 0
            ? '${burned.asCoin.toSatsCommaString()} ${transactionView.symbol}'
            : '';
      case 'Create Restricted Fee':
        final burned = transactionView.issueRestrictedBurned;
        return burned > 0
            ? '${burned.asCoin.toSatsCommaString()} ${transactionView.symbol}'
            : '';
      case 'Tag Fee':
        final burned = transactionView.addTagBurned;
        return burned > 0
            ? '${burned.asCoin.toSatsCommaString()} ${transactionView.symbol}'
            : '';
      case 'Burned':
        final burned = transactionView.burnBurned;
        return burned > 0
            ? '${burned.asCoin.toSatsCommaString()} ${transactionView.symbol}'
            : '';
      case 'Incoming':
        final incoming = transactionView.iReceived;
        return incoming > 0
            ? '${incoming.asCoin.toSatsCommaString()} ${transactionView.symbol}'
            : '';
      case 'Outgoing':
        final outgoing = transactionView.iProvided;
        return outgoing > 0
            ? '${outgoing.asCoin.toSatsCommaString()} ${transactionView.symbol}'
            : '';
      case 'ID':
        return transactionView.readableHash.cutOutMiddle();
      case 'IPFS':
        return (String humanName) {
          final String txMemo = transactionMemo(cubit) ?? '';
          if (txMemo.isIpfs) {
            return txMemo.cutOutMiddle();
          }
          return '';
        }(humanName);
      case 'Memo':
        return (String humanName) {
          final String txMemo = transactionMemo(cubit) ?? '';
          if (txMemo.isIpfs) {
            return '';
          }
          if (txMemo.length > 30) {
            return txMemo.cutOutMiddle(length: 12);
          }
          return txMemo;
        }(humanName);
      case 'Note':
        return transactionView.note ?? '';
      case 'Transaction Fee':
        // don't show tx fee if I didn't possibly pay it.
        return transactionView.fee > 0 && transactionView.outgoing
            ? '${transactionView.fee.asCoin.toSatsCommaString()} ${pros.settings.chain.symbol}'
            : '';
      case 'Total':
        if (transactionView.isCoin) {
          return transactionView.iValue > 0
              ? '${transactionView.iValue.asCoin.toSatsCommaString()} ${pros.settings.chain.symbol}'
              : '${transactionView.fee.asCoin.toSatsCommaString()} ${pros.securities.currentCoin.symbol}';
        }
        return '${transactionView.iValue.asCoin.toSatsCommaString()} ${transactionView.symbol}'; // + ' +
      //'${transactionView.fee.asCoin.toSatsCommaString()} ${pros.securities.currentCoin.symbol}';
      default:
        return 'unknown';
    }
  }

  String? transactionMemo(TransactionViewCubit cubit) {
    /// todo: might have to make a call for transaction memo.
    // should do this logic on the back / in the record
    //return transaction!.memos.isNotEmpty
    //    ? transaction!.memos.first.substring(2).hexToUTF8
    //    : transaction!.assetMemos.isNotEmpty
    //        ? transaction!.assetMemos.first /*.hexToAscii ?*/
    //        : null;
    if (cubit.state.transactionView?.memo == null) {
      return null;
    }
    return cubit.state.transactionView!.memo!.toBs58();
  }

  String? transactionAssets(TransactionViewCubit cubit) {
    /// todo: might have to make a call for transaction memo.
    // should do this logic on the back / in the record
    //return transaction!.memos.isNotEmpty
    //    ? transaction!.memos.first.substring(2).hexToUTF8
    //    : transaction!.assetMemos.isNotEmpty
    //        ? transaction!.assetMemos.first /*.hexToAscii ?*/
    //        : null;
    if (cubit.state.transactionView?.memo == null) {
      return null;
    }
    return cubit.state.transactionView!.memo!.toBs58();
  }

  String elementFull(String humanName, TransactionViewCubit cubit) {
    switch (humanName) {
      case 'ID':
        return transactionView.readableHash;
      case 'IPFS':
        return transactionMemo(cubit) ?? '';
      case 'Note':
        return transactionView.note ?? '';
      default:
        return 'unknown';
    }
  }

  Widget plain(BuildContext context, String text, String value) =>
      value == '' || value == null
          ? SizedBox(height: 0)
          : ListTile(
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
                  maxLines: text == 'Memo' ? 3 : null,
                ),
              ),
            );

  Widget link(
    BuildContext context, {
    required String title,
    required String text,
    required String url,
    required String description,
    required TransactionViewCubit cubit,
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
                    launchUrl(Uri.parse(url + elementFull(text, cubit)));
                  },
                },
              ),
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: elementFull(text, cubit)));
            streams.app.snack.add(Snack(message: 'copied to clipboard'));
          },
          trailing: Text(element(text, cubit),
              style: Theme.of(context).textTheme.link));

  Widget detailsBody(TransactionViewCubit cubit, BuildContext context) =>
      RefreshIndicator(
          onRefresh: () => refresh(),
          child: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 112),
              children: <Widget>[
                    link(context,
                        title: 'Transaction Info',
                        text: 'ID',
                        url:
                            'https://${pros.settings.chain.symbol}${pros.settings.mainnet ? '' : 't'}.cryptoscope.io/tx/?txid=',
                        description: 'info',
                        cubit: cubit),
                    if (transactionMemo(cubit) != null)
                      transactionMemo(cubit)!.isIpfs
                          ? link(
                              context,
                              title: 'IPFS',
                              text: 'IPFS',
                              url: 'https://gateway.ipfs.io/ipfs/',
                              description: 'data',
                              cubit: cubit,
                            )
                          : plain(context, 'IPFS', element('IPFS', cubit)),
                  ] +
                  <Widget>[
                    for (String text in <String>[
                      'Date',
                      'Confirmations',
                      'Type',
                      'Asset',
                      'Assets',
                      'Note',
                      'Memo', // non-ipfs memos
                      'Incoming',
                      'Outgoing',
                      'Transaction Fee',
                      'Create Asset Fee',
                      'Create Sub-Asset Fee',
                      'Create NFT Fee',
                      'Create Message Fee',
                      'Create Qualifier Fee',
                      'Create Sub-Qualifier Fee',
                      'Create Restricted Fee',
                      'Reissue Fee',
                      'Burned',
                      'Tag Fee',
                      'Total'
                    ])
                      plain(context, text, element(text, cubit))
                  ]
              // +
              //(transactionView.note == null || transactionView.note == ''
              //    ? <Widget>[]
              //    : <Widget>[plain('Note', element('Note'))]),
              ));

  int? getBlocksBetweenHelper({Block? current}) {
    current = current ?? pros.blocks.latest;
    return (current != null && transactionView.height != null)
        ? current.height - transactionView.height
        : null;
  }

  String getDateBetweenHelper() => 'Date: ${transactionView.formattedDatetime}';
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
      getBlocksBetweenHelper()?.toString() ?? 'unknown';
}
