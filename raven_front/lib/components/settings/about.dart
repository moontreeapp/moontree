import 'package:flutter/material.dart';

AppBar header(context) {
  return AppBar(
    backgroundColor: Colors.blue[900],
    leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.grey[100]),
        onPressed: () => Navigator.pop(context)),
    elevation: 2,
    centerTitle: false,
    title: Text('About', style: TextStyle(fontSize: 18.0, letterSpacing: 2.0)),
  );
}

Center body(context) {
  return Center(
    child: Column(
      children: <Widget>[
        Image(image: AssetImage('assets/ravenhead.png')),
        Text('Github.com/moontreeapp'),
        Text('MoonTreeLLC 2021'),
      ],
    ),
  );
}
