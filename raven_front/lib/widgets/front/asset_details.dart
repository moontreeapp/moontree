import 'dart:async';
import 'package:intersperse/intersperse.dart';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';

class AssetDetails extends StatefulWidget {
  final String symbol;

  const AssetDetails({Key? key, required this.symbol}) : super(key: key);

  @override
  State<AssetDetails> createState() => _AssetDetails();
}

class _AssetDetails extends State<AssetDetails> {
  late Asset? assetDetails;

  @override
  Widget build(BuildContext context) {
    assetDetails = res.assets.primaryIndex.getOne(widget.symbol);
    return body();
  }

  Widget body() => ListView(
        padding: EdgeInsets.only(top: 8, bottom: 112),
        children: [
          ListTile(
            dense: true,
            title: Text('Name', style: Theme.of(context).assetDetail),
            trailing:
                Text(element('Name'), style: Theme.of(context).assetDetail),
          ),
          ListTile(
            dense: true,
            title: Text('Quantity', style: Theme.of(context).assetDetail),
            trailing:
                Text(element('Quantity'), style: Theme.of(context).assetDetail),
          ),
          ListTile(
            dense: true,
            title: Text('Decimals', style: Theme.of(context).assetDetail),
            trailing:
                Text(element('Decimals'), style: Theme.of(context).assetDetail),
          ),
          if (widget.symbol.startsWith('\$'))
            Padding(
              padding:
                  EdgeInsets.only(left: 16, right: 16, top: 15, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verifier', style: Theme.of(context).assetDetail),
                  Container(
                    width:
                        (MediaQuery.of(context).size.width - 16 - 16 - 8) / 1.5,
                    child: Text(
                        element('Verifier') +
                            '(#KYC & #AML) OR #VERIFIED'
                                '(#KYC & #AML) OR #VERIFIED'
                                '(#KYC & #AML) OR #VERIFIED'
                                '(#KYC & #AML) OR #VERIFIED'
                                '(#KYC & #AML) OR #VERIFIED'
                                '(#KYC & #AML) OR #VERIFIED'
                                '(#KYC & #AML) OR #VERIFIED'
                                '(#KYC & #AML) OR #VERIFIED'
                                '(#KYC & #AML) OR #VERIFIED'
                                '(#KYC & #AML) OR #VERIFIED'
                                '(#KYC & #AML) OR #VERIFIED'
                                '(#KYC & #AML) OR #VERIFIED'
                                '(#KYC & #AML) OR #VERIFIED',
                        overflow: TextOverflow.fade,
                        softWrap: true,
                        maxLines: 100,
                        style: Theme.of(context).assetDetail),
                  )
                ],
              ),
            ),
          ListTile(
            dense: true,
            title: Text('IPFS/Txid', style: Theme.of(context).assetDetail),
            trailing: Text(element('IPFS/Txid'),
                style: Theme.of(context).assetDetail),
          ),
          ListTile(
            dense: true,
            title: Text('Reissuable', style: Theme.of(context).assetDetail),
            trailing: Text(element('Reissuable'),
                style: Theme.of(context).assetDetail),
          ),
        ],
      );

  String element(String humanName) {
    if (assetDetails == null) {
      return 'unknown';
    }
    switch (humanName) {
      case 'Name':
        return widget.symbol;
      case 'Quantity':
        return utils
            .satToAmount(assetDetails!.satsInCirculation,
                divisibility: assetDetails!.divisibility)
            .toCommaString();
      case 'Decimals':
        return assetDetails!.divisibility.toString();
      case 'Verifier':
        return 'not captured...';
      case 'IPFS/Txid':
        return assetDetails!.metadata.cutOutMiddle();
      case 'Reissuable':
        return assetDetails!.reissuable ? 'Yes' : 'No';
      default:
        return 'unknown';
    }
  }
}
