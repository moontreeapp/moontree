import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:raven_mobile/components/styles/buttons.dart';
import 'package:raven_mobile/components/text.dart';
import 'package:raven_mobile/services/lookup.dart';
import 'package:raven_mobile/utils/address.dart';
import 'package:raven_mobile/utils/params.dart';
import 'package:raven_mobile/utils/utils.dart';
import 'package:raven_mobile/theme/extensions.dart';

class Send extends StatefulWidget {
  final dynamic data;
  const Send({this.data}) : super();

  @override
  _SendState createState() => _SendState();
}

class _SendState extends State<Send> {
  Map<String, dynamic> data = {};
  final formKey = GlobalKey<FormState>();
  final sendAddress = TextEditingController();
  final sendAmount = TextEditingController(text: '10');
  final sendMemo = TextEditingController();
  final sendNote = TextEditingController();
  String visibleAmount = '';
  String visibleFiatAmount = '';
  String validatedAddress = 'unknown';
  Color addressColor = Colors.grey.shade400;
  Color amountColor = Colors.grey.shade400;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    sendAddress.dispose();
    sendAmount.dispose();
    sendMemo.dispose();
    sendNote.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // could hold which asset to send...
    data = populateData(context, data);
    try {
      visibleFiatAmount = RavenText.securityAsReadable(
          RavenText.amountSats(
            double.parse(visibleAmount),
            percision: 8, /* get asset percision...*/
          ),
          symbol: data['symbol']);
    } catch (e) {
      visibleFiatAmount = '';
    }
    return Scaffold(
        appBar: header(),
        body: body(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: sendTransactionButton(),
        bottomNavigationBar: RavenButton.bottomNav(context));
  }

  PreferredSize header() => PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.34),
      child: AppBar(
          elevation: 2,
          centerTitle: false,
          leading: RavenButton.back(context),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: RavenButton.settings(context, () {
                  setState(() {});
                }))
          ],
          title: Text('Send'),
          flexibleSpace: Container(
            alignment: Alignment.center,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              SizedBox(height: 100.0),
              Text(visibleAmount, style: Theme.of(context).textTheme.headline3),
              SizedBox(height: 15.0),
              Text(visibleFiatAmount,
                  style: Theme.of(context).textTheme.headline5),
              SizedBox(height: 15.0),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                RavenIcon.assetAvatar(data['symbol']),
                SizedBox(width: 15.0),
                Text(data['symbol'],
                    style: Theme.of(context).textTheme.headline5),
              ]),
            ]),
          )));

  void populateFromQR(String code) {
    if (code.startsWith('raven:')) {
      sendAddress.text = code.substring(6).split('?')[0];
      var params = parseReceiveParams(code);
      if (params.containsKey('amount')) {
        sendAmount.text = verifyDecAmount(params['amount']!);
      }
      if (params.containsKey('label')) {
        sendNote.text = verifyLabel(params['label']!);
      }
      data['symbol'] = requestedAsset(params,
          holdings: Current.holdingNames, current: data['symbol']);
    } else {
      sendAddress.text = code;
    }
  }

  bool _validateAddress(String address) {
    var old = validatedAddress;
    validatedAddress = validateAddress(address);
    if (validatedAddress != '') {
      if (validatedAddress == 'RVN') {
        addressColor = Theme.of(context).good!;
      } else if (validatedAddress == 'UNS') {
        addressColor = Theme.of(context).primaryColor;
      } else if (validatedAddress == 'ASSET') {
        addressColor = Theme.of(context).primaryColor;
      }
      if (old != validatedAddress) setState(() => {});
      return true;
    }
    addressColor = Theme.of(context).bad!;
    if (old != '') setState(() => {});
    return false;
  }

  void verifyVisibleAmount(String value) {
    visibleAmount = verifyDecAmount(value);
    if (visibleAmount == '0' || visibleAmount != value) {
      amountColor = Theme.of(context).bad!;
    } else {
      // if amount is larger than total...
      //amountColor = Theme.of(context).bad!;
      // else
      amountColor = Theme.of(context).good!;
    }
    setState(() => {});
  }

  ListView body() {
    //var _controller = TextEditingController();
    return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
        children: <Widget>[
          Form(
              key: formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        (data.containsKey('walletId') &&
                                data['walletId'] != null)
                            ? 'Use Wallet: ' + data['walletId']
                            : '',
                        style: Theme.of(context).textTheme.caption),
                    DropdownButton<String>(
                        isExpanded: true,
                        value: data['symbol'],
                        items: Current.holdingNames
                            .map((String value) => DropdownMenuItem<String>(
                                value: value, child: Text(value)))
                            .toList(),
                        onChanged: (String? newValue) =>
                            setState(() => data['symbol'] = newValue!)),
                    TextFormField(
                      controller: sendAddress,
                      decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: addressColor)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: addressColor)),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: addressColor)),
                          labelText: 'To',
                          hintText: 'Address'),
                      onChanged: (value) {
                        _validateAddress(value);
                      },
                      onEditingComplete: () {
                        /// should tell front end what it was so we can notify user we're substituting the asset name or uns domain for the actual address
                        var verifiedAddress =
                            verifyValidAddress(sendAddress.text);

                        /// tell user then:
                        sendAddress.text = verifiedAddress;
                      },
                      //validator: (String? value) {
                      //  //if (value == null || value.isEmpty) {
                      //  //  return 'Please enter a valid address';
                      //  //}
                      //  //return null;
                      //},
                    ),
                    TextButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/send/scan_qr').then(
                                (value) =>
                                    populateFromQR((value as Barcode).code)),
                        icon: Icon(Icons.qr_code_scanner),
                        label: Text('Scan QR code')),
                    TextFormField(
                      controller: sendAmount,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: amountColor)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: amountColor)),
                          //border: UnderlineInputBorder(
                          //    borderSide: BorderSide(color: amountColor)),
                          labelText: 'Amount',
                          hintText: 'Quantity'),
                      onChanged: (value) {
                        verifyVisibleAmount(value);
                      },
                      onEditingComplete: () {
                        sendAmount.text = verifyDecAmount(sendAmount.text);
                        verifyVisibleAmount(sendAmount.text);
                      },
                      //validator: (String? value) {  // validate as double/int
                      //  //if (value == null || value.isEmpty) {
                      //  //  return 'Please enter a valid send amount';
                      //  //}
                      //  //return null;
                      //},
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('fee'), Text('0.01397191 RVN')]),
                    TextFormField(
                      controller: sendMemo,
                      keyboardType: TextInputType.multiline,
                      maxLines: 1,
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Memo (optional)',
                          hintText: 'IPFS hash publicly posted on transaction'),
                    ),
                    TextFormField(
                      controller: sendNote,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Note (optional)',
                          hintText: 'Private note to self'),
                    ),
                    //Center(child: sendTransactionButton(_formKey))
                  ])),
        ]);
  }

  /// after transaction sent (and subscription on scripthash saved...)
  /// save the note with, no need to await:
  /// services.historyService.saveNote(hash, note {or history object})
  /// should notes be in a separate reservoir? makes this simpler, but its nice
  /// to have it all in one place as in transaction.note....
  ElevatedButton sendTransactionButton() => ElevatedButton.icon(
      icon: Icon(Icons.send),
      label: Text('Send'),
      onPressed: () {
        // Validate will return true if the form is valid, or false if
        // the form is invalid.
        if (formKey.currentState!.validate()) {
          // Process data.
          if (data.containsKey('walletId') && data['walletId'] != null) {
            // send using only this wallet
          } else {
            // send using any/every wallet in the account
          }
        }
      },
      style: RavenButtonStyle.curvedSides);
}
