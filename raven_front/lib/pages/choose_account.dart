import 'package:flutter/material.dart';
import '../services/account_mock.dart';

class ChooseAccount extends StatefulWidget {
  @override
  _ChooseAccountState createState() => _ChooseAccountState();
}

class _ChooseAccountState extends State<ChooseAccount> {
  Map<String, String> accounts = Accounts.instance.accounts;

  @override
  void initState() {
    super.initState();
  }

  Future<void> updateChosen(String key) async {
    Future.delayed(Duration(seconds: 1));
    Navigator.pop(context, accounts[key]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
            backgroundColor: Colors.blue[900],
            title: Text('Choose an Account'),
            centerTitle: true,
            elevation: 0),
        body: ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 1.0, horizontal: 4.0),
                  child: Card(
                      child: ListTile(
                          onTap: () => updateChosen('accountId$index'),
                          title: Text(
                              '${index.toString()} - ${accounts["accountId${index.toString()}"]}'),
                          leading: CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/ravenhead.png')))));
            }));
  }
}
