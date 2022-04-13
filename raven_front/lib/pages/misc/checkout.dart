import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/utils/data.dart';
import 'package:raven_back/services/transaction/maker.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/utilities/transform.dart';
import 'package:raven_front/widgets/widgets.dart';

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
  static const Iterable<Iterable<String>> exampleItems = [
    ['Short Text', 'aligned right'],
    ['Too Long Text (~20+ chars)', 'QmXwHQ43NrZPq123456789'],
    [
      'Multiline (2) - Limited',
      '(#KYC && #COOLDUDE) || (#OVERRIDE || #MOONTREE) && (!! #IRS)',
      '2'
    ],
    [
      'Multiline (5)',
      '(#KYC && #COOLDUDE) || (#OVERRIDE || #MOONTREE) && (!! #IRS)',
      '5'
    ]
  ];
  static const Iterable<Iterable<String>> exampleFees = [
    ['Transaction', '1'],
    ['Sub Asset', '100'],
    ['long amount', '21,000,000.00000000']
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
  });
}

class Checkout extends StatefulWidget {
  const Checkout({Key? key}) : super(key: key);

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  late Map<String, dynamic> data = {};
  late CheckoutStruct struct;
  late List<StreamSubscription> listeners = [];
  late SendEstimate? estimate = null;
  late bool disabled = false;

  @override
  void initState() {
    super.initState();
    listeners.add(streams.spend.estimate.listen((SendEstimate? value) {
      if (value != estimate) {
        setState(() {
          estimate = value;
        });
      }
    }));
    listeners.add(streams.create.estimate.listen((SendEstimate? value) {
      if (value != estimate) {
        setState(() {
          estimate = value;
        });
      }
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
    struct = data['struct'] ?? CheckoutStruct();
    return BackdropLayers(back: BlankBack(), front: FrontCurve(child: body()));
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
            SizedBox(height: 12),
            header,
            Divider(indent: 16 + 56),
            SizedBox(height: 14),
            transactionItems,
            SizedBox(height: 16),
            //Divider(indent: 16),
          ],
        ),
      );

  Widget get header => ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: struct.icon ??
            components.icons.assetAvatar(struct.symbol!.toUpperCase()),
        title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          SizedBox(width: 5),
          Text(struct.displaySymbol,
              style: Theme.of(context).textTheme.bodyText1)
        ]),
        //subtitle: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        //  SizedBox(width: 5),
        //  Text(struct.subSymbol!.toUpperCase(),
        //      style: Theme.of(context).checkoutSubAsset),
        //])
      );

  Widget get transactionItems => Padding(
      padding: EdgeInsets.only(left: 16, right: 16),
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
    var rows = <Widget>[];
    for (var pair in pairs) {
      var rightSide = fee ? getRightFee(pair.toList()[1]) : pair.toList()[1];
      if (rightSide.length > 20) {
        rightSide =
            ['To', 'IPFS', 'IPFS/TxId', 'ID', 'TxId'].contains(pair.toList()[0])
                ? rightSide.cutOutMiddle()
                : rightSide;
      }
      rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: (MediaQuery.of(context).size.width - 16 - 16 - 8) *
                    (struct.left ?? .5),
                child: Text(pair.toList()[0],
                    style: style,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    maxLines: 1)),
            fee || rightSide.length < 21
                ? Text(rightSide, style: style, textAlign: TextAlign.right)
                : Container(
                    width: (MediaQuery.of(context).size.width - 16 - 16 - 8) *
                        (1 - (struct.left ?? .5)),
                    child: Text(
                      rightSide,
                      style: style,
                      textAlign: TextAlign.right,
                      overflow: pair.length == 2
                          ? TextOverflow.fade
                          : TextOverflow.fade,
                      softWrap: pair.length == 2 ? false : true,
                      maxLines:
                          pair.length == 2 ? 1 : int.parse(pair.toList()[2]),
                    )),
          ]));
    }
    return rows.intersperse(SizedBox(height: 21));
  }

  String getRightFee(String x) {
    if (x == 'calculating fee...') {
      disabled = true;
      if (estimate != null) {
        disabled = false;
        return satToAmount(estimate!.fees).toString();
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
          children: [
            if (struct.fees != null)
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...fees,
                  ],
                ),
              ),
            Divider(indent: 0),
            if (struct.total != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                      padding: EdgeInsets.only(
                          top: 10, left: 16, right: 16, bottom: 0),
                      child: total),
                  SizedBox(height: 40),
                  components.containers.navBar(context, child: submitButton),
                ],
              ),
            if (struct.confirm != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                      padding: EdgeInsets.only(
                          top: 10, left: 16, right: 16, bottom: 0),
                      child: confirm),
                  SizedBox(height: 40),
                  components.containers.navBar(context,
                      child: struct.button == null
                          ? submitButton
                          : struct.button!),
                ],
              ),
          ],
        ),
      );

  List<Widget> get fees => [
        Text('Fees', style: Theme.of(context).textTheme.checkoutFees),
        SizedBox(height: 14),
        ...detailItems(
          pairs: struct.fees!,
          style: Theme.of(context).textTheme.checkoutFee,
          fee: true,
        ),
      ];

  Widget get total =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Total:', style: Theme.of(context).textTheme.bodyText1),
        Text(
            '${getRightTotal(struct.total!)} ${struct.paymentSymbol!.toUpperCase()}',
            style: Theme.of(context).textTheme.bodyText1),
      ]);

  Widget get confirm =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(struct.confirm!, style: Theme.of(context).textTheme.bodyText1),
      ]);

  String getRightTotal(String x) {
    if (x == 'calculating total...') {
      disabled = true;
      if (estimate != null) {
        disabled = false;
        return satToAmount(estimate!.total).toString();
      }
    }
    return x;
  }

  Widget get submitButton => Row(children: [
        components.buttons.actionButton(
          context,
          enabled: !disabled,
          label: struct.buttonWord,
          disabledOnPressed:
              //? () {}
              /// for testing
              () async {
            components.loading.screen(message: struct.loadingMessage);
            await Future.delayed(Duration(seconds: 6));
            streams.app.snack.add(Snack(message: 'test'));
          },
          onPressed: () async {
            components.loading.screen(message: struct.loadingMessage);
            (struct.buttonAction ?? () {})();
          },
        )
      ]);
}
