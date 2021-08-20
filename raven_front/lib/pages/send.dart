import 'package:flutter/material.dart';

import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/styles.dart';

class Send extends StatefulWidget {
  final dynamic data;
  const Send({this.data}) : super();

  @override
  _SendState createState() => _SendState();
}

class _SendState extends State<Send> {
  dynamic data = {};
  late GlobalKey<FormState> formKey;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;
    formKey = GlobalKey<FormState>();
    return Scaffold(
        appBar: header(),
        body: body(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: sendTransactionButton(),
        bottomNavigationBar: RavenButton().bottomNav(context));
  }

  PreferredSize header() => PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.34),
      child: AppBar(
          elevation: 2,
          centerTitle: false,
          leading: RavenButton().back(context),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: RavenButton().settings(context))
          ],
          title: Text('Send'),
          flexibleSpace: Container(
            alignment: Alignment.center,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('\n0 RVN', style: Theme.of(context).textTheme.headline3),
                IconButton(
                    onPressed: () {
                      /*show available assets and balances for this account*/
                    },
                    padding: EdgeInsets.only(top: 24.0),
                    icon: Icon(
                      Icons.change_circle_outlined,
                      color: Colors.white,
                    ))
              ]),
              Text('\n\$ 0.00', style: Theme.of(context).textTheme.headline5),
            ]),
          )));

  ListView body() {
    var _controller = TextEditingController();
    return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(20.0),
        children: <Widget>[
          Form(
              key: formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _controller,
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
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Amount',
                          hintText: 'Quantity'),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('fee'), Text('0.01397191 RVN')]),
                    TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Note',
                          hintText: 'Note to Self'),
                    ),
                    //Center(child: sendTransactionButton(_formKey))
                  ]))
        ]);
  }

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
      style: RavenButtonStyle().curvedSides);
}
