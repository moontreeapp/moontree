import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:client_back/services/transaction/maker.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/presentation/components/components.dart';
import 'package:client_front/presentation/theme/extensions.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/domain/utils/data.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:wallet_utils/wallet_utils.dart';

enum TransactionType { spend, create, reissue, export }

class CheckoutStruct {
  final Widget? icon;
  final String? symbol;
  final String displaySymbol;
  final String? subSymbol;
  final String? paymentSymbol;
  final double? left;
  final Iterable<Iterable<String>> items;
  final Iterable<Iterable<String>>? fees;
  final String? total;
  final String? confirm;
  final Function? buttonAction;
  final String? buttonWord;
  final Widget? button;
  final String loadingMessage;
  final int? playcount;
  static const Iterable<Iterable<String>> exampleItems = <List<String>>[
    <String>['Short Text', 'aligned right'],
    <String>['Too Long Text (~20+ chars)', 'QmXwHQ43NrZPq123456789'],
    <String>[
      'Multiline (2) - Limited',
      '(#KYC && #COOLDUDE) || (#OVERRIDE || #MOONTREE) && (!! #IRS)',
      '2'
    ],
    <String>[
      'Multiline (5)',
      '(#KYC && #COOLDUDE) || (#OVERRIDE || #MOONTREE) && (!! #IRS)',
      '5'
    ]
  ];
  static const Iterable<Iterable<String>> exampleFees = <List<String>>[
    <String>['Transaction', '1'],
    <String>['Sub Asset', '100'],
    <String>['long amount', '21,000,000.00000000']
  ];

  const CheckoutStruct({
    this.icon,
    this.left,
    this.symbol = '#MoonTree',
    this.displaySymbol = 'MoonTree',
    this.subSymbol = 'Main/',
    this.paymentSymbol = 'RVN',
    this.items = exampleItems,
    this.fees = exampleFees,
    this.total = '101',
    this.buttonAction,
    this.buttonWord = 'Submit',
    this.loadingMessage = 'Sending Transaction',
    this.confirm,
    this.button,
    this.playcount = 2,
  });
}

class Checkout extends StatefulWidget {
  final TransactionType? transactionType;

  const Checkout({required this.transactionType, Key? key}) : super(key: key);

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  late Map<String, dynamic> data = <String, dynamic>{};
  late CheckoutStruct struct;
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];
  SendEstimate? estimate;
  late bool disabled = false;
  late DateTime startTime;

  @override
  void initState() {
    super.initState();

    /// if still in download process of any kind, tell user they must wait till
    /// sync is finished, disable button until done.
    if (streams.client.busy.value) {
      streams.app.snack
          .add(Snack(message: 'Still syncing with network, please wait'));
    }
    if (widget.transactionType == TransactionType.spend) {
      listeners.add(streams.spend.estimate.listen((SendEstimate? value) {
        if (value != estimate) {
          setState(() {
            estimate = value;
          });
        }
      }));
    } else if (widget.transactionType == TransactionType.create) {
      listeners.add(streams.create.estimate.listen((SendEstimate? value) {
        if (value != estimate) {
          setState(() {
            estimate = value;
          });
        }
      }));
    } else if (widget.transactionType == TransactionType.reissue) {
      listeners.add(streams.reissue.estimate.listen((SendEstimate? value) {
        if (value != estimate) {
          setState(() {
            estimate = value;
          });
        }
      }));
    }
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
    struct = data['struct'] as CheckoutStruct? ?? const CheckoutStruct();
    startTime = DateTime.now();
    return BackdropLayers(
        back: const BlankBack(), front: FrontCurve(child: body()));
  }

  Widget body() => CustomScrollView(
        shrinkWrap: true,
        slivers: <Widget>[
          topPart,
          bottomPart,
        ],
      );

  Widget get topPart => SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 12),
            header,
            const Divider(indent: 16 + 56),
            const SizedBox(height: 14),
            transactionItems,

            const SizedBox(height: 16),
            //Divider(indent: 16),
          ],
        ),
      );

  Widget get header => ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: struct.icon ??
            components.icons.assetAvatar(struct.symbol!.toUpperCase(),
                net: pros.settings.net),
        title: Row(children: <Widget>[
          const SizedBox(width: 5),
          Container(
              width:
                  MediaQuery.of(context).size.width - (16 + 40 + 16 + 5 + 16),
              child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(struct.displaySymbol,
                      style: Theme.of(context).textTheme.bodyText1)))
        ]),
        //subtitle: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        //  const SizedBox(width: 5),
        //  Text(struct.subSymbol!.toUpperCase(),
        //      style: Theme.of(context).checkoutSubAsset),
        //])
      );

  Widget get transactionItems => Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ...detailItems(
            pairs: struct.items,
            style: Theme.of(context).textTheme.checkoutItem,
          )
        ],
      ));

  Iterable<Widget> detailItems({
    required Iterable<Iterable<String>> pairs,
    TextStyle? style,
    bool fee = false,
  }) {
    final List<Widget> rows = <Widget>[];
    for (final Iterable<String> pair in pairs) {
      String rightSide = fee
          ? getRightFee(pair.toList()[1])
          : getRightAmount(pair.toList()[1]);
      if (rightSide.length > 20) {
        rightSide = <String>['To', 'IPFS', 'IPFS/TxId', 'ID', 'TxId']
                .contains(pair.toList()[0])
            ? rightSide.cutOutMiddle()
            : rightSide;
      }
      rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
                width: (MediaQuery.of(context).size.width - 16 - 16 - 8) *
                    (struct.left ?? .5),
                child: Text(pair.toList()[0],
                    style: style,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    maxLines: 1)),
            if (fee || rightSide.length < 21)
              Text(rightSide, style: style, textAlign: TextAlign.right)
            else
              SizedBox(
                  width: (MediaQuery.of(context).size.width - 16 - 16 - 8) *
                      (1 - (struct.left ?? .5)),
                  child: Text(
                    rightSide,
                    style: style,
                    textAlign: TextAlign.right,
                    overflow: pair.length == 2
                        ? TextOverflow.fade
                        : TextOverflow.fade,
                    softWrap: pair.length != 2,
                    maxLines:
                        pair.length == 2 ? 1 : int.parse(pair.toList()[2]),
                  )),
          ]));
    }
    return rows.intersperse(const SizedBox(height: 21));
  }

  String getRightAmount(String x) {
    if (x == 'calculating amount...') {
      disabled = true;
      if (estimate != null) {
        disabled = false;
        return estimate!.amount.asCoin.toString();
        //return satToAmount(estimate!.total - estimate!.fees).toString();
      }
      return x;
    }
    return x;
  }

  String getRightFee(String x) {
    if (x == 'calculating fee...') {
      disabled = true;
      if (estimate != null) {
        disabled = false;
        return estimate!.fees.asCoin.toString();
      }
      return x;
    }
    return x;
  }

  Widget get bottomPart => SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (struct.fees != null)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ...fees,
                  ],
                ),
              ),
            const Divider(indent: 0),
            if (struct.total != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 16, right: 16),
                      child: total),
                  const SizedBox(height: 40),
                  components.containers.navBar(context, child: submitButton),
                ],
              ),
            if (struct.confirm != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 16, right: 16),
                      child: confirm),
                  const SizedBox(height: 40),
                  components.containers.navBar(context,
                      child: struct.button == null
                          ? submitButton
                          : struct.button!),
                ],
              ),
          ],
        ),
      );

  List<Widget> get fees => <Widget>[
        Text('Fees', style: Theme.of(context).textTheme.checkoutFees),
        const SizedBox(height: 14),
        ...detailItems(
          pairs: struct.fees!,
          style: Theme.of(context).textTheme.checkoutFee,
          fee: true,
        ),
      ];

  Widget get total =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Text('Total:', style: Theme.of(context).textTheme.bodyText1),
        Text(
            '${getRightTotal(struct.total!)} ${struct.paymentSymbol!.toUpperCase()}',
            style: Theme.of(context).textTheme.bodyText1,
            key: Key('checkoutTotal')),
      ]);

  Widget get confirm => Container(
        height: 60,
        alignment: Alignment.center,
        child: Text(
          struct.confirm!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText1,
          softWrap: true,
          overflow: TextOverflow.fade,
          maxLines: 3,
        ),
      );

  String getRightTotal(String x) {
    if (x == 'calculating total...') {
      disabled = true;
      if (estimate != null) {
        disabled = false;
        return estimate!.total.asCoin.toString();
      }
    }
    return x;
  }

  Widget get submitButton => Row(children: <Widget>[
        components.buttons.actionButton(
          context,
          enabled: !disabled,
          label: struct.buttonWord,
          onPressed: () async {
            if (DateTime.now().difference(startTime).inMilliseconds > 500) {
              components.loading.screen(
                  message: struct.loadingMessage,
                  playCount: struct.playcount ?? 2,
                  then: struct.buttonAction);
            }
          },
        )
      ]);
}
