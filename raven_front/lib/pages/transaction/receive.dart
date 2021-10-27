//import 'dart:uri';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/components/components.dart';
import 'package:raven_mobile/services/lookup.dart';
import 'package:raven_mobile/utils/params.dart';
import 'package:raven_mobile/utils/utils.dart';

class Receive extends StatefulWidget {
  final dynamic data;
  const Receive({this.data}) : super();

  @override
  _ReceiveState createState() => _ReceiveState();
}

class _ReceiveState extends State<Receive> {
  Map<String, dynamic> data = {};
  late String address;
  final requestAmount = TextEditingController();
  final requestLabel = TextEditingController();
  final requestMessage = TextEditingController();
  bool rawAddress = true;
  String uri = '';

  void _toggleRaw(_) {
    setState(() {
      rawAddress = !rawAddress;
    });
  }

  void _makeURI() {
    var amount = requestAmount.text == ''
        ? ''
        : 'amount=${Uri.encodeComponent(requestAmount.text)}';
    var label = requestLabel.text == ''
        ? ''
        : 'label=${Uri.encodeComponent(requestLabel.text)}';
    var message = requestMessage.text == ''
        ? ''
        //: 'message=${Uri.encodeComponent(requestMessage.text)}';
        : 'message=asset:${Uri.encodeComponent(requestMessage.text)}';
    var tail = [amount, label, message].join('&').replaceAll('&&', '&');
    tail =
        '?' + (tail.endsWith('&') ? tail.substring(0, tail.length - 1) : tail);
    tail = tail.length == 1 ? '' : tail;
    uri = rawAddress ? address : 'raven:$address$tail';
    setState(() => {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    requestAmount.dispose();
    requestLabel.dispose();
    requestMessage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    requestMessage.text =
        requestMessage.text == '' ? 'RVN' : requestMessage.text;
    address = Current.account.wallets[0].addresses[0].address;
    uri = uri == '' ? address : uri;
    return Scaffold(
      appBar: header(),
      body: body(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: shareAddressButton(),
      //bottomNavigationBar: components.buttons.bottomNav(context), // alpha hide
    );
  }

  AppBar header() => AppBar(
        leading: components.buttons.back(context),
        elevation: 2,
        centerTitle: false,
        title: Text(
          //(data['accounts'][data['account']] ?? 'Unknown') + ' Wallet',
          'Address',
        ),
      );

  ListView body() => ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(10.0),
          children: <Widget>[
            /// if this is a RVNt account we could show that here...
            //SizedBox(height: 15.0),
            //Text(
            //    // rvn is default but if balance is 0 then take the largest asset balance and also display name here.
            //    'RVN',
            //    textAlign: TextAlign.center,
            //    style: Theme.of(context).textTheme.bodyText1),
            SizedBox(height: 20.0),
            Center(
                child: QrImage(
                    backgroundColor: Colors.white,
                    data: rawAddress ? address : uri,
                    version: QrVersions.auto,
                    size: 300.0)),
            SizedBox(height: 10.0),
            Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  /// does not belong on UI but I still want an indication that what is on QR code is not raw address...
                  Visibility(
                      visible: !rawAddress,
                      child: Text(
                        'raven:',
                        style: Theme.of(context).textTheme.caption,
                      )),
                  SelectableText(
                    address,
                    cursorColor: Colors.grey[850],
                    showCursor: true,
                    toolbarOptions: ToolbarOptions(
                        copy: true, selectAll: true, cut: false, paste: false),
                  ),
                  Visibility(
                      visible: !rawAddress && requestAmount.text != '',
                      child: Text(
                        'amount: ${requestAmount.text}',
                        style: Theme.of(context).textTheme.caption,
                      )),
                  Visibility(
                      visible: !rawAddress && requestLabel.text != '',
                      child: Text(
                        'label: ${requestLabel.text}',
                        style: Theme.of(context).textTheme.caption,
                      )),
                  Visibility(
                      visible: !rawAddress && requestMessage.text != '',
                      child: Text(
                        'message: ${requestMessage.text}',
                        style: Theme.of(context).textTheme.caption,
                      )),
                ])),
            SizedBox(height: 20.0),
            Row(children: <Widget>[
              Checkbox(
                value: rawAddress,
                onChanged: (_) {
                  _toggleRaw(_);
                  _makeURI();
                },
              ),
              Text('address only'),
            ]),

            /// if no options are selected it is a raw address?... yes
            //?amount=5.12340000
            //&label=This%20is%20a%20label  // could transalte to note
            //&message=This%20is%20a%20message  // could transalte to asking for a specific asset
            //DropdownButton<String>(
            //    isExpanded: true,
            //    value: data['uri'],
            //    items: <String>[
            //      for (var uriOption in ['Raw Address', '']) uriOption
            //    ]
            //        .map((String value) => DropdownMenuItem<String>(
            //            value: value, child: Text(value)))
            //        .toList(),
            //    onChanged: (String? newValue) =>
            //        setState(() => data['uri'] = newValue!)),
            Visibility(
                visible: !rawAddress,
                child: TextField(
                    autocorrect: false,
                    controller: requestAmount,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Amount (Optional)',
                        hintText: 'Quantity'),
                    onEditingComplete: () {
                      requestAmount.text = verifyDecAmount(requestAmount.text);
                      _makeURI();
                    })),
            Visibility(
                visible: !rawAddress,
                child: TextField(
                  autocorrect: false,
                  controller: requestLabel,
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Label (Optional)',
                      hintText: 'Groceries'),
                  onEditingComplete: () {
                    _makeURI();
                  },
                )),
            //Visibility(
            //  visible: !rawAddress,
            //  child:
            //      TextField(
            //        autocorrect: false,
            //        controller: requestMessage,
            //        decoration: InputDecoration(
            //            border: UnderlineInputBorder(),
            //            labelText: 'Message (Optional)',
            //            hintText: 'Requesting asset'),
            //        onEditingComplete: () {
            //          _makeURI();
            //        })
            //),
            Visibility(
                visible: !rawAddress,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text('Requested Asset:'),
                      DropdownButton<String>(
                          isExpanded: true,
                          value: requestMessage.text,
                          items: Current.holdingNames
                              .map((String value) => DropdownMenuItem<String>(
                                  value: value, child: Text(value)))
                              .toList(),
                          onChanged: (String? newValue) {
                            requestMessage.text = newValue!;
                            _makeURI();
                          }),
                    ])),
          ]);

  ElevatedButton shareAddressButton() => ElevatedButton.icon(
      icon: Icon(Icons.share),
      label: Text('Share'),
      onPressed: () {},
      style: components.buttonStyles.curvedSides);
}
