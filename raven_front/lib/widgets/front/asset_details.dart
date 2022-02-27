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
  @override
  Widget build(BuildContext context) {
    return body();
  }

  Widget body() => ListView(
        padding: EdgeInsets.only(top: 8, bottom: 112),
        children: [
          ListTile(
            dense: true,
            title: Text('Name', style: Theme.of(context).assetDetail),
            trailing: Text(widget.symbol, style: Theme.of(context).assetDetail),
          ),
          ListTile(
            dense: true,
            title: Text('Quantity', style: Theme.of(context).assetDetail),
            trailing:
                Text('total quantity', style: Theme.of(context).assetDetail),
          ),
          ListTile(
            dense: true,
            title: Text('Decimals', style: Theme.of(context).assetDetail),
            trailing:
                Text('divisibility', style: Theme.of(context).assetDetail),
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
            trailing: Text('link? QmXwHQ...EJkH22',
                style: Theme.of(context).assetDetail),
          ),
          ListTile(
            dense: true,
            title: Text('Reissuable', style: Theme.of(context).assetDetail),
            trailing: Text('No', style: Theme.of(context).assetDetail),
          ),
        ],
      );
}
