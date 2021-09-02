import 'package:flutter/material.dart';

import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:raven_mobile/components/styles/buttons.dart';
import 'package:raven_mobile/components/text.dart';
import 'package:raven_mobile/services/lookup.dart';

class Send extends StatefulWidget {
  final dynamic data;
  const Send({this.data}) : super();

  @override
  _SendState createState() => _SendState();
}

class _SendState extends State<Send> {
  dynamic data = {};
  late GlobalKey<FormState> formKey;
  final sendAddress = TextEditingController();
  final sendAmount = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    sendAddress.dispose();
    sendAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // could hold which asset to send...
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;
    formKey = GlobalKey<FormState>();
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
                child: RavenButton.settings(context))
          ],
          title: Text('Send'),
          flexibleSpace: Container(
            alignment: Alignment.center,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              SizedBox(height: 100.0),
              Text(sendAmount.text == '' ? '0' : sendAmount.text,
                  style: Theme.of(context).textTheme.headline3),
              SizedBox(height: 15.0),
              Text(
                  RavenText.securityAsReadable(
                      RavenText.amountSats(
                        double.parse(sendAmount.text),
                        percision: 8, /* get asset percision...*/
                      ),
                      symbol: data['symbol']),
                  style: Theme.of(context).textTheme.headline5),
              SizedBox(height: 15.0),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                RavenIcon.assetAvatar(data['symbol']),
                SizedBox(width: 15.0),
                Text(data['symbol'],
                    style: Theme.of(context).textTheme.headline5),

                /// drop down works well
                //IconButton(
                //    onPressed: () {
                //      /*show available assets and balances for this account*/
                //      //security name switchout button should bring up a new page of all the assets available in this account.
                //      /// start with a drop down
                //    },
                //    //padding: EdgeInsets.only(top: 24.0),
                //    icon: Icon(
                //      Icons.change_circle_outlined,
                //      color: Colors.white,
                //    )),
              ]),
            ]),
          )));

  ListView body() {
    //var _controller = TextEditingController();
    return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(20.0),
        children: <Widget>[
          Form(
              key: formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DropdownButton<String>(
                        isExpanded: true,
                        value: data['symbol'],
                        items: <String>[
                          for (var balance in Current.holdings)
                            balance.security.symbol
                        ]
                            .map((String value) => DropdownMenuItem<String>(
                                value: value, child: Text(value)))
                            .toList(),
                        onChanged: (String? newValue) =>
                            setState(() => data['symbol'] = newValue!)),
                    TextFormField(
                      controller: sendAddress,
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'To',
                          hintText: 'Address'),
                      //validator: (String? value) {
                      //  //if (value == null || value.isEmpty) {
                      //  //  return 'Please enter a valid address';
                      //  //}
                      //  //return null;
                      //},
                    ),
                    TextButton.icon(
                        onPressed: () {
                          /* qr code scanner get value put in textbox
                          # need a qr code scanner:
                          # https://pub.dev/packages/qr_code_scanner
                          # https://pub.dev/packages/qrscan
                        */
                        },
                        icon: Icon(Icons.qr_code_scanner),
                        label: Text('Scan QR code')),
                    TextFormField(
                      controller: sendAmount,
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Amount',
                          hintText: 'Quantity'),
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
                      keyboardType: TextInputType.multiline,
                      maxLines: 1,
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Memo (optional)',
                          hintText: 'IPFS hash publicly posted on transaction'),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Note (optional)',
                          hintText: 'Private note to self'),
                    ),
                    //Center(child: sendTransactionButton(_formKey))
                  ]))
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
        }
      },
      style: RavenButtonStyle.curvedSides);
}
