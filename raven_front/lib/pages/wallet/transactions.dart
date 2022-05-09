/// this file could be removed with slight modifications to transactions.dart
/// that should probably happen at some point - when we start using assets more.

import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction/transaction.dart';
//import 'package:raven_front/backdrop/backdrop.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/services/storage.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/utils/data.dart';
import 'package:raven_front/utils/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_front/components/components.dart';
import 'package:url_launcher/url_launcher.dart';

class Transactions extends StatefulWidget {
  const Transactions({Key? key}) : super(key: key);

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions>
    with TickerProviderStateMixin {
  Map<String, dynamic> data = {};
  late List<TransactionRecord> currentTxs;
  late List<Balance> currentHolds;
  late Security security;
  Widget? cachedMetadataView;
  DraggableScrollableController dController = DraggableScrollableController();
  ValueNotifier<double> valueNotifier = ValueNotifier<double>(0.9);

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    security = data['holding']!.security;
    currentHolds = Current.holdings;
    currentTxs = services.transaction
        .getTransactionRecords(wallet: Current.wallet, securities: {security});

    cachedMetadataView = _metadataView(security, context);
    return BackdropLayers(
        back: CoinDetailsHeader(
          security,
          cachedMetadataView,
          dController,
          valueNotifier,
        ),
        front: CoinDetailsGlidingSheet(
          currentTxs,
          cachedMetadataView,
          security,
          dController,
          valueNotifier,
        ));
  }
}

class CoinDetailsGlidingSheet extends StatefulWidget {
  const CoinDetailsGlidingSheet(
    this.currentTxs,
    this.cachedMetadataView,
    this.security,
    this.dController,
    this.valueNotifier, {
    Key? key,
  }) : super(key: key);
  final List<TransactionRecord> currentTxs;
  final Security security;
  final Widget? cachedMetadataView;
  final DraggableScrollableController dController;
  final ValueNotifier<double> valueNotifier;

  @override
  State<CoinDetailsGlidingSheet> createState() =>
      _CoinDetailsGlidingSheetState();
}

class _CoinDetailsGlidingSheetState extends State<CoinDetailsGlidingSheet> {
  String tabChoice = 'HISTORY';
  List<StreamSubscription> listeners = [];

  @override
  void initState() {
    super.initState();
    listeners.add(res.balances.batchedChanges.listen((batchedChanges) {
      if (batchedChanges.isNotEmpty) setState(() {});
    }));
    listeners.add(streams.app.coinspec.listen((String? value) {
      if (value != null) {
        setState(() {
          tabChoice = value;
          streams.app.coinspec.add(null);
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
    var minHeight = .7245;
    var maxExtent = (widget.currentTxs.length * 80 +
            80 +
            40 +
            (!services.download.history.downloads_complete ? 80 : 0))
        .ofMediaHeight(context);
    return Stack(alignment: Alignment.bottomCenter, children: [
      DraggableScrollableSheet(
        initialChildSize: minHeight,
        minChildSize: minHeight,
        maxChildSize: min(1.0, max(minHeight, maxExtent)),
        controller: widget.dController,
        //snap: true, // if snap then show amount in app bar
        builder: ((context, ScrollController scrollController) {
          //print("Drag offset ${dController.size}");
          widget.valueNotifier.value = widget.dController.size;

          return Stack(
            alignment: Alignment.topCenter,
            children: [
              CoinSpecTabs(),
              Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: FrontCurve(
                    frontLayerBoxShadow: [],
                    child: content(
                      scrollController,
                      tabChoice,
                      widget.currentTxs,
                      widget.security,
                      context,
                      widget.cachedMetadataView,
                    ),
                  ))
            ],
          );
        }),
      ),
      NavBar(
        includeSectors: false,
        actionButtons: <Widget>[
          components.buttons.actionButton(
            context,
            label: 'send',
            link: '/transaction/send',
          ),
          components.buttons.actionButton(
            context,
            label: 'receive',
            link: '/transaction/receive',
            arguments: widget.security != res.securities.RVN
                ? {'symbol': widget.security.symbol}
                : null,
          )
        ],
      ),
    ]);
  }
}

class CoinDetailsHeader extends StatelessWidget {
  const CoinDetailsHeader(
    this.security,
    this.cachedMetadataView,
    this.dController,
    this.valueNotifier, {
    Key? key,
  }) : super(key: key);
  final Security security;
  final Widget? cachedMetadataView;
  final DraggableScrollableController dController;
  final ValueNotifier<double> valueNotifier;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: valueNotifier,
        builder: (context, widget) {
          //print("Opacity to change ${dController.size}");

          return Transform.rotate(
            angle: valueNotifier.value * pi * 180,
            //opacity: getOpacityFromController(dController.size),
            child: CoinSpec(
              pageTitle: 'Transactions',
              security: security,
              bottom: cachedMetadataView != null ? null : Container(),
            ),
          );
        });
  }

  double getOpacityFromController(double controllerValue) {
    if (controllerValue >= 0.9) return 1;
    if (controllerValue <= 0.72) return 0;
    return (0.9 - controllerValue) * 5;
  }
}

Widget? _metadataView(Security security, BuildContext context) {
  var securityAsset = security.asset;
  if (securityAsset == null || securityAsset.hasMetadata == false) {
    return null;
  }
  var chilren = <Widget>[];
  if (securityAsset.primaryMetadata == null &&
      securityAsset.hasData &&
      securityAsset.data!.isIpfs) {
    return Container(
        alignment: Alignment.topCenter,
        height:
            (MediaQuery.of(context).size.height - (72.figma(context) + 56)) *
                0.5,
        child: InkWell(
            child: Text('VIEW DATA', //Text('${securityAsset.metadata}',
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    fontWeight: FontWeights.bold,
                    letterSpacing: 1.25,
                    color: AppColors.primary)),
            onTap: () => components.message.giveChoices(
                  context,
                  title: 'View Data',
                  content: 'View data in external browser?',
                  behaviors: {
                    'CANCEL': Navigator.of(context).pop,
                    'BROWSER': () {
                      Navigator.of(context).pop();
                      launch(
                          'https://ipfs.io/ipfs/${securityAsset.metadata}'); //'https://gateway.ipfs.io/ipfs/'
                    },
                  },
                )));
  } else if (securityAsset.primaryMetadata == null) {
    chilren = [SelectableText(securityAsset.metadata)];
  } else if (securityAsset.primaryMetadata!.kind == MetadataType.ImagePath) {
    chilren = [
      Image.file(AssetLogos()
          .readImageFileNow(securityAsset.primaryMetadata!.data ?? ''))
    ];
  } else if (securityAsset.primaryMetadata!.kind == MetadataType.JsonString) {
    chilren = [SelectableText(securityAsset.primaryMetadata!.data ?? '')];
  } else if (securityAsset.primaryMetadata!.kind == MetadataType.Unknown) {
    chilren = [
      SelectableText(securityAsset.primaryMetadata!.metadata),
      SelectableText(securityAsset.primaryMetadata!.data ?? '')
    ];
  }
  return ListView(padding: EdgeInsets.all(10.0), children: chilren);
}

Widget metadata(Widget? chachedView, BuildContext context) =>
    chachedView ??
    components.empty.message(
      context,
      icon: Icons.description,
      msg: '\nNo metadata.\n',
    );

Widget content(
        ScrollController scrollController,
        String tabChoice,
        List<TransactionRecord> currentTxs,
        Security security,
        BuildContext context,
        Widget? cachedMetadataView) =>
    tabChoice == CoinSpecTabs.tabIndex[0]
        ? TransactionList(
            scrollController: scrollController,
            transactions:
                currentTxs.where((tx) => tx.security.symbol == security.symbol),
            msg: '\nNo ${security.symbol} transactions.\n')
        : metadata(cachedMetadataView,
            context); //(scrollController: scrollController) //at present we can't scroll metadata
