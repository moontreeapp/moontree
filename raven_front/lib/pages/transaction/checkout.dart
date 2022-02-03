import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/utils/data.dart';
import 'package:raven_back/services/transaction_maker.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/utils/transform.dart';

class CheckoutStruct {
  final String symbol;
  final String subSymbol;
  final String paymentSymbol;
  final Iterable<Iterable<String>> items;
  final Iterable<Iterable<String>> fees;
  final String total;
  final Function? buttonAction;
  final IconData buttonIcon;
  final String buttonWord;
  static const Iterable<Iterable<String>> exampleItems = [
    ['Short Text', 'aligned right'],
    ['Too Long Text (~20+ chars)', 'QmXwHQ43NrZPq123456789'],
    [
      'Multiline (2) - Limited',
      '(#KYC && #COOLDUDE) || (#OVERRIDE || #MOONTREE) && (!! #IRS) && (!! #BASTARD)',
      '2'
    ],
    [
      'Multiline (5)',
      '(#KYC && #COOLDUDE) || (#OVERRIDE || #MOONTREE) && (!! #IRS) && (!! #BASTARD)',
      '5'
    ]
  ];
  static const Iterable<Iterable<String>> exampleFees = [
    ['Transaction', '1'],
    ['Sub Asset', '100'],
    ['long amount', '21,000,000.00000000']
  ];

  const CheckoutStruct({
    this.symbol = 'MoonTree',
    this.subSymbol = 'Main/',
    this.paymentSymbol = 'RVN',
    this.items = exampleItems,
    this.fees = exampleFees,
    this.total = '101',
    this.buttonAction,
    this.buttonIcon = Icons.add_rounded,
    this.buttonWord = 'Submit',
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

  @override
  void initState() {
    super.initState();
    listeners.add(streams.spend.estimate.listen((SendEstimate? value) {
      print('estimate: $value');
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
    return body();
  }

  Widget body() => CustomScrollView(
        shrinkWrap: true,
        slivers: <Widget>[
          topPart(),
          bottomPart(),
        ],
      );

  Widget topPart() => SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 12),
            header(),
            Divider(indent: 16),
            SizedBox(height: 14),
            transactionItems(),
          ],
        ),
      );

  Widget header() => ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: components.icons.assetAvatar(struct.symbol.toUpperCase()),
      title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(width: 5),
        Text(struct.symbol.toUpperCase(),
            style: Theme.of(context).checkoutAsset)
      ]),
      subtitle: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(width: 5),
        Text(struct.subSymbol.toUpperCase(),
            style: Theme.of(context).checkoutSubAsset),
      ]));

  Widget transactionItems() => Padding(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ...detailItems(
              pairs: struct.items, style: Theme.of(context).checkoutItem)
        ],
      ));

  Iterable<Widget> detailItems({
    required Iterable<Iterable<String>> pairs,
    TextStyle? style,
    bool fee = false,
  }) {
    var rows = <Widget>[];
    for (var pair in pairs) {
      var rightSide = getRightString(pair.toList()[1]);
      rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: (MediaQuery.of(context).size.width - 16 - 16 - 8) / 2,
                child: Text(pair.toList()[0],
                    style: style,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    maxLines: 1)),
            fee || rightSide.length < 21
                ? Text(rightSide, style: style)
                : Container(
                    width:
                        (MediaQuery.of(context).size.width - 16 - 16 - 8) / 2,
                    child: Text(
                      rightSide,
                      style: style,
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

  String getRightString(String x) {
    if (x == 'calculating fee...') {
      print('x$x|esimate$estimate');
      if (estimate != null) {
        return satToAmount(estimate!.fees).toString();
      }
      return x;
    }
    return x;
  }

  Widget bottomPart() => SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...fees(),
                ],
              ),
            ),
            Divider(indent: 0),
            Padding(
              padding:
                  EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  total(),
                  SizedBox(height: 40),
                  submitButton(),
                ],
              ),
            ),
          ],
        ),
      );

  List<Widget> fees() => [
        Text('Fees', style: Theme.of(context).checkoutFees),
        SizedBox(height: 14),
        ...detailItems(
          pairs: struct.fees,
          style: Theme.of(context).checkoutFee,
          fee: true,
        ),
      ];

  Widget total() =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Total', style: Theme.of(context).checkoutTotal),
        Text(
            '${getRightTotal(struct.total)} ${struct.paymentSymbol.toUpperCase()}',
            style: Theme.of(context).checkoutTotal),
      ]);

  String getRightTotal(String x) {
    if (x == 'calculating total...') {
      if (estimate != null) {
        return satToAmount(estimate!.total).toString();
      }
    }
    return x;
  }

  Widget submitButton() => Container(
      height: 40,
      child: OutlinedButton.icon(
          onPressed: () async {
            (struct.buttonAction ?? () {})();
            Navigator.popUntil(components.navigator.routeContext!,
                ModalRoute.withName('/home'));
          },
          icon: Icon(
            struct.buttonIcon,
            color: Color(0xDE000000),
          ),
          label: Text(
            struct.buttonWord.toUpperCase(),
            style: Theme.of(context).navBarButton,
          ),
          style: components.styles.buttons.bottom(context)));
}
