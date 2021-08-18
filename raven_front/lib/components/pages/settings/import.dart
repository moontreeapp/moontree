import 'package:flutter/material.dart';
import 'package:raven_mobile/components/styles/buttons.dart';
import 'package:raven_mobile/styles.dart';
import 'package:raven_mobile/components/buttons.dart';

AppBar header(context) => AppBar(
    backgroundColor: RavenColor().appBar,
    leading: RavenButton().back(context),
    elevation: 2,
    centerTitle: false,
    title: RavenText('Import Wallet').h2);

ListView body(_formKey) {
  var _controller = TextEditingController();
  return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.all(20.0),
      children: <Widget>[
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _controller,
                maxLength: null,
                maxLines: null,
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: ("Please enter your seed words, WIF, or anything "
                        "you've got. We will do our best to import your "
                        "wallet accordingly.")),
                //validator: (String? value) {
                //  //if (value == null || value.isEmpty) {
                //  //  return 'Please enter a valid address';
                //  //}
                //  //return null;
                //},
              )
            ],
          ),
        )
      ]);
}

Row importWaysButtons(context) =>
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      ElevatedButton.icon(
          icon: Icon(Icons.qr_code_scanner),
          label: Text('Scan'),
          onPressed: () {
            //Navigator.push(
            //  context,
            //  MaterialPageRoute(builder: (context) => Receive()),
            //);
          },
          style: RavenButtonStyle().leftSideCurved),
      ElevatedButton.icon(
          icon: Icon(Icons.upload_file),
          label: Text('File'),
          onPressed: () {
            //Navigator.push(
            //  context,
            //  MaterialPageRoute(builder: (context) => Send()),
            //);
          },
          style: RavenButtonStyle().rightSideCurved)
    ]);
