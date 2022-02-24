/// we'll probably need to convert this over for wallets so we'll keep it
/// for reference 

/*
import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_back/raven_back.dart';

/// changes the name of existing account
Future<bool> updateAcount(Account account, String name) async {
  if (account.name == name) {
    return true;
  }
  name = utils.removeChars(name);
  if (res.accounts.byName.getAll(name).length > 0 || name == '') {
    return false;
  }
  await res.accounts.save(
      Account(accountId: account.accountId, name: name, net: account.net));
  return true;
}

List<Widget> createNewAcount(
  BuildContext context,
  TextEditingController accountName,
) =>
    [
      SizedBox(height: 5),
      ListTile(
        onTap: () {}, //async => _validateAndCreateAccount(),
        title: TextField(
          readOnly: false,
          controller: accountName,
          decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Create Account',
              hintText: 'Hodl'),
          onSubmitted: (_) async =>
              validateAndCreateAccount(context, accountName),
        ),
        trailing: IconButton(
            onPressed: () async =>
                validateAndCreateAccount(context, accountName),
            icon: Icon(Icons.add, size: 26.0, color: Colors.grey.shade800)),
      )
    ];

Future validateAndCreateAccount(
  BuildContext context,
  TextEditingController accountName,
) async {
  var desiredAccountName = utils.removeChars(accountName.text.trim());
  accountName.text = desiredAccountName;
  if (desiredAccountName == '') {
    components.alerts.failure(context,
        headline: 'Unable to create account',
        msg: 'Please enter new account name');
    return;
  }
  if (res.accounts.data
      .map((account) => account.name)
      .toList()
      .contains(desiredAccountName)) {
    components.alerts.failure(context,
        headline: 'Unable to create account',
        msg: 'Account name, "$desiredAccountName" is already taken. '
            'Please enter a uinque account name.');
    return;
  }
  // todo replace with a legit spinner, and reduce amount of time it's waiting
  showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
          title: Text('Generating Account...'),
          content:
              Text('Please wait, generating a new account with a new default '
                  'wallet can take several seconds...')));
  // this is used to get the please wait message to show up
  // it needs enough time to display the message
  await Future.delayed(const Duration(milliseconds: 150));
  var account = await services.account.createSave(desiredAccountName,
      net: res.settings.primaryIndex.getOne(SettingName.Electrum_Net)!.value);
  await res.settings.save(
      Setting(name: SettingName.Account_Current, value: account.accountId));
  Navigator.popUntil(context, ModalRoute.withName('/home'));
  desiredAccountName = '';
  accountName.text = '';
}
*/