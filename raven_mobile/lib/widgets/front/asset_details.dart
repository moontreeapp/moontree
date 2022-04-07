import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

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
        children: <Widget>[
              for (var text in ['Name', 'Quantity', 'Decimals'])
                ListTile(
                  dense: true,
                  title:
                      Text(text, style: Theme.of(context).textTheme.bodyText1),
                  trailing: Text(element(text),
                      style: Theme.of(context).textTheme.bodyText1),
                ),
            ] +
            [
              if (widget.symbol.startsWith('\$'))
                Padding(
                  padding:
                      EdgeInsets.only(left: 16, right: 16, top: 15, bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Verifier',
                          style: Theme.of(context).textTheme.bodyText1),
                      Container(
                        width:
                            (MediaQuery.of(context).size.width - 16 - 16 - 8) /
                                1.5,
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
                            style: Theme.of(context).textTheme.bodyText1),
                      )
                    ],
                  ),
                )
            ] +
            [link('IPFS', 'https://gateway.ipfs.io/ipfs/')] +
            [
              for (var text in ['Reissuable'])
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
      case 'Quantity':
        return utils
            .satToAmount(assetDetails!.satsInCirculation)
            .toCommaString();
      case 'Decimals':
        return assetDetails!.divisibility.toString();
      case 'Verifier':
        return 'not captured...';
      case 'IPFS':
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
        onTap: () => launch(link + elementFull(text)),
        title: Text(text, style: Theme.of(context).textTheme.bodyText1),
        trailing: Text(element(text), style: Theme.of(context).textTheme.link),
      );
}
