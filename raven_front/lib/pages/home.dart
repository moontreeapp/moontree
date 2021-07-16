import 'package:flutter/material.dart';

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
            child: Column(
              children: <Widget>[
                TextButton.icon(
                  onPressed: () async {
                    dynamic result =
                        await Navigator.pushNamed(context, '/account');
                    setState(() {
                      if (result == null) {
                        data = data;
                      } else {
                        data = {'account': result};
                      }
                    });
                  },
                  icon: Icon(
                    Icons.change_circle,
                    color: Colors.grey[300],
                  ),
                  label: Text(
                    'Change Wallet',
                    style: TextStyle(
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                SizedBox(height: 120.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      data['account'] ?? 'unknown',
                      style: TextStyle(
                        fontSize: 28.0,
                        letterSpacing: 2.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Text(data['account'] ?? 'unknown',
                    style: TextStyle(fontSize: 66.0, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
