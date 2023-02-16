import 'package:client_back/server/src/protocol/asset_metadata_class.dart';
import 'package:client_back/server/src/protocol/protocol.dart';
import 'package:flutter/material.dart';
import 'package:client_back/services/transaction/transaction.dart';
import 'package:client_front/application/cubits.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet_utils/src/utilities/validation_ext.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_back/streams/client.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/presentation/widgets/back/coinspec/spec.dart';
import 'package:client_front/presentation/widgets/back/coinspec/tabs.dart';
import 'package:client_front/presentation/widgets/backdrop/curve.dart';
import 'package:client_front/presentation/widgets/bottom/navbar.dart';
import 'package:client_front/presentation/widgets/front/lists/transactions.dart';
import 'package:wallet_utils/wallet_utils.dart';

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
  final TransactionsViewCubit cubit;
  const AssetNavbar({Key? key, required this.cubit}) : super(key: key);

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
          arguments: <String, dynamic>{'security': cubit.state.security},
        ),
        components.buttons.actionButton(
          context,
          label: 'receive',
          link: '/transaction/receive',
          arguments: cubit.state.security != pros.securities.currentCoin
              ? <String, dynamic>{'symbol': cubit.state.security.symbol}
              : null,
        )
      ],
    );
  }
}

class TransactionsContent extends StatelessWidget {
  const TransactionsContent(
    this.cubit,
    this.cachedMetadataView,
    this.scrollController, {
    Key? key,
  }) : super(key: key);
  final TransactionsViewCubit cubit;
  final Widget? cachedMetadataView;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: cubit.state.currentTab,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          final String tab = snapshot.data ?? 'HISTORY';
          final bool showTransactions = tab == CoinSpecTabs.tabIndex[0];
          return showTransactions
              ? TransactionList(
                  cubit: cubit,
                  scrollController: scrollController,
                  symbol: cubit.state.security.symbol,
                  transactions: cubit.state.transactionViews,
                  msg: '\nNo ${cubit.state.security.symbol} transactions.\n')
              : MetaDataWidget(cachedMetadataView);
        });
  }
}

class CoinDetailsHeader extends StatelessWidget {
  const CoinDetailsHeader(
    this.cubit,
    this.security,
    this.minHeight,
    this.emptyMetaDataCache, {
    required this.balanceView,
    Key? key,
  }) : super(key: key);
  final TransactionsViewCubit cubit;
  final Security security;
  final bool emptyMetaDataCache;
  final double minHeight;
  final BalanceView balanceView;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
        stream: cubit.state.scrollObserver,
        builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
          return Transform.translate(
            offset: Offset(
                0,
                0 -
                    (((snapshot.data ?? minHeight) as double) - minHeight) *
                        100),
            child: Opacity(
              //angle: ((snapshot.data ?? 0.9) as double) * pi * 180,
              opacity: getOpacityFromController(
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
  const CoinDetailsGlidingSheet({
    this.cachedMetadataView,
    required this.cubit,
    required this.dController,
    required this.scrollController,
    Key? key,
  }) : super(key: key);
  final TransactionsViewCubit cubit;
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
    widget.cubit.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        if (widget.cachedMetadataView != null)
          CoinSpecTabs(cubit: widget.cubit),
        Padding(
            padding: EdgeInsets.only(
                top: widget.cachedMetadataView != null ? 48 : 0),
            child: FrontCurve(
              frontLayerBoxShadow: const <BoxShadow>[],
              child: TransactionsContent(
                widget.cubit,
                widget.cachedMetadataView,
                widget.scrollController,
              ),
            ))
      ],
    );
  }
}

class MetadataView extends StatelessWidget {
  final TransactionsViewCubit cubit;
  const MetadataView({Key? key, required this.cubit}) : super(key: key);

  Future<void> refresh() async {
    //setState(() {
    cubit.setMetadataView(force: true);
    //});
  }

  @override
  Widget build(BuildContext context) {
    //final Asset securityAsset = cubit.state.security.asset!;
    final AssetMetadata? securityAsset = cubit.state.metadataView;

    List<Widget> children = <Widget>[];
    //if (securityAsset.primaryMetadata == null &&
    //    securityAsset.hasData &&
    //    securityAsset.data!.isIpfs) {
    if (securityAsset != null) {
      if (securityAsset.associatedData != null) {
        if (securityAsset.associatedData!.toHex().isIpfs) {
          return Container(
            alignment: Alignment.topCenter,
            height:
                (cubit.state.scrollObserver.value.ofMediaHeight(context) + 32) /
                    2,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: components.buttons.actionButtonSoft(
                context,
                label: 'View Data',
                onPressed: () => components.message.giveChoices(
                  context,
                  title: 'View Data',
                  content: 'View data in external browser?',
                  behaviors: <String, void Function()>{
                    'CANCEL': Navigator.of(context).pop,
                    'BROWSER': () {
                      Navigator.of(context).pop();
                      launchUrl(Uri.parse(
                          'https://ipfs.io/ipfs/${securityAsset.associatedData!.toHex()}'));
                    },
                  },
                ),
              ),
            ),
          );
        } else {
          // not ipfs - show whatever it is. todo: handle image etc here.
          children = <Widget>[
            SelectableText(securityAsset.associatedData!.toHex())
          ];
        }
      } else {
        // no associated data - show details
        children = <Widget>[
          ListTile(
            title: Text(
              'Total Supply:',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            trailing: SelectableText(
              securityAsset.totalSupply.toCommaString(),
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          ListTile(
            title: Text(
              'Divisibility:',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            trailing: SelectableText(
              '${securityAsset.divisibility}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          ListTile(
            title: Text(
              'Reissuable:',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            trailing: SelectableText(
              '${securityAsset.reissuable ? 'yes' : 'no'}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          ListTile(
            title: Text(
              'Frozen:',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            trailing: SelectableText(
              '${securityAsset.frozen ? 'yes' : 'no'}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        ];
      }
    } else {
      // asset metadata not found
    }
    //} else if (securityAsset.primaryMetadata == null) {
    //children = <Widget>[SelectableText(securityAsset.metadata)];
    //} else if (securityAsset.primaryMetadata!.kind == MetadataType.imagePath) {
    //  children = <Widget>[
    //    Image.file(AssetLogos()
    //        .readImageFileNow(securityAsset.primaryMetadata!.data ?? ''))
    //  ];
    //} else if (securityAsset.primaryMetadata!.kind == MetadataType.jsonString) {
    //  children = <Widget>[
    //    SelectableText(securityAsset.primaryMetadata!.data ?? '')
    //  ];
    //} else if (securityAsset.primaryMetadata!.kind == MetadataType.unknown) {
    //  children = <Widget>[
    //    SelectableText(securityAsset.primaryMetadata!.metadata),
    //    SelectableText(securityAsset.primaryMetadata!.data ?? '')
    //  ];
    //}
    return RefreshIndicator(
        onRefresh: () => refresh(),
        child:
            ListView(padding: const EdgeInsets.all(10.0), children: children));
  }
}

double getOpacityFromController(
  double controllerValue,
  double minHeightFactor,
) {
  double opacity = 1;
  if (controllerValue >= 0.9) {
    opacity = 0;
  } else if (controllerValue <= minHeightFactor) {
    opacity = 1;
  } else {
    opacity = (0.9 - controllerValue) * 5;
  }
  if (opacity > 1) {
    return 1;
  }
  if (opacity < 0) {
    return 0;
  }
  return opacity;
}
