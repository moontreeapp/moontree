import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/indicators/indicators.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/utils/params.dart';
import 'package:raven_front/utils/data.dart';

class CreateAsset extends StatefulWidget {
  final Map<String, dynamic>? data;
  const CreateAsset({this.data}) : super();

  @override
  _CreateAssetState createState() => _CreateAssetState();
}

class _CreateAssetState extends State<CreateAsset> {
  Map<String, dynamic> data = {};
  final assetName = TextEditingController();
  final assetAmount = TextEditingController();
  final assetMetadata = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    assetName.dispose();
    assetAmount.dispose();
    assetMetadata.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // could hold which asset to send...
    data = populateData(context, data);

    data['reissuable'] =
        data.containsKey('reissuable') ? data['reissuable'] : 'Reissuable';
    data['divisibility'] =
        data.containsKey('divisibility') ? data['divisibility'] : '0';
    data['wallet'] = data.containsKey('wallet')
        ? data['wallet']
        : res.wallets.data.first.walletId;
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          //appBar: header(),
          body: body(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: sendTransactionButton(),
          //bottomNavigationBar: components.buttons.bottomNav(context), // alpha hide
        ));
  }

  AppBar header() => AppBar(
        elevation: 2,
        centerTitle: false,
        leading: components.buttons.back(context),
        title: Text('Create Asset'),
        actions: [
          components.status,
          indicators.process,
          indicators.client,
        ],
      );

  ListView body() {
    //var _controller = TextEditingController();
    return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        children: <Widget>[
          // send tx using only this wallet
          Text(
              (data.containsKey('walletId') && data['walletId'] != null)
                  ? 'Use Wallet: ' + data['walletId']
                  : '',
              style: Theme.of(context).textTheme.caption),
          TextField(
            controller: assetName,
            textCapitalization: TextCapitalization.characters,
            maxLength: 31,
            autocorrect: false,
            decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Asset Name',
                hintText: 'LEMONADE.COM'),
            onEditingComplete: () {
              var text = assetName.text;
              var punctuation = ' +-*/|][}{=)(&^%#@!~`<>,?\$\\';
              for (var ix
                  in List<int>.generate(punctuation.length, (i) => i + 1)) {
                text = text.replaceAll(punctuation.substring(ix - 1, ix), '');
              }
              var allowed = ['.', '_'];
              if (text != '') {
                while (allowed.contains(text.substring(0, 1))) {
                  text = text.substring(1, text.length);
                }
                while (allowed
                    .contains(text.substring(text.length - 1, text.length))) {
                  text = text.substring(0, text.length - 1);
                }
              }
              assetName.text = text.toUpperCase();
            },
          ),
          SizedBox(height: 5),
          TextField(
            controller: assetAmount,
            keyboardType: TextInputType.number,
            autocorrect: false,
            maxLength: 11,
            decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Amount',
                hintText: 'Quantity'),
            onEditingComplete: () {
              assetAmount.text = cleanSatAmount(assetAmount.text);
            },
          ),
          SizedBox(height: 20),
          Text('Reissuable:', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
              isExpanded: true,
              value: data['reissuable'],
              items: <String>['Reissuable', 'Not Reissuable']
                  .map((String value) => DropdownMenuItem<String>(
                      value: value, child: Text(value)))
                  .toList(),
              onChanged: (String? newValue) =>
                  setState(() => data['reissuable'] = newValue!)),
          SizedBox(height: 20),
          Text('Percision:', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
              isExpanded: true,
              value: data['divisibility'],
              items: <int>[0, 1, 2, 3, 4, 5, 6, 7, 8]
                  .map((int value) => DropdownMenuItem<String>(
                      value: value.toString(),
                      child: Text(value > 0
                          ? '$value (.' + '0' * (value - 1) + '1)'
                          : '0 (1)')))
                  .toList(),
              onChanged: (String? newValue) =>
                  setState(() => data['divisibility'] = newValue!)),

          /// how does this work with HD wallets?
          /// - don't we have to get an address below the top?
          /// should we show those options?
          /// only show options with balance large enough?
          /// if you wanted to get only the wallets that had a large enough balance:
          ///  for each wallet
          ///   if SingleWallet sum histories values of that wallet's id
          ///    if large enough add address to list
          ///   if leaderwallet
          ///    get all addresses of wallet
          ///     for each address sum histories  values of that address
          ///      if large enough add address to list
          /// this logic should go on the balance service
          ///
          ///
          /// NOT MVP:
          /// will the user even care?
          /// might have to allow them to choose wallet for normal transactions...
          /// or avoid taking money from an asset holding wallet as long as we can...
          /// or both: avoid and give them a choice that's hidden (defaulted).
          ///
          /// MVP: treat all wallets the same, assume if they have an asset wallet
          /// they'll move it into another account if they care.
          //DropdownButton<String>(
          //    isExpanded: true,
          //    value: data['wallet'],
          //    items: wallets.byAccount
          //        .getAll(Current.account.accountId)
          //        .map((Wallet wallet) => DropdownMenuItem<String>(
          //            value: wallet.walletId,
          //            child: Text(
          //                '${wallet.walletId.substring(0, 6)}...${wallet.walletId.substring(wallet.walletId.length - 6, wallet.walletId.length)}',
          //                style: Theme.of(context).mono)))
          //        .toList(),
          //    onChanged: (String? newValue) => setState(() => {
          //          // enable create asset button if enough RVN in wallet
          //          // disable create asset button if not enough RVN in wallet
          //          data['wallet'] = newValue!
          //        })),

          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('fee'), Text('500+tx fee RVN')]),

          /// Metadata could be just an ipfs hash,
          /// or it could be a json structure of any kind,
          /// including our own.
          /// Perhaps here we let them choose what format they'd like,
          /// then we could have things like upload icon for this asset
          /// and display it correctly in the marketplace.
          //Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          //  components.icons.assetAvatar("data['symbol']"),
          //  Text('upload icon?',
          //      style: Theme.of(context).textTheme.headline5),
          //]),
          SizedBox(height: 20),
          TextField(
            controller: assetMetadata,
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Metadata (optional)',
                hintText: 'IPFS hash publicly posted on transaction'),
          ),
          //Center(child: sendTransactionButton(_formKey))
        ]);
  }

  /// disable until validation checks out.
  ElevatedButton sendTransactionButton() => ElevatedButton.icon(
      icon: Icon(Icons.send),
      label: Text('Create Asset'),
      onPressed: () {
        /// use:
        ///  data['reissuable']
        ///  data['divisibility']
        ///  data['wallet']
        ///  assetName.text
        ///  assetAmount.text
        ///  assetMetadata.text
        ///
        /// ask them to review on additional screen / scroll down
        /// confirm
        ///
        ///FocusScope.of(context).unfocus();
        if (data.containsKey('walletId') && data['walletId'] != null) {
          // send tx using only this wallet
        } else {
          // send tx using any/every wallet in the account
        }
      },
      style: components.styles.buttons.curvedSides);
}
