import 'package:flutter/material.dart';

import 'account_view.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;

    // set background image
    //String bgImage = 'ravenbg.png';
    Color? bgColor = Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Container(
          //decoration: BoxDecoration(
          //  image: DecorationImage(
          //    image: AssetImage('assets/$bgImage'),
          //    fit: BoxFit.cover,
          //  ),
          //),
          child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
              child: AccountView(data: data)),
        ),
      ),
    );
  }
}
