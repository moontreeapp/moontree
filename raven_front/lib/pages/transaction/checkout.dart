import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';

class Checkout extends StatefulWidget {
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
    ['IPFS/Txid Hash', 'QmXwHQ43NrZPq'],
    ['IPFS/Txid Hash', 'QmXwHQ43NrZPq123456789'],
    [
      'Limited Multiline Item',
      '(#KYC && #COOLDUDE) || (#OVERRIDE || #MOONTREE) && (!! #IRS) && (!! #BASTARD)',
      '2'
    ],
    [
      'Multiline Item',
      '(#KYC && #COOLDUDE) || (#OVERRIDE || #MOONTREE) && (!! #IRS) && (!! #BASTARD)',
      '5'
    ]
  ];
  static const Iterable<Iterable<String>> exampleFees = [
    ['Transaction', '1'],
    ['Sub Asset', '100'],
    ['long amount', '21,000,000.00000000']
  ];

  const Checkout({
    Key? key,
    this.symbol = 'MoonTree',
    this.subSymbol = 'Main/',
    this.paymentSymbol = 'RVN',
    this.items = exampleItems,
    this.fees = exampleFees,
    this.total = '101',
    this.buttonAction,
    this.buttonIcon = Icons.add_rounded,
    this.buttonWord = 'Submit',
  }) : super(key: key);

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => body();

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
      leading: components.icons.assetAvatar(widget.symbol.toUpperCase()),
      title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(width: 5),
        Text(widget.symbol.toUpperCase(),
            style: Theme.of(context).checkoutAsset)
      ]),
      subtitle: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(width: 5),
        Text(widget.subSymbol.toUpperCase(),
            style: Theme.of(context).checkoutSubAsset),
      ]));

  Widget transactionItems() => Padding(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ...detailItems(
              pairs: widget.items, style: Theme.of(context).checkoutItem)
        ],
      ));

  Iterable<Widget> detailItems({
    required Iterable<Iterable<String>> pairs,
    TextStyle? style,
    bool fee = false,
  }) =>
      [
        for (var pair in pairs) ...[
          // ignore: unnecessary_cast
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pair.toList()[0], style: style),
                fee || pair.toList()[1].length < 17
                    ? Text(pair.toList()[1], style: style)
                    : Container(
                        width:
                            (MediaQuery.of(context).size.width - 16 - 16) / 2,
                        child: Text(
                          pair.toList()[1],
                          style: style,
                          overflow: pair.length == 2
                              ? TextOverflow.fade
                              : TextOverflow.ellipsis,
                          softWrap: pair.length == 2 ? false : true,
                          maxLines: pair.length == 2
                              ? 1
                              : int.parse(pair.toList()[2]),
                        )),
              ]) as Widget,
        ]
      ].intersperse(SizedBox(height: 21));

  String cutString(String x) => x.length > 13 ? x.substring(0, 13) + '...' : x;

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
          pairs: widget.fees,
          style: Theme.of(context).checkoutFee,
          fee: true,
        ),
      ];

  Widget total() =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Total', style: Theme.of(context).checkoutTotal),
        Text('${widget.total} ${widget.paymentSymbol.toUpperCase()}',
            style: Theme.of(context).checkoutTotal),
      ]);

  Widget submitButton() => Container(
      height: 40,
      child: OutlinedButton.icon(
          onPressed: () async {
            (widget.buttonAction ?? () {})();
            Navigator.popUntil(components.navigator.routeContext!,
                ModalRoute.withName('/home'));
          },
          icon: Icon(
            widget.buttonIcon,
            color: Color(0xDE000000),
          ),
          label: Text(
            widget.buttonWord.toUpperCase(),
            style: Theme.of(context).navBarButton,
          ),
          style: components.styles.buttons.bottom(context)));
}
