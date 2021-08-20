import 'package:flutter/material.dart';

import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:raven_mobile/theme/extensions.dart';

class Transaction extends StatefulWidget {
  final dynamic data;
  const Transaction({this.data}) : super();

  @override
  _TransactionState createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
        appBar: header(),
        body: body(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
          title: Text('Transaction Details'),
          flexibleSpace: Container(
            alignment: Alignment.center,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(height: 15.0),
              RavenIcon.assetAvatar('Magic Musk'),
              SizedBox(height: 15.0),
              Text('Magic Musk', style: Theme.of(context).textTheme.headline4),
              SizedBox(height: 15.0),
              Text('Received', style: Theme.of(context).textTheme.headline5),
            ]),
          )));

// perhaps this should be two tabs, one for tx details, one for metadata
  ListView body() =>
      ListView(shrinkWrap: true, padding: EdgeInsets.all(20.0), children: <
          Widget>[
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Date: June 26 2021',
              style: TextStyle(color: Theme.of(context).disabledColor)),
          Text('Confirmaitons: 60+',
              style: TextStyle(color: Theme.of(context).disabledColor)),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          SizedBox(height: 15.0),
          TextField(
            readOnly: true,
            controller: TextEditingController(
                text: 'rtahoe5eu4e4ea451ea21e445euaeu454'),
            decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'To',
                hintText: 'Address'),
          ),
          SizedBox(height: 15.0),
          TextField(
            readOnly: true,
            controller: TextEditingController(text: '500'),
            decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Amount',
                hintText: 'Quantity'),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('fee',
                style: TextStyle(color: Theme.of(context).disabledColor)),
            Text('0.01397191 RVN',
                style: TextStyle(color: Theme.of(context).disabledColor)),
          ]),
          SizedBox(height: 15.0),
          TextField(
            readOnly: true,
            controller: TextEditingController(text: ':)'),
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Note',
                hintText: 'Note to Self'),
          ),
          SizedBox(height: 15.0),
          Text('id: 1354s31e35s13f54se3851f3s51ef35s1ef35',
              style: TextStyle(color: Theme.of(context).disabledColor)),
          SizedBox(height: 15.0),
          ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.description),
              label: Text('Metadata'))
        ])
      ]);
}
