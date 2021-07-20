import 'package:flutter/material.dart';

class AccountView extends StatefulWidget {
  final dynamic data;

  const AccountView({this.data}) : super();

  @override
  _AccountViewState createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // change account button
        TextButton.icon(
          onPressed: () async {
            dynamic result = await Navigator.pushNamed(context, '/account');
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
        SizedBox(height: 20.0),
        // name stuff
        Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Text(
            'name: ' + (data['account'] ?? 'unknown'),
            style: TextStyle(
              fontSize: 28.0,
              letterSpacing: 2.0,
              color: Colors.white,
            ),
          ),
        ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ButtonBar(
              children: [
                TextButton.icon(
                  onPressed: () async {
                    //this should happen just by touching the name...
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.grey[300],
                  ),
                  label: Text(
                    'Change Wallet Name',
                    style: TextStyle(
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    // delete this account...
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Colors.grey[300],
                  ),
                  label: Text(
                    'Delete Wallet',
                    style: TextStyle(
                      color: Colors.grey[300],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        SizedBox(height: 20.0),
        // Balance
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text(
            'balance: ' + (data['account'] ?? 'unknown'),
            style: TextStyle(
              fontSize: 28.0,
              letterSpacing: 2.0,
              color: Colors.white,
            ),
          ),
        ]),
        SizedBox(height: 20.0),
        // Sync
        Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Text(
            'last synced: now',
            style: TextStyle(
              fontSize: 28.0,
              letterSpacing: 2.0,
              color: Colors.white,
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              //this should happen just by touching the name...
            },
            icon: Icon(
              Icons.refresh,
              color: Colors.grey[300],
            ),
            label: Text(
              'Refresh',
              style: TextStyle(
                color: Colors.grey[300],
              ),
            ),
          ),
        ]),
        SizedBox(height: 20.0),
        // Security
        Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          TextButton.icon(
            onPressed: () async {
              //this should happen just by touching the name...
            },
            icon: Icon(
              Icons.security,
              color: Colors.grey[300],
            ),
            label: Text(
              'see account pass phrase',
              style: TextStyle(
                color: Colors.grey[300],
              ),
            ),
          ),
        ]),
        SizedBox(height: 20.0),
        // Transactions
        Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          TextButton.icon(
            onPressed: () async {
              //this should happen just by touching the name...
            },
            icon: Icon(
              Icons.list,
              color: Colors.grey[300],
            ),
            label: Text(
              'see transactions',
              style: TextStyle(
                color: Colors.grey[300],
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              //this should happen just by touching the name...
            },
            icon: Icon(
              Icons.save,
              color: Colors.grey[300],
            ),
            label: Text(
              'export transaction history',
              style: TextStyle(
                color: Colors.grey[300],
              ),
            ),
          ),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          TextButton.icon(
            onPressed: () async {
              //this should happen just by touching the name...
            },
            icon: Icon(
              Icons.send,
              color: Colors.grey[300],
            ),
            label: Text(
              'send',
              style: TextStyle(
                color: Colors.grey[300],
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              //this should happen just by touching the name...
            },
            icon: Icon(
              Icons.get_app,
              color: Colors.grey[300],
            ),
            label: Text(
              'receive',
              style: TextStyle(
                color: Colors.grey[300],
              ),
            ),
          ),
        ]),
        SizedBox(height: 20.0),
        // Assets
        Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          TextButton.icon(
            onPressed: () async {
              //this should happen just by touching the name...
            },
            icon: Icon(
              Icons.list,
              color: Colors.grey[300],
            ),
            label: Text(
              'see assets',
              style: TextStyle(
                color: Colors.grey[300],
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              //this should happen just by touching the name...
            },
            icon: Icon(
              Icons.create,
              color: Colors.grey[300],
            ),
            label: Text(
              'Create Asset',
              style: TextStyle(
                color: Colors.grey[300],
              ),
            ),
          ),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          TextButton.icon(
            onPressed: () async {
              //this should happen just by touching the name...
            },
            icon: Icon(
              Icons.swap_calls,
              color: Colors.grey[300],
            ),
            label: Text(
              'Trade Assets',
              style: TextStyle(
                color: Colors.grey[300],
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              //this should happen just by touching the name...
            },
            icon: Icon(
              Icons.get_app,
              color: Colors.grey[300],
            ),
            label: Text(
              'receive',
              style: TextStyle(
                color: Colors.grey[300],
              ),
            ),
          ),
        ]),
      ],
    );
  }
}
