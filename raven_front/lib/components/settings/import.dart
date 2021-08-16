import 'package:flutter/material.dart';

AppBar header(context) {
  return AppBar(
    backgroundColor: Colors.blue[900],
    leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.grey[100]),
        onPressed: () => Navigator.pop(context)),
    elevation: 2,
    centerTitle: false,
    title: Text('Import Wallet',
        style: TextStyle(fontSize: 18.0, letterSpacing: 2.0)),
  );
}

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

Row importWaysButtons(context) {
  return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    ElevatedButton.icon(
        icon: Icon(Icons.qr_code_scanner),
        label: Text('Scan'),
        onPressed: () {
          //Navigator.push(
          //  context,
          //  MaterialPageRoute(builder: (context) => Receive()),
          //);
        },
        style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0)))))),
    ElevatedButton.icon(
        icon: Icon(Icons.upload_file),
        label: Text('File'),
        onPressed: () {
          //Navigator.push(
          //  context,
          //  MaterialPageRoute(builder: (context) => Send()),
          //);
        },
        style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))))))
  ]);
}
