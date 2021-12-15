import 'dart:async';

import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';

import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/utils/transform.dart';
import 'package:raven_back/raven_back.dart';

class ElectrumNetwork extends StatefulWidget {
  final dynamic data;
  const ElectrumNetwork({this.data}) : super();

  @override
  _ElectrumNetworkState createState() => _ElectrumNetworkState();
}

class _ElectrumNetworkState extends State<ElectrumNetwork> {
  TextEditingController electrumAddress = TextEditingController(text: '');
  TextEditingController electrumAddressFirstBackup =
      TextEditingController(text: '');
  TextEditingController electrumAddressSecondBackup =
      TextEditingController(text: '');
  TextEditingController electrumAddressTest = TextEditingController(text: '');
  bool passwordVerified = false;
  final TextEditingController password = TextEditingController();
  List<StreamSubscription> listeners = [];
  List<bool>? isSelected;

  @override
  void initState() {
    passwordVerified = false;
    electrumAddress.text =
        '${services.client.preferredElectrumDomain}:${services.client.preferredElectrumPort}';
    electrumAddressFirstBackup.text =
        '${services.client.firstBackupElectrumDomain}:${services.client.firstBackupElectrumPort}';
    electrumAddressSecondBackup.text =
        '${services.client.secondBackupElectrumDomain}:${services.client.secondBackupElectrumPort}';
    electrumAddressTest.text =
        '${services.client.testElectrumDomain}:${services.client.testElectrumPort}';
    listeners.add(settings.changes.listen((changes) => setState(() {})));
    listeners.add(streams.client.client.stream
        .listen((ravenClient) async => setState(() {})));
    var value = settings.primaryIndex.getOne(SettingName.Electrum_Net)!.value;
    isSelected = isSelected ?? [value == Net.Main, value == Net.Test];
    super.initState();
  }

  @override
  void dispose() {
    electrumAddress.dispose();
    electrumAddressFirstBackup.dispose();
    electrumAddressSecondBackup.dispose();
    electrumAddressTest.dispose();
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: components.headers.back(context, 'Electrum Server'),
          body: body(),
        ));
  }

  ListView body() => ListView(
        padding: EdgeInsets.all(20),
        children: <Widget>[
          Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                isSelected![0] == true
                    ? streams.client.client.value != null
                        ? Text(
                            '${streams.client.client.value!.host}:${streams.client.client.value!.port}')
                        : Text(
                            '${services.client.chosenDomain}:${services.client.chosenPort.toString()}')
                    : Text(
                        '${services.client.testElectrumDomain}:${services.client.testElectrumPort.toString()}'),
                ...[
                  services.client.connectionStatus
                      ? Text(
                          'connected',
                          style: TextStyle(color: Theme.of(context).good),
                        )
                      : Column(children: [
                          Text(
                            'disconnected',
                            style: TextStyle(color: Theme.of(context).bad),
                          ),
                          Text('connecting...'),
                        ])
                ],
                TextButton.icon(
                    onPressed: () {
                      // flush out current connection and allow waiter to reestablish one
                      streams.client.client.sink.add(null);
                      // show that waits for valid connection or times out...
                      // todo
                      setState(() {});
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('refresh connection')),
              ]),
          SizedBox(height: 20),
          ToggleButtons(
              children: <Widget>[Text('MainNet'), Text('TestNet')],
              isSelected: isSelected ?? [false, true],
              onPressed: (int index) async {
                if (index == 0 && !isSelected!.first) {
                  isSelected = [true, false];
                  await settings.save(
                      Setting(name: SettingName.Electrum_Net, value: Net.Main));
                  var changeAccount = accounts.getBestAccount(Net.Main);
                  if (changeAccount != null) {
                    await settings.setCurrentAccountId(changeAccount.accountId);
                  }
                } else if (index == 1 && !isSelected!.last) {
                  isSelected = [false, true];
                  await settings.save(
                      Setting(name: SettingName.Electrum_Net, value: Net.Test));
                  var changeAccount = accounts.getBestAccount(Net.Test);
                  if (changeAccount != null) {
                    await settings.setCurrentAccountId(changeAccount.accountId);
                  }
                }
                setState(() {});
              }),
          SizedBox(height: 20),
          TextField(
            autocorrect: false,
            controller: electrumAddress,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Preferred Electrum Domain:Port',
              hintText: 'testnet.rvn.com:5000',
            ),
            onEditingComplete: () => attemptSave(),
          ),
          TextField(
            autocorrect: false,
            controller: electrumAddressFirstBackup,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'First Backup Electrum Domain:Port',
              hintText: 'testnet.rvn.com:5000',
            ),
            onEditingComplete: () => attemptSave(),
          ),
          TextField(
            autocorrect: false,
            controller: electrumAddressSecondBackup,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Second Backup Electrum Domain:Port',
              hintText: 'testnet.rvn.com:5000',
            ),
            onEditingComplete: () => attemptSave(),
          ),
          TextField(
            autocorrect: false,
            controller: electrumAddressTest,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'TestNet Electrum Domain:Port',
              hintText: 'testnet.rvn.com:5000',
            ),
            onEditingComplete: () => attemptSave(),
          ),
          SizedBox(height: 50),
          Text('What is the Electrum server?\n',
              style: Theme.of(context).textTheme.caption),
          Text(
              'The Electrum server is what connects this lightweight RavenWallet to the Ravencoin blockchain.\n\nIt holds a record of the entire blockchain so your device doesn\'t have to. As such, you should only connect to trusted Electrum servers.\n\nMore advanced users may run their own Electrum server and connect directly to it by modifying the settings on this page.'),
        ],
      );

  void attemptSave() {
    if (validateDomainPort(electrumAddress.text) &&
        validateDomainPort(electrumAddressFirstBackup.text) &&
        validateDomainPort(electrumAddressSecondBackup.text) &&
        validateDomainPort(electrumAddressTest.text)) {
      FocusScope.of(context).unfocus();
      if (services.password.required && !passwordVerified) {
        requestPassword();
      } else {
        save();
        alertSuccess();
      }
    } else {
      alertValidationFailure();
    }
  }

  // validate this domain and port - url structure
  bool validateDomainPort(String value) => (value.contains(':') &&
      !value.split(':')[0].contains('://') &&
      stringIsInt(value.split(':')[1]));

  Future requestPassword() => showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: <Widget>[
              TextField(
                  autocorrect: false,
                  controller: password,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'password',
                  ),
                  onEditingComplete: () {
                    if (submit()) {
                      Navigator.pop(context);
                      alertSuccess();
                    }
                  }),
            ],
          ),
        );
      });

  bool submit() {
    if (services.password.validate.password(password.text)) {
      passwordVerified = true;
      save();
      return true;
    }
    return false;
  }

  void save() {
    services.client.saveElectrumAddresses(domains: [
      electrumAddress.text.split(':')[0],
      electrumAddressFirstBackup.text.split(':')[0],
      electrumAddressSecondBackup.text.split(':')[0],
      electrumAddressTest.text.split(':')[0],
    ], ports: [
      int.parse(electrumAddress.text.split(':')[1]),
      int.parse(electrumAddressFirstBackup.text.split(':')[1]),
      int.parse(electrumAddressSecondBackup.text.split(':')[1]),
      int.parse(electrumAddressTest.text.split(':')[1]),
    ]);
  }

  Future alertSuccess() => showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text('Success!'),
            content: Text('Electrum Network Settings Saved!'),
            actions: [
              TextButton(
                  child: Text('ok'), onPressed: () => Navigator.pop(context))
            ],
          ));

  Future alertValidationFailure() => showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text('Unrecognized Electrum URL'),
            content: Text(
                'Electrum Server addresses must follow this format: domain:port'),
            actions: [
              TextButton(
                  child: Text('ok'), onPressed: () => Navigator.pop(context))
            ],
          ));
}
