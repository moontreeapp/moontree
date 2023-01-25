import 'package:flutter/material.dart';
import 'package:client_front/domain/utils/data.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/records/asset.dart' as asset_record;
import 'package:client_front/presentation/components/components.dart';

class AssetPage extends StatefulWidget {
  const AssetPage() : super();

  @override
  _AssetPageState createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage> {
  Map<String, dynamic> data = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    final String symbol = data['symbol'] as String;
    final Asset chosenAsset = pros.assets.primaryIndex
        .getOne(symbol, pros.settings.chain, pros.settings.net)!;
    return BackdropLayers(
      back: CoinSpec(
          pageTitle: 'Asset',
          security: pros.securities.primaryIndex.getOne(
            symbol,
            pros.settings.chain,
            pros.settings.net,
          )!),
      front: FrontCurve(
          height: MediaQuery.of(context).size.height * .64,
          child: Column(children: <Widget>[
            Expanded(child: AssetDetails(symbol: symbol)),
            NavBar(
              placeholderManage: !services.developer.developerMode,
              includeSectors: false,
              actionButtons: <Widget>[
                if (<SymbolType>[SymbolType.main, SymbolType.sub]
                    .contains(chosenAsset.symbolType)) ...<Widget>[
                  components.buttons.actionButton(context,
                      label: 'create', onPressed: _produceSubCreateModal),
                ],
                if (<SymbolType>[
                  SymbolType.qualifier,
                  SymbolType.qualifierSub,
                ].contains(chosenAsset.symbolType)) ...<Widget>[
                  components.buttons.actionButton(context,
                      label: 'create',
                      onPressed: () => Navigator.pushNamed(
                            components.routes.routeContext!,
                            '/create/qualifiersub',
                            arguments: <String, String>{
                              'symbol': 'QualifierSub'
                            },
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

  Future<void> _produceMainManageModal(asset_record.Asset asset) async {
    if (asset.reissuable &&
        <SymbolType>[SymbolType.main, SymbolType.sub, SymbolType.restricted]
            .contains(asset.symbolType)) {
      await SelectionItems(
        context,
        //symbol: symbol,
        modalSet: SelectionSet.MainManage,
        behaviors: <void Function()>[
          () {
            Navigator.pushNamed(
              context,
              '/reissue/${asset.symbolType.name.toLowerCase()}',
              arguments: <String, String>{'symbol': asset.symbol},
            );
          },
          () {
            ///Navigator.pushNamed(
            ///  context,
            ///  '/issue/dividend' + symbolType.name.toLowerCase(),
            ///  arguments: {'symbol': symbol},
            ///);
          },
        ],
      ).build();
    }
  }
}
