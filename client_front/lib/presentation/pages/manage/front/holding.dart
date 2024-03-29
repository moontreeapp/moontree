import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/protocol.dart';
import 'package:client_front/application/manage/holding/cubit.dart';
import 'package:client_front/presentation/widgets/front_curve.dart';
import 'package:client_front/presentation/widgets/back/coinspec/tabs.dart';
import 'package:client_front/presentation/services/services.dart' as services;
import 'package:client_front/presentation/components/shadows.dart' as shadows;
import 'package:client_front/presentation/components/components.dart'
    as components;

class ManageHolding extends StatelessWidget {
  const ManageHolding({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('ManageHolding');

  @override
  Widget build(BuildContext context) {
    final ManageHoldingViewCubit cubit =
        BlocProvider.of<ManageHoldingViewCubit>(context);
    // first set the wallet and security so we can set the coinspec
    cubit.set(
        wallet: pros.wallets.currentWallet,
        security: Security(
          symbol: components.cubits.location.state.symbol ??
              cubit.state.security.symbol,
          chain: pros.settings.chain,
          net: pros.settings.net,
        ));
    cubit.setInitial(force: true);
    return Container(
      color: Colors.transparent,
      height: services.screen.frontContainer.maxHeight,
      width: services.screen.width,
      child: MetadataView(cubit: cubit),
    );
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
  final ManageHoldingViewCubit cubit;
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
        //if (widget.cachedMetadataView != null) // always show the tabs, but maybe grey out data if it's not populated
        CoinSpecTabs(manageCubit: widget.cubit),
        FrontCurve(
          color: Colors.white,
          frontLayerBoxShadow: shadows.none,
          child: widget.cachedMetadataView,
        ),
      ],
    );
  }
}

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

class MetadataView extends StatelessWidget {
  final ManageHoldingViewCubit cubit;
  const MetadataView({Key? key, required this.cubit}) : super(key: key);

  Future<void> refresh() async {
    //setState(() {
    cubit.setMetadataView(force: true);
    //});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageHoldingViewCubit, ManageHoldingViewState>(
        builder: (BuildContext context, ManageHoldingViewState state) {
      //final Asset securityAsset = cubit.state.security.asset!;
      final AssetMetadataResponse? securityAsset = state.metadataView;

      List<Widget> children = <Widget>[];
      //if (securityAsset.primaryMetadata == null &&
      //    securityAsset.hasData &&
      //    securityAsset.data!.isIpfs) {
      if (securityAsset != null) {
        final associatedData =
            securityAsset.mempoolAssociatedData ?? securityAsset.associatedData;
        //if (associatedData != null) {
        //  if (associatedData.toHex().isIpfs) {
        //    return Container(
        //      alignment: Alignment.topCenter,
        //      child: Padding(
        //        padding: const EdgeInsets.only(top: 16),
        //        child: components.buttons.actionButtonSoft(
        //          context,
        //          label: 'View Data',
        //          onPressed: () => components.message.giveChoices(
        //            context,
        //            title: 'View Data',
        //            content: 'View data in external browser?',
        //            behaviors: <String, void Function()>{
        //              'CANCEL': Navigator.of(context).pop,
        //              'BROWSER': () {
        //                Navigator.of(context).pop();
        //                launchUrl(Uri.parse(
        //                    'https://ipfs.io/ipfs/${associatedData.toHex()}'));
        //              },
        //            },
        //          ),
        //        ),
        //      ),
        //    );
        //  } else {
        //    // not ipfs - show whatever it is. todo: handle image etc here.
        //    children = <Widget>[SelectableText(associatedData.toHex())];
        //  }
        //} else {
        final associatedMemo = associatedData != null
            ? <Widget>[
                if (!associatedData.toBs58().isIpfs &&
                    !associatedData.toHex().isIpfs)
                  ListTile(
                    dense: true,
                    title: Text(
                      'Memo:',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: Container(
                      width: services.screen.width * .5,
                      child: SelectableText(
                        associatedData.toBs58(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                if (associatedData.toBs58().isIpfs)
                  ListTile(
                    title: Text(
                      'Memo:',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: Container(
                      alignment: Alignment.centerRight,
                      width: services.screen.width * .5,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: components.buttons.actionButtonSoft(
                          context,
                          label: 'View Data',
                          onPressed: () {
                            print(associatedData.toBs58());
                            //components.cubits.extraContainer
                            //    .set(child: SizedBox());
                            //components.message.giveChoices(
                            //  components.routes.context!,
                            //  title: 'View Data',
                            //  content: 'View data in external browser?',
                            //  behaviors: <String, void Function()>{
                            //    'CANCEL':
                            //        () {}, //Navigator.of(components.routes.context!).pop,
                            //    'BROWSER': () {
                            //      //Navigator.of(components.routes.context!).pop();
                            streams.app.loc.browsing.add(true);
                            launchUrl(Uri.parse(
                                'https://ipfs.io/ipfs/${associatedData.toBs58()}'));
                            //    },
                            //  },
                            //);
                          },
                        ),
                      ),
                    ),
                  ),
                if (associatedData.toHex().isIpfs)
                  ListTile(
                    title: Text(
                      'Memo:',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: Container(
                      alignment: Alignment.centerRight,
                      width: services.screen.width * .5,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: components.buttons.actionButtonSoft(
                          context,
                          label: 'View Data',
                          onPressed: () {
                            print(associatedData.toHex());
                            //components.cubits.extraContainer
                            //    .set(child: SizedBox());
                            //components.message.giveChoices(
                            //  components.routes.context!,
                            //  title: 'View Data',
                            //  content: 'View data in external browser?',
                            //  behaviors: <String, void Function()>{
                            //    'CANCEL':
                            //        () {}, //Navigator.of(components.routes.context!).pop,
                            //    'BROWSER': () {
                            //      //Navigator.of(components.routes.context!).pop();
                            streams.app.loc.browsing.add(true);
                            launchUrl(Uri.parse(
                                'https://ipfs.io/ipfs/${associatedData.toHex()}'));
                            //    },
                            //  },
                            //);
                          },
                        ),
                      ),
                    ),
                  ),
              ]
            : <Widget>[];
        // no associated data - show details
        children = <Widget>[
          ListTile(
            dense: true,
            title: Text(
              cubit.state.security.isCoin ? 'Currency:' : 'Asset:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            trailing: Container(
                alignment: Alignment.centerRight,
                width: services.screen.width * .5,
                child: SelectableText(
                  cubit.state.security.symbol,
                  style: Theme.of(context).textTheme.bodyLarge,
                )),
          ),
          ListTile(
            dense: true,
            title: Text(
              'Asset Type:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            trailing: SelectableText(
              cubit.state.security.isCoin
                  ? 'Currency'
                  : Symbol(cubit.state.security.symbol).symbolTypeName,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ListTile(
            dense: true,
            title: Text(
              cubit.state.security.isCoin
                  ? 'Cirulcating Supply:'
                  : 'Total Supply:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            trailing: SelectableText(
              (securityAsset.mempoolTotalSupply ?? securityAsset.totalSupply)
                  .asCoin
                  .toSatsCommaString(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ListTile(
            dense: true,
            title: Text(
              'Divisibility:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            trailing: SelectableText(
              '${(securityAsset.mempoolDivisibility ?? securityAsset.divisibility)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ListTile(
            dense: true,
            title: Text(
              'Reissuable:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            trailing: SelectableText(
              '${(securityAsset.mempoolReissuable ?? securityAsset.reissuable) ? 'yes' : 'no'}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          ListTile(
            dense: true,
            title: Text(
              'Frozen:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            trailing: SelectableText(
              '${(securityAsset.mempoolFrozen ?? securityAsset.frozen) ? 'yes' : 'no'}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          if (associatedMemo.isNotEmpty) ...associatedMemo
        ];
      } else {
        // asset metadata not found or loading
        return components.empty.getTransactionsPlaceholder(
          context,
          scrollController: ScrollController(),
          count: 1,
        );
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
          child: //ListView(
              //padding: const EdgeInsets.all(10.0), children: children)
              ScrollablePageStructure(
            headerSpace: 0,
            heightSpacer: SizedBox(height: 0),
            children: children,
            leftPadding: 0,
            rightPadding: 0,
            topPadding: 16,
          ));
    });
  }
}
