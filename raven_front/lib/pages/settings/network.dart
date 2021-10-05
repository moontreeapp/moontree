import 'package:flutter/material.dart';

import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/theme/extensions.dart';
import 'package:raven_mobile/utils/transform.dart';
import 'package:raven/raven.dart';

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
  bool passwordVerified = false;
  final TextEditingController password = TextEditingController();

  @override
  void initState() {
    passwordVerified = false;
    electrumAddress.text =
        '${services.client.preferredElectrumDomain}:${services.client.preferredElectrumPort}';
    electrumAddressFirstBackup.text =
        '${services.client.firstBackupElectrumDomain}:${services.client.firstBackupElectrumPort}';
    electrumAddressSecondBackup.text =
        '${services.client.secondBackupElectrumDomain}:${services.client.secondBackupElectrumPort}';
    super.initState();
  }

  @override
  void dispose() {
    electrumAddress.dispose();
    electrumAddressFirstBackup.dispose();
    electrumAddressSecondBackup.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: header(), body: body());

  AppBar header() => AppBar(
      leading: RavenButton.back(context),
      elevation: 2,
      centerTitle: false,
      title: Text('Electrum Network'));

  ListView body() => ListView(
        padding: EdgeInsets.all(20),
        children: <Widget>[
          Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                    '${services.client.chosenDomain}:${services.client.chosenPort.toString()}'),
                ...[
                  services.client.connectionStatus
                      ? Text(
                          'connected',
                          style: TextStyle(color: Theme.of(context).good),
                        )
                      : Text(
                          'disconnected',
                          style: TextStyle(color: Theme.of(context).bad),
                        )
                ],
                Text(services.client.mostRecentRavenClient.toString()),
                TextButton.icon(
                    onPressed: () {
                      // flush out current connection and allow waiter to reestablish one
                      subjects.client.sink.add(null);
                      // show that waits for valid connection or times out...
                      // todo
                      setState(() {});
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('refresh connection')),
              ]),
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
        ],
      );

  void attemptSave() {
    if (validateDomainPort(electrumAddress.text) &&
        validateDomainPort(electrumAddressFirstBackup.text) &&
        validateDomainPort(electrumAddressSecondBackup.text)) {
      if (!passwordVerified) {
        requestPassword();
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
    print(services.passwords.validate.password(password.text));
    if (services.passwords.validate.password(password.text)) {
      passwordVerified = true;
      services.client.saveElectrumAddresses(domains: [
        electrumAddress.text.split(':')[0],
        electrumAddressFirstBackup.text.split(':')[0],
        electrumAddressSecondBackup.text.split(':')[0],
      ], ports: [
        int.parse(electrumAddress.text.split(':')[1]),
        int.parse(electrumAddressFirstBackup.text.split(':')[1]),
        int.parse(electrumAddressSecondBackup.text.split(':')[1]),
      ]);
      return true;
    }
    return false;
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
