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
    Color? bgColor = Colors.blueAccent[50];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text(
          'name: ' + (data['account'] ?? 'unknown'),
          style: TextStyle(
            fontSize: 18.0,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
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
      // setting drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                children: <Widget>[
                  Text('Wallet Settings'),
                  //SizedBox(height: 10.0),
                  // change account button
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
                      color: Colors.grey[850],
                    ),
                    label: Text(
                      'Change Wallet',
                      style: TextStyle(
                        color: Colors.grey[850],
                      ),
                    ),
                  ),
                  //SizedBox(height: 5.0),
                  // sync
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          'last synced: now',
                          style: TextStyle(
                            fontSize: 14.0,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Spacer(),
                        TextButton.icon(
                          onPressed: () async {},
                          icon: Icon(
                            Icons.refresh,
                            color: Colors.grey[850],
                          ),
                          label: Text(
                            'Refresh',
                            style: TextStyle(
                              color: Colors.grey[850],
                            ),
                          ),
                        ),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          'Wallet type:',
                          style: TextStyle(
                            fontSize: 14.0,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'RVN Mainnet', // mainnet, testnet, single address (mainnet)
                          style: TextStyle(
                            fontSize: 14.0,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ]),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(5, 0.0, 15.0, 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextButton.icon(
                    onPressed: () async {
                      //this should happen just by touching the name...
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Colors.grey[850],
                    ),
                    label: Text(
                      'Change Wallet Name',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.grey[850],
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      // delete this account...
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.grey[850],
                    ),
                    label: Text(
                      'Delete Wallet',
                      style: TextStyle(
                        color: Colors.grey[850],
                      ),
                    ),
                  ),
                  // Security
                  TextButton.icon(
                    onPressed: () async {},
                    icon: Icon(
                      Icons.security,
                      color: Colors.grey[850],
                    ),
                    label: Text(
                      'See Account Passphrase',
                      style: TextStyle(
                        color: Colors.grey[850],
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {},
                    icon: Icon(
                      Icons.list,
                      color: Colors.grey[850],
                    ),
                    label: Text(
                      'See Wallet Addresses',
                      style: TextStyle(
                        color: Colors.grey[850],
                      ),
                    ),
                  ),
                  // Transactions
                  TextButton.icon(
                    onPressed: () async {},
                    icon: Icon(
                      Icons.list,
                      color: Colors.grey[850],
                    ),
                    label: Text(
                      'See Transactions',
                      style: TextStyle(
                        color: Colors.grey[850],
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {},
                    icon: Icon(
                      Icons.save,
                      color: Colors.grey[850],
                    ),
                    label: Text(
                      'Export Transaction History',
                      style: TextStyle(
                        color: Colors.grey[850],
                      ),
                    ),
                  ),
                  // trade assets
                  TextButton.icon(
                    onPressed: () async {
                      //this should happen just by touching the name...
                    },
                    icon: Icon(
                      Icons.swap_calls,
                      color: Colors.grey[850],
                    ),
                    label: Text(
                      'Trade Assets',
                      style: TextStyle(
                        color: Colors.grey[850],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
