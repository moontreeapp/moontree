import 'package:flutter/material.dart';
import 'package:ravencoin_front/utils/data.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/records/asset.dart' as assetRecord;
import 'package:ravencoin_front/components/components.dart';

class Asset extends StatefulWidget {
  const Asset() : super();

  @override
  _AssetState createState() => _AssetState();
}

class _AssetState extends State<Asset> {
  Map<String, dynamic> data = {};

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    var symbol = data['symbol'] as String;
    var chosenAsset = pros.assets.bySymbol.getOne(symbol)!;
    return BackdropLayers(
      back: CoinSpec(
          pageTitle: 'Asset',
          security: pros.securities.bySymbolSecurityType
              .getOne(symbol, SecurityType.RavenAsset)!),
      front: FrontCurve(
          height: MediaQuery.of(context).size.height - (201 + 56),
          child: Column(children: [
            Expanded(child: AssetDetails(symbol: symbol)),
            NavBar(
              includeSectors: false,
              actionButtons: <Widget>[
                if ([AssetType.Main, AssetType.Sub]
                    .contains(chosenAsset.assetType)) ...[
                  components.buttons.actionButton(context,
                      label: 'create', onPressed: _produceSubCreateModal),
                ],
                if ([
                  AssetType.Qualifier,
                  AssetType.QualifierSub,
                ].contains(chosenAsset.assetType)) ...[
                  components.buttons.actionButton(context,
                      label: 'create',
                      onPressed: () => Navigator.pushNamed(
                            components.navigator.routeContext!,
                            '/create/qualifiersub',
                            arguments: {'symbol': 'QualifierSub'},
                          )),
                ],
                components.buttons.actionButton(context, label: 'manage',
                    onPressed: () {
                  // if main do this
                  _produceMainManageModal(chosenAsset);
                  // if sub do this
                  //_produceSubManageModal();
                  // if other do this
                  //
                }),
              ],
            )
          ])),
    );
  }

  void _produceSubCreateModal() {
    SelectionItems(context, modalSet: SelectionSet.Sub_Asset).build();
  }

  void _produceMainManageModal(assetRecord.Asset asset) async {
    if (asset.reissuable &&
        [AssetType.Main, AssetType.Sub, AssetType.Restricted]
            .contains(asset.assetType)) {
      await SelectionItems(
        context,
        //symbol: symbol,
        modalSet: SelectionSet.MainManage,
        behaviors: [
          () {
            Navigator.pushNamed(
              context,
              '/reissue/' + asset.assetType.enumString.toLowerCase(),
              arguments: {'symbol': asset.symbol},
            );
          },
          () {
            ///Navigator.pushNamed(
            ///  context,
            ///  '/issue/dividend' + assetType.enumString.toLowerCase(),
            ///  arguments: {'symbol': symbol},
            ///);
          },
        ],
      ).build();
    }
  }
}
