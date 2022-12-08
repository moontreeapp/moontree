import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/src/utilities/validation_ext.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/theme/extensions.dart';
import 'package:ravencoin_front/components/components.dart';

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
    assetDetails = pros.assets.primaryIndex
        .getOne(widget.symbol, pros.settings.chain, pros.settings.net);
    return body();
  }

  Widget body() => ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 112),
        children: <Widget>[
              for (String text in <String>[
                'Name',
                'Global Quantity',
                'Decimals'
              ])
                ListTile(
                  dense: true,
                  title:
                      Text(text, style: Theme.of(context).textTheme.bodyText1),
                  trailing: Text(element(text),
                      style: Theme.of(context).textTheme.bodyText1),
                ),
            ] +
            <Widget>[
              if (widget.symbol.startsWith(r'$'))
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 15, bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Verifier',
                          style: Theme.of(context).textTheme.bodyText1),
                      SizedBox(
                        width:
                            (MediaQuery.of(context).size.width - 16 - 16 - 8) /
                                1.5,
                        child: Text(
                            '${element('Verifier')}'
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
                            style: Theme.of(context).textTheme.bodyText1),
                      )
                    ],
                  ),
                )
            ] +
            <Widget>[
              if (assetDetails!.metadata == '' || assetDetails!.metadata.isIpfs)
                link('IPFS', 'https://gateway.ipfs.io/ipfs/')
              else
                ListTile(
                  dense: true,
                  title: Text('TXID',
                      style: Theme.of(context).textTheme.bodyText1),
                  trailing: Text(element('TXID'),
                      style: Theme.of(context).textTheme.bodyText1),
                )
            ] +
            <Widget>[
              for (String text in <String>['Reissuable'])
                ListTile(
                  dense: true,
                  title:
                      Text(text, style: Theme.of(context).textTheme.bodyText1),
                  trailing: Text(element(text),
                      style: Theme.of(context).textTheme.bodyText1),
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
      case 'Global Quantity':
        return assetDetails!.amount.toSatsCommaString();
      case 'Decimals':
        return assetDetails!.divisibility.toString();
      case 'Verifier':
        return 'not captured...';
      case 'IPFS':
      case 'TXID':
        return assetDetails!.metadata.cutOutMiddle();
      case 'Reissuable':
        return assetDetails!.reissuable ? 'Yes' : 'No';
      default:
        return 'unknown';
    }
  }

  String elementFull(String humanName) {
    switch (humanName) {
      case 'IPFS':
        return assetDetails!.metadata;
      default:
        return 'unknown';
    }
  }

  Widget link(String text, String link) => ListTile(
        dense: true,
        onTap: () => components.message.giveChoices(
          context,
          content: 'Open block explorer in browser?',
          behaviors: <String, void Function()>{
            'Cancel': Navigator.of(context).pop,
            'Continue': () {
              Navigator.of(context).pop();
              launchUrl(Uri.parse(link + elementFull(text)));
            },
          },
        ),
        title: Text(text, style: Theme.of(context).textTheme.bodyText1),
        trailing: Text(element(text), style: Theme.of(context).textTheme.link),
      );
}

// showDialog(
//            context: context,
//            builder: (BuildContext context) => AlertDialog(
//                    title: Text('Open in External App'),
//                    content: Text('Open discord app or browser?'),
//                    actions: <Widget>[
//                      TextButton(
//                          child: Text('Cancel'),
//                          onPressed: () => Navigator.of(context).pop()),
//                      TextButton(
//                          child: Text('Continue'),
//                          onPressed: () {
//                            Navigator.of(context).pop();
//                            launch(
//                                'https://discord.gg/${link ?? name.toLowerCase()}');
//                          })
//                    ])),