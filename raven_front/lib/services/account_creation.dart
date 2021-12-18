import 'package:flutter/material.dart';
import 'package:raven_front/utils/transform.dart';
import 'package:raven_back/raven_back.dart';

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
  var desiredAccountName = removeChars(accountName.text.trim());
  accountName.text = desiredAccountName;
  if (desiredAccountName == '') {
    alertFailure(context,
        headline: 'Unable to create account',
        msg: 'Please enter new account name');
    return;
  }
  if (accounts.data
      .map((account) => account.name)
      .toList()
      .contains(desiredAccountName)) {
    alertFailure(context,
        headline: 'Unable to create account',
        msg:
            'Account name, "$desiredAccountName" is already taken. Please enter a uinque account name.');
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
      net: settings.primaryIndex.getOne(SettingName.Electrum_Net)!.value);
  await settings.save(
      Setting(name: SettingName.Account_Current, value: account.accountId));
  Navigator.popUntil(context, ModalRoute.withName('/home'));
  desiredAccountName = '';
  accountName.text = '';
}

Future alertFailure(
  BuildContext context, {
  String headline = 'Unable to create account',
  String msg = 'Please enter account name',
}) =>
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(headline),
              content: Text(msg),
              actions: [
                TextButton(
                    child: Text('ok'),
                    onPressed: () => Navigator.of(context).pop())
              ],
            ));
