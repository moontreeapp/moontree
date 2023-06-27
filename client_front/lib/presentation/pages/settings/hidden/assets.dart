import 'package:client_back/streams/app.dart';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

class HiddenAssets extends StatefulWidget {
  const HiddenAssets({Key? key}) : super(key: key);

  @override
  HiddenAssetsState createState() => HiddenAssetsState();
}

class HiddenAssetsState extends State<HiddenAssets> {
  final Security currentCrypto = pros.securities.currentCoin;

  @override
  Widget build(BuildContext context) {
    return ScrollablePageStructure(
      heightSpacer: const SizedBox(height: 0),
      widthSpacer: const SizedBox(width: 0),
      headerSpace: 0,
      leftPadding: 0,
      rightPadding: 0,
      topPadding: 0,
      children: <Widget>[
        for (final Security security in pros.settings.hiddenAssets) ...[
          ListTile(
            //dense: true,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            onTap: () async {
              await pros.settings.removeAllHiddenAssets([security]);
              setState(() {});
              streams.app.behavior.snack.add(Snack(
                positive: true,
                message: 'Asset unhidden',
                delay: 0,
              ));
            },
            leading: leadingIcon(security),
            title: title(security, currentCrypto),
            trailing: Icon(Icons.visibility_off_outlined),
          ),
          const Divider(height: 1)
        ]
      ],
    );
  }

  Widget leadingIcon(Security holding) => SizedBox(
        height: 40,
        width: 40,
        child: //Hero(
            //tag: holding.symbol.toLowerCase(),
            //child:
            components.icons.assetAvatar(
          holding.symbol,
          net: pros.settings.net,
        ),
      )
      //)
      ;
  Widget title(Security holding, Security currentCrypto) => SizedBox(
      width: MediaQuery.of(context).size.width - (16 + 40 + 16 + 16),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child:
            Text(holding.symbol, style: Theme.of(context).textTheme.bodyLarge),
      ));
}
