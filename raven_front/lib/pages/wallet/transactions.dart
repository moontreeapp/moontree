import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction/transaction.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/services/storage.dart';
import 'package:raven_front/utils/data.dart';
import 'package:raven_front/utils/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_front/components/components.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

class Transactions extends StatefulWidget {
  const Transactions({Key? key}) : super(key: key);

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  late List<StreamSubscription> listeners = [];
  Map<String, dynamic> data = {};
  late List<TransactionRecord> currentTxs;
  late List<Balance> currentHolds;
  late Security security;
  Widget? cachedMetadataView;
  DraggableScrollableController dController = DraggableScrollableController();
  BehaviorSubject<double> scrollObserver = BehaviorSubject.seeded(.7245);
  @override
  void initState() {
    super.initState();
    listeners.add(streams.client.busy.listen((bool value) {
      if (!value) {
        setState(() {});
      }
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    scrollObserver.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    security = data['holding']!.security;
    currentHolds = Current.holdings;
    currentTxs = services.transaction
        .getTransactionRecords(wallet: Current.wallet, securities: {security});
    cachedMetadataView = _metadataView(security, context);
    var minHeight = .7245;
    var maxExtent = (currentTxs.length * 80 +
            80 +
            40 +
            (!services.download.history.downloads_complete ? 80 : 0))
        .ofMediaHeight(context);
    return BackdropLayers(
        back: CoinDetailsHeader(security, cachedMetadataView, scrollObserver),
        front: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            DraggableScrollableSheet(
                initialChildSize: minHeight,
                minChildSize: minHeight,
                maxChildSize: min(1.0, max(minHeight, maxExtent)),
                controller: dController,
                builder: (context, scrollController) {
                  scrollObserver.add(dController.size);
                  return CoinDetailsGlidingSheet(
                    currentTxs,
                    _metadataView(security, context),
                    security,
                    dController,
                    scrollController,
                  );
                }),
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
                  arguments: security != res.securities.RVN
                      ? {'symbol': security.symbol}
                      : null,
                )
              ],
            ),
          ],
        ));
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
          height: (scrollObserver.value.ofMediaHeight(context) + 16 + 16) / 2,
          child: Padding(
              padding: EdgeInsets.only(top: 16),
              child: components.buttons.actionButtonSoft(
                context,
                label: 'View Data',
                onPressed: () => components.message.giveChoices(
                  context,
                  title: 'View Data',
                  content: 'View data in external browser?',
                  behaviors: {
                    'CANCEL': Navigator.of(context).pop,
                    'BROWSER': () {
                      Navigator.of(context).pop();
                      launch('https://ipfs.io/ipfs/${securityAsset.metadata}');
                    },
                  },
                ),
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
}

class _CoinDetailsGlidingSheetState extends State<CoinDetailsGlidingSheet> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        if (widget.cachedMetadataView != null) CoinSpecTabs(),
        Padding(
            padding: EdgeInsets.only(
                top: widget.cachedMetadataView != null ? 48 : 0),
            child: FrontCurve(
              frontLayerBoxShadow: [],
              child: content(
                widget.scrollController,
                tabChoice,
                widget.currentTxs,
                widget.security,
                context,
                widget.cachedMetadataView,
              ),
            ))
      ],
    );
  }

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
}

class CoinDetailsGlidingSheet extends StatefulWidget {
  const CoinDetailsGlidingSheet(
    this.currentTxs,
    this.cachedMetadataView,
    this.security,
    this.dController,
    this.scrollController, {
    Key? key,
  }) : super(key: key);
  final List<TransactionRecord> currentTxs;
  final Security security;
  final Widget? cachedMetadataView;
  final DraggableScrollableController dController;
  final ScrollController scrollController;

  @override
  State<CoinDetailsGlidingSheet> createState() =>
      _CoinDetailsGlidingSheetState();
}

class CoinDetailsHeader extends StatelessWidget {
  const CoinDetailsHeader(
    this.security,
    this.cachedMetadataView,
    this.scrollObserver, {
    Key? key,
  }) : super(key: key);
  final Security security;
  final Widget? cachedMetadataView;
  final Stream<double> scrollObserver;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: scrollObserver,
        initialData: 0.9,
        builder: (context, snapshot) {
          //print("Opacity to change ${dController.size}");

          return Transform.translate(
            offset: Offset(0, (0.9 - ((snapshot.data ?? 0.9) as double)) * 200),
            child: Opacity(
              //angle: ((snapshot.data ?? 0.9) as double) * pi * 180,
              opacity:
                  getOpacityFromController((snapshot.data ?? 0.9) as double),
              child: CoinSpec(
                pageTitle: 'Transactions',
                security: security,
                bottom: cachedMetadataView != null ? null : Container(),
              ),
            ),
          );
        });
  }

  double getOpacityFromController(double controllerValue) {
    double opacity = 1;
    if (controllerValue >= 0.9)
      opacity = 0;
    else if (controllerValue <= 0.72)
      opacity = 1;
    else
      opacity = (0.9 - controllerValue) * 5;
    return opacity;
  }
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
  Widget? cachedMetadataView,
) =>
    tabChoice == CoinSpecTabs.tabIndex[0]
        ? TransactionList(
            scrollController: scrollController,
            symbol: security.symbol,
            transactions:
                currentTxs.where((tx) => tx.security.symbol == security.symbol),
            msg: '\nNo ${security.symbol} transactions.\n')
        : metadata(cachedMetadataView,
            context); //(scrollController: scrollController) //at present we can't scroll metadata
