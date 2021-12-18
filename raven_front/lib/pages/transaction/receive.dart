//import 'dart:uri';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/utils/params.dart';
import 'package:raven_front/utils/utils.dart';
import 'package:share/share.dart';

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
  FocusNode requestAmountFocus = FocusNode();
  FocusNode requestLabelFocus = FocusNode();
  FocusNode requestMessageFocus = FocusNode();
  bool rawAddress = true;
  String uri = '';
  String username = '';
  List<Security> fetchedNames = <Security>[];

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
    var to = username == '' ? '' : 'to=${Uri.encodeComponent(username)}';
    var tail = [amount, label, message, to].join('&').replaceAll('&&', '&');
    tail =
        '?' + (tail.endsWith('&') ? tail.substring(0, tail.length - 1) : tail);
    tail = tail.length == 1 ? '' : tail;
    uri = rawAddress ? address : 'raven:$address$tail';
    setState(() => {});
  }

  @override
  void initState() {
    super.initState();
    requestMessage.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    requestAmount.dispose();
    requestLabel.dispose();
    requestMessage.dispose();
    super.dispose();
  }

  void _printLatestValue() async {
    fetchedNames = (await services.client.api
            .getAssetNames(requestMessage.text))
        .toList()
        .map((e) => Security(symbol: e, securityType: SecurityType.RavenAsset))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    username = settings.primaryIndex.getOne(SettingName.User_Name)?.value ?? '';
    data = populateData(context, data);
    requestMessage.text = requestMessage.text == ''
        ? data['symbol'] == ''
            ? 'RVN'
            : data['symbol']
        : requestMessage.text;
    address = Current.account.wallets[0].addresses[0].address;
    uri = uri == '' ? address : uri;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          _makeURI();
        },
        child: Scaffold(
          appBar: components.headers.back(context, 'Address'),
          body: body(),
          //floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          //floatingActionButton: shareAddressButton(),
          //bottomNavigationBar: components.buttons.bottomNav(context), // alpha hide
        ));
  }

  ListView body() =>
      ListView(shrinkWrap: true, padding: EdgeInsets.all(10.0), children: <
          Widget>[
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
                  visible: !rawAddress && username != '',
                  child: Text(
                    'to: $username',
                    style: Theme.of(context).textTheme.caption,
                  )),
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
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(children: <Widget>[
                Checkbox(
                  value: rawAddress,
                  onChanged: (_) {
                    _toggleRaw(_);
                    _makeURI();
                    FocusScope.of(context).requestFocus(requestMessageFocus);
                  },
                ),
                Text('address only'),
              ]),
              shareAddressButton(),
            ]),
        Visibility(
            visible: !rawAddress,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 15),
                  Text(
                    'Requested Asset:',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                  //getAssetNames
                  Autocomplete<Security>(
                    displayStringForOption: _displayStringForOption,
                    initialValue: TextEditingValue(text: requestMessage.text),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      requestMessage.text = textEditingValue.text;
                      _makeURI();
                      if (requestMessage.text == '') {
                        return const Iterable<Security>.empty();
                      }
                      if (requestMessage.text == 't') {
                        return [
                          Security(
                              symbol: 'testing',
                              securityType: SecurityType.Fiat)
                        ];
                      }
                      if (requestMessage.text.length >= 3) {
                        return fetchedNames;
                      }
                      //(await services.client.api.getAllAssetNames(textEditingValue.text)).map((String s) => Security(
                      //        symbol: s,
                      //        securityType: SecurityType.RavenAsset));
                      return securities.data
                          .where((Security option) => option.symbol
                              .contains(requestMessage.text.toUpperCase()))
                          .toList()
                          .reversed;
                    },
                    optionsMaxHeight: 100,
                    onSelected: (Security selection) async {
                      requestMessage.text = selection.symbol;
                      _makeURI();
                      FocusScope.of(context).requestFocus(requestAmountFocus);
                    },
                  ),
                  SizedBox(height: 15.0),
                ])),
        Visibility(
            visible: !rawAddress,
            child: TextField(
                focusNode: requestAmountFocus,
                autocorrect: false,
                controller: requestAmount,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Amount (Optional)',
                    hintText: 'Quantity'),
                onChanged: (value) {
                  requestAmount.text = cleanDecAmount(requestAmount.text);
                  _makeURI();
                },
                onEditingComplete: () {
                  requestAmount.text = cleanDecAmount(requestAmount.text);
                  _makeURI();
                  // send focus to next element
                  FocusScope.of(context).requestFocus(requestLabelFocus);
                })),
        Visibility(
            visible: !rawAddress,
            child: TextField(
              focusNode: requestLabelFocus,
              autocorrect: false,
              controller: requestLabel,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Label (Optional)',
                  hintText: 'Groceries'),
              onChanged: (value) {
                requestLabel.text = cleanLabel(requestLabel.text);
                _makeURI();
              },
              onEditingComplete: () {
                requestLabel.text = cleanLabel(requestLabel.text);
                _makeURI();
                FocusScope.of(context).unfocus();
              },
            )),
      ]);

  static String _displayStringForOption(Security option) => option.symbol;

  ElevatedButton shareAddressButton() => ElevatedButton.icon(
        icon: Icon(Icons.share),
        label: Text('Share'),
        onPressed: () => Share.share(uri),
        //style: components.buttonStyles.curvedSides
      );
}
