/// this file could be removed with slight modifications to transactions.dart
/// that should probably happen at some point - when we start using assets more.

import 'dart:async';
import 'dart:math';

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
  late AnimationController controller;
  late Animation<Offset> offset;
  Map<String, dynamic> data = {};
  List<StreamSubscription> listeners = [];
  bool showUSD = false;
  late List<TransactionRecord> currentTxs;
  late List<Balance> currentHolds;
  late Security security;
  String tabChoice = 'HISTORY';
  Widget? cachedMetadataView;
  ValueNotifier<double> _notifier = ValueNotifier(1);
  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    offset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 1.0)).animate(
        CurvedAnimation(
            parent: controller,
            curve: Curves.ease,
            reverseCurve: Curves.ease.flipped));

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
    controller.dispose();
    super.dispose();
  }

  //bool visibilityOfSendReceive(notification) {
  //  if (notification.direction == ScrollDirection.forward &&
  //      Backdrop.of(components.navigator.routeContext!).isBackLayerConcealed) {
  //    Backdrop.of(components.navigator.routeContext!).revealBackLayer();
  //  } else if (notification.direction == ScrollDirection.reverse &&
  //      Backdrop.of(components.navigator.routeContext!).isBackLayerRevealed) {
  //    Backdrop.of(components.navigator.routeContext!).concealBackLayer();
  //  }
  //  return true;
  //}

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    security = data['holding']!.security;
    currentHolds = Current.holdings;
    currentTxs = services.transaction
        .getTransactionRecords(wallet: Current.wallet, securities: {security});
    var maxExtent = (currentTxs.length * 80 +
            80 +
            40 +
            (!services.download.history.downloads_complete ? 80 : 0))
        .ofMediaHeight(context);
    //var minHeight = 1 - (201 + 25) / MediaQuery.of(context).size.height;
    var minHeight = .7245;

    print(minHeight);
    cachedMetadataView = _metadataView();
    DraggableScrollableController dController = DraggableScrollableController();
    return BackdropLayers(
        back:
            // fade this out as we drag up:
            CoinSpec(
          pageTitle: 'Transactions',
          security: security,
          bottom: cachedMetadataView != null ? null : Container(),
        ),
        front: Stack(alignment: Alignment.bottomCenter, children: [
          DraggableScrollableSheet(
              initialChildSize: minHeight,
              minChildSize: minHeight,
              maxChildSize: min(1.0, max(minHeight, maxExtent)),
              controller: dController,
              //snap: true, // if snap then show amount in app bar
              builder: ((context, ScrollController scrollController) {
                //print(scrollController.position.pixels);
                //print(dController.size);
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    CoinSpecTabs(),
                    Padding(
                        padding: EdgeInsets.only(top: 48),
                        child: FrontCurve(
                          frontLayerBoxShadow: [],
                          child: content(scrollController),
                        ))
                    //)
                  ],
                );
              })),
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
        ]));
  }

  Widget content(ScrollController scrollController) => tabChoice ==
          CoinSpecTabs.tabIndex[0]
      ? TransactionList(
          scrollController: scrollController,
          transactions:
              currentTxs.where((tx) => tx.security.symbol == security.symbol),
          msg: '\nNo ${security.symbol} transactions.\n')
      : metadata; //(scrollController: scrollController) //at present we can't scroll metadata

  Widget get metadata =>
      cachedMetadataView ??
      components.empty.message(
        context,
        icon: Icons.description,
        msg: '\nNo metadata.\n',
      );

  Widget? _metadataView() {
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
}
