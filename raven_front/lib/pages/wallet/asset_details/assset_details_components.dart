import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/pages/wallet/asset_details/asset_details_bloc.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/utils/extensions.dart';
import '../../../widgets/back/coinspec/spec.dart';
import '../../../widgets/back/coinspec/tabs.dart';
import '../../../widgets/backdrop/curve.dart';
import '../../../widgets/bottom/navbar.dart';
import '../../../widgets/front/lists/transactions.dart';

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
    ;
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
    return assetDetailsBloc.tabChoice == CoinSpecTabs.tabIndex[0]
        ? TransactionList(
            scrollController: scrollController,
            symbol: assetDetailsBloc.security.symbol,
            transactions: assetDetailsBloc.currentTxs.where(
                (tx) => tx.security.symbol == assetDetailsBloc.security.symbol),
            msg: '\nNo ${assetDetailsBloc.security.symbol} transactions.\n')
        : MetaDataWidget(cachedMetadataView);
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
                bottom: emptyMetaDataCache? null : Container(),
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
