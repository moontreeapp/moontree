import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/streams/client.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/pages/wallet/transactions/bloc.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/utils/extensions.dart';
import 'package:ravencoin_front/services/storage.dart';
import 'package:ravencoin_front/widgets/back/coinspec/spec.dart';
import 'package:ravencoin_front/widgets/back/coinspec/tabs.dart';
import 'package:ravencoin_front/widgets/backdrop/curve.dart';
import 'package:ravencoin_front/widgets/bottom/navbar.dart';
import 'package:ravencoin_front/widgets/front/lists/transactions.dart';

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
    final bool walletIsEmpty = Current.wallet.balances.isEmpty;
    final ConnectionStatus connectionStatus = streams.client.connected.value;
    return NavBar(
      includeSectors: false,
      actionButtons: <Widget>[
        components.buttons.actionButton(
          context,
          label: 'send',
          link: '/transaction/send',
          enabled:
              !walletIsEmpty && connectionStatus == ConnectionStatus.connected,
          disabledOnPressed: () {
            streams.app.snack.add(Snack(
              message: 'Unable to send, please try again later',
            ));
          },
          arguments: {'security': transactionsBloc.security},
        ),
        components.buttons.actionButton(
          context,
          label: 'receive',
          link: '/transaction/receive',
          arguments: transactionsBloc.security != pros.securities.currentCoin
              ? {'symbol': transactionsBloc.security.symbol}
              : null,
        )
      ],
    );
  }
}

class TransactionsContent extends StatelessWidget {
  const TransactionsContent(this.cachedMetadataView, this.scrollController,
      {Key? key})
      : super(key: key);
  final Widget? cachedMetadataView;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: transactionsBloc.currentTab,
        builder: (context, snapshot) {
          final tab = snapshot.data ?? 'HISTORY';
          final showTransactions = tab == CoinSpecTabs.tabIndex[0];
          return showTransactions
              ? TransactionList(
                  scrollController: scrollController,
                  symbol: transactionsBloc.security.symbol,
                  transactions: transactionsBloc.currentTxs.where((tx) =>
                      tx.security.symbol == transactionsBloc.security.symbol),
                  msg:
                      '\nNo ${transactionsBloc.security.symbol} transactions.\n')
              : MetaDataWidget(cachedMetadataView);
        });
  }
}

class CoinDetailsHeader extends StatelessWidget {
  final Security security;
  final bool emptyMetaDataCache;
  final double minHeight;

  const CoinDetailsHeader(
    this.security,
    this.minHeight,
    this.emptyMetaDataCache, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = TransactionsBloc.instance();
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
                (snapshot.data ?? .9) as double,
                minHeight,
              ),
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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    transactionsBloc.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        if (widget.cachedMetadataView != null) CoinSpecTabs(),
        Padding(
            padding: EdgeInsets.only(
                top: widget.cachedMetadataView != null ? 48 : 0),
            child: FrontCurve(
              frontLayerBoxShadow: [],
              child: TransactionsContent(
                widget.cachedMetadataView,
                widget.scrollController,
              ),
            ))
      ],
    );
  }
}

class MetadataView extends StatelessWidget {
  const MetadataView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Asset securityAsset = transactionsBloc.security.asset!;

    var chilren = <Widget>[];
    if (securityAsset.primaryMetadata == null &&
        securityAsset.hasData &&
        securityAsset.data!.isIpfs) {
      final height =
          (transactionsBloc.scrollObserver.value.ofMediaHeight(context) + 32) /
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
                  launchUrl(Uri.parse(
                      'https://ipfs.io/ipfs/${securityAsset.metadata}'));
                },
              },
            ),
          ),
        ),
      );
    } else if (securityAsset.primaryMetadata == null) {
      chilren = [SelectableText(securityAsset.metadata)];
    } else if (securityAsset.primaryMetadata!.kind == MetadataType.imagePath) {
      chilren = [
        Image.file(AssetLogos()
            .readImageFileNow(securityAsset.primaryMetadata!.data ?? ''))
      ];
    } else if (securityAsset.primaryMetadata!.kind == MetadataType.jsonString) {
      chilren = [SelectableText(securityAsset.primaryMetadata!.data ?? '')];
    } else if (securityAsset.primaryMetadata!.kind == MetadataType.unknown) {
      chilren = [
        SelectableText(securityAsset.primaryMetadata!.metadata),
        SelectableText(securityAsset.primaryMetadata!.data ?? '')
      ];
    }
    return ListView(padding: EdgeInsets.all(10.0), children: chilren);
  }
}
