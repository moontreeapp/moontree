import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/pages/wallet/asset_details/asset_details_bloc.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/utils/extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/storage.dart';
import '../../../widgets/back/coinspec/spec.dart';
import '../../../widgets/back/coinspec/tabs.dart';
import '../../../widgets/backdrop/curve.dart';
import '../../../widgets/bottom/navbar.dart';
import '../../../widgets/front/lists/transactions.dart';
import 'package:raven_back/raven_back.dart';

class MetaDataWidget extends StatelessWidget {
  const MetaDataWidget(this.cacheView, {Key? key}) : super(key: key);
  final Widget? cacheView;

  @override
  Widget build(BuildContext context) {
    return cacheView ??
        components.empty.message(
          context,
          icon: Icons.description,
          msg: '\nNo metadata.\n',
        );
  }
}

class AssetNavbar extends StatelessWidget {
  const AssetNavbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavBar(
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
          arguments: assetDetailsBloc.security != res.securities.RVN
              ? {'symbol': assetDetailsBloc.security.symbol}
              : null,
        )
      ],
    );
  }
}

class AssetDetailsContent extends StatelessWidget {
  const AssetDetailsContent(this.cachedMetadataView, this.scrollController,
      {Key? key})
      : super(key: key);
  final Widget? cachedMetadataView;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
        stream: streams.app.coinspec,
        builder: (context, snapshot) {
          final showTransactions =
              assetDetailsBloc.tabChoice == CoinSpecTabs.tabIndex[0];
          return showTransactions
              ? TransactionList(
                  scrollController: scrollController,
                  symbol: assetDetailsBloc.security.symbol,
                  transactions: assetDetailsBloc.currentTxs.where((tx) =>
                      tx.security.symbol == assetDetailsBloc.security.symbol),
                  msg:
                      '\nNo ${assetDetailsBloc.security.symbol} transactions.\n')
              : MetaDataWidget(cachedMetadataView);
        });
  }
}

class CoinDetailsHeader extends StatelessWidget {
  const CoinDetailsHeader(
    this.security,
    this.emptyMetaDataCache, {
    Key? key,
  }) : super(key: key);
  final Security security;
  final bool emptyMetaDataCache;

  @override
  Widget build(BuildContext context) {
    final bloc = AssetDetailsBloc.instance();
    return StreamBuilder(
        stream: bloc.scrollObserver,
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
                bottom: emptyMetaDataCache ? null : Container(),
              ),
            ),
          );
        });
  }
}

class CoinDetailsGlidingSheet extends StatefulWidget {
  const CoinDetailsGlidingSheet(
    this.cachedMetadataView,
    this.dController,
    this.scrollController, {
    Key? key,
  }) : super(key: key);
  final Widget? cachedMetadataView;
  final DraggableScrollableController dController;
  final ScrollController scrollController;

  @override
  State<CoinDetailsGlidingSheet> createState() =>
      _CoinDetailsGlidingSheetState();
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
              child: AssetDetailsContent(
                widget.cachedMetadataView,
                widget.scrollController,
              ),
            ))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    assetDetailsBloc.reset();
    super.dispose();
  }
}

double minHeight = 0.65.figmaAppHeight;

class MetadataView extends StatelessWidget {
  const MetadataView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Asset securityAsset = assetDetailsBloc.security.asset!;

    var chilren = <Widget>[];
    if (securityAsset.primaryMetadata == null &&
        securityAsset.hasData &&
        securityAsset.data!.isIpfs) {
      final height =
          (assetDetailsBloc.scrollObserver.value.ofMediaHeight(context) + 32) /
              2;
      return Container(
        alignment: Alignment.topCenter,
        height: height,
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
