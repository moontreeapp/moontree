import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
    return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(10.0),
        children: <Widget>[
          SizedBox(height: 15.0),
          // Balance
          Text(
            (data['account'] ?? '(unknown)'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32.0,
              letterSpacing: 2.0,
            ),
          ),
          Text(
            // rvn is default but if balance is 0 then take the largest asset balance and also display name here.
            'RVN',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.0,
              letterSpacing: 1.6,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 30.0),
          Center(
              child: QrImage(
            data: "mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7",
            version: QrVersions.auto,
            size: 200.0,
          )),
          Center(
              child: SelectableText(
            'mp4dJLeLDNi4B9vZs46nEtM478cUvmx4m7',
            cursorColor: Colors.grey[850],
            showCursor: true,
            toolbarOptions: ToolbarOptions(
                copy: true, selectAll: true, cut: false, paste: false),
            style: TextStyle(
              color: Colors.grey[850],
            ),
          )),
          SizedBox(height: 40.0),
          ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(15.0),
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton.icon(
                        onPressed: () async {
                          // administer
                        },
                        icon: Icon(
                          Icons.shield, // administer
                          color: Colors.grey[850],
                        ),
                        label: Text(
                          'Asset 0',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[850],
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          // see history
                        },
                        icon: Icon(
                          Icons.history,
                          color: Colors.grey[850],
                        ),
                        label: Text(
                          'Balance',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[850],
                          ),
                        ),
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton.icon(
                        onPressed: () async {
                          // administer
                        },
                        icon: Icon(
                          Icons
                              .settings, // manage (administer with less options)
                          color: Colors.grey[850],
                        ),
                        label: Text(
                          'Asset 1',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[850],
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          // see history
                        },
                        icon: Icon(
                          Icons.history,
                          color: Colors.grey[850],
                        ),
                        label: Text(
                          'Balance',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[850],
                          ),
                        ),
                      ),
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton.icon(
                        onPressed: () async {
                          // administer
                        },
                        icon: Icon(
                          Icons.remove_red_eye, // view only
                          color: Colors.grey[850],
                        ),
                        label: Text(
                          'Asset 2',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[850],
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          // see history
                        },
                        icon: Icon(
                          Icons.history,
                          color: Colors.grey[850],
                        ),
                        label: Text(
                          'Balance',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[850],
                          ),
                        ),
                      ),
                    ]),
                TextButton.icon(
                  onPressed: () async {
                    //this should happen just by touching the name...
                  },
                  icon: Icon(
                    Icons.add,
                    color: Colors.grey[850],
                  ),
                  label: Text(
                    'Create',
                    style: TextStyle(
                      color: Colors.grey[850],
                    ),
                  ),
                ),
              ]),
          // seems as though we have to pull this send button out of the listView in order to have it stay there at the bottom...
          ///Align(
          ///    alignment: Alignment.bottomCenter,
          ///    child: IconButton(
          ///      icon: Icon(Icons.favorite),
          ///      onPressed: () async {},
          ///    )),
          SizedBox(height: 20.0),
          // fix want it always at bottom of screen
          TextButton.icon(
            onPressed: () async {},
            icon: Icon(
              Icons.send,
              color: Colors.grey[850],
            ),
            label: Text(
              'Send', // rvn or assets
              style: TextStyle(
                color: Colors.grey[850],
              ),
            ),
          ),
        ]);
  }
}
