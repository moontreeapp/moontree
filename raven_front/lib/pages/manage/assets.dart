import 'package:flutter/material.dart';
import 'package:raven_front/utils/data.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';

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
    var assetType = symbol;
    return BackdropLayers(
      back: CoinSpec(
          pageTitle: 'Asset',
          security: res.securities.bySymbolSecurityType
              .getOne(symbol, SecurityType.RavenAsset)!),
      front: FrontCurve(
          height: MediaQuery.of(context).size.height - (201 + 56),
          child: Column(children: [
            Expanded(child: AssetDetails(symbol: symbol)),
            NavBar(
              includeSectors: false,
              actionButtons: <Widget>[
                if ([AssetType.Main, AssetType.Sub].contains(assetType)) ...[
                  components.buttons.actionButton(context,
                      label: 'create', onPressed: _produceSubCreateModal),
                  SizedBox(width: 16)
                ],
                if ([
                  AssetType.Qualifier,
                  AssetType.QualifierSub,
                ].contains(assetType)) ...[
                  components.buttons.actionButton(context,
                      label: 'create',
                      onPressed: () => Navigator.pushNamed(
                            components.navigator.routeContext!,
                            '/create/qualifiersub',
                            arguments: {'symbol': 'QualifierSub'},
                          )),
                  SizedBox(width: 16)
                ],
                components.buttons.actionButton(context, label: 'manage',
                    onPressed: () {
                  // if main do this
                  _produceMainManageModal();
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

  void _produceMainManageModal() async {
    await SelectionItems(context, modalSet: SelectionSet.MainManage).build();
  }
}
