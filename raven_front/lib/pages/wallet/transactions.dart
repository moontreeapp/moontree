import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction/transaction.dart';
import 'package:raven_front/pages/wallet/asset_details/assset_details_components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/services/storage.dart';
import 'package:raven_front/utils/data.dart';
import 'package:raven_front/utils/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_front/components/components.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

import 'asset_details/asset_details_bloc.dart';

double minHeight = 0.65.figmaAppHeight;

class Transactions extends StatefulWidget {
  const Transactions({Key? key}) : super(key: key);

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  late List<StreamSubscription> listeners = [];
  Widget? cachedMetadataView;
  DraggableScrollableController dController = DraggableScrollableController();
  BehaviorSubject<double> scrollObserver = BehaviorSubject.seeded(.91);
  @override
  void initState() {
    super.initState();
    AssetDetailsBloc.reset();

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
    final AssetDetailsBloc bloc = AssetDetailsBloc.instance();

    bloc.data = populateData(context, bloc.data);
    // security = bloc.data['holding']!.security;
    // currentHolds = Current.holdings;
    // currentTxs = services.transaction
    //     .getTransactionRecords(wallet: Current.wallet, securities: {security});
    cachedMetadataView = _metadataView(bloc.security, context);
    minHeight =
        0.65.figmaAppHeight + (cachedMetadataView != null ? 48.ofAppHeight : 0);
    var maxExtent = (bloc.currentTxs.length * 80 +
            80 +
            40 +
            (!services.download.history.isComplete ? 80 : 0))
        .ofMediaHeight(context);
    return BackdropLayers(
        back: CoinDetailsHeader(bloc.security, cachedMetadataView, scrollObserver),
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
                    bloc.currentTxs,
                    _metadataView(bloc.security, context),
                    bloc.security,
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
                  arguments: bloc.security != res.securities.RVN
                      ? {'symbol': bloc.security.symbol}
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
          ),
        ),
      );
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
    final bloc = AssetDetailsBloc.instance();
    return StreamBuilder(
        stream: scrollObserver,
        builder: (context, snapshot) {
          return Transform.translate(
            offset: Offset(
                0,
                0 -
                    (((snapshot.data ?? minHeight) as double) - minHeight) *
                        100),
            child: Opacity(
              //angle: ((snapshot.data ?? 0.9) as double) * pi * 180,
              opacity: bloc.getOpacityFromController(
                  (snapshot.data ?? .9) as double, minHeight),
              child: CoinSpec(
                pageTitle: 'Transactions',
                security: security,
                bottom: cachedMetadataView != null ? null : Container(),
              ),
            ),
          );
        });
  }
}

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
        : MetaDataWidget(
            cachedMetadataView); //(scrollController: scrollController) //at present we can't scroll metadata
