import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_electrum/raven_electrum.dart';

import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/utils/transform.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/widgets/widgets.dart';

class ElectrumNetwork extends StatefulWidget {
  final dynamic data;
  const ElectrumNetwork({this.data}) : super();

  @override
  _ElectrumNetworkState createState() => _ElectrumNetworkState();
}

class _ElectrumNetworkState extends State<ElectrumNetwork> {
  List<StreamSubscription> listeners = [];
  TextEditingController serverAddress = TextEditingController(text: '');
  FocusNode serverFocusNode = FocusNode();
  bool validated = true;

  @override
  void initState() {
    serverAddress.text =
        '${services.client.currentDomain}:${services.client.currentPort}';
    listeners.add(res.settings.changes
        .listen((Change<Setting> changes) => setState(() {})));
    listeners.add(streams.client.client
        .listen((RavenElectrumClient? ravenClient) => setState(() {})));
    super.initState();
  }

  @override
  void dispose() {
    serverAddress.dispose();
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: services.password.required && !streams.app.verify.value
          ? VerifyPassword(parentState: this)
          : body(),
    );
  }

  Widget body() => Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          serverTextField(),
          Padding(
              padding: EdgeInsets.only(
                top: 0,
                bottom: 40,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [submitButton()]))
        ],
      ));

  Widget serverTextField() => TextField(
        focusNode: serverFocusNode,
        autocorrect: false,
        controller: serverAddress,
        textInputAction: TextInputAction.done,
        decoration: components.styles.decorations.textFeild(
          context,
          labelText: 'Server',
          hintText: streams.client.client.value != null
              ? '${streams.client.client.value!.host}:${streams.client.client.value!.port}'
              : '${services.client.currentDomain}:${services.client.currentPort.toString()}',
          helperText: validated
              ? services.client.connectionStatus
                  ? 'Connected'
                  : 'Connecting...'
              : null,
          errorText: validated ? null : 'Invalid Server',
        ),
        onChanged: (String value) => validated = validateDomainPort(value),
        onEditingComplete: () {
          serverAddress.text = serverAddress.text.trim();
          validated = validateDomainPort(serverAddress.text);
        },
      );

  Widget submitButton() => Container(
      height: 40,
      child: OutlinedButton.icon(
          onPressed: validated ? () => attemptSave() : () {},
          icon: Icon(
            Icons.lock_rounded,
            color: validated ? null : Color(0x61000000),
          ),
          label: Text(
            'Set'.toUpperCase(),
            style: validated
                ? Theme.of(context).enabledButton
                : Theme.of(context).disabledButton,
          ),
          style: components.styles.buttons.bottom(
            context,
            disabled: !validated,
          )));

  void attemptSave() {
    if (validateDomainPort(serverAddress.text)) {
      FocusScope.of(context).unfocus();
      save();
    }
  }

  // validate domain:port structure
  bool validateDomainPort(String value) =>
      value.contains(':') && stringIsInt(value.split(':').last);

  void save() {
    var port = serverAddress.text.split(':').last;
    var domain = serverAddress.text
        .substring(0, serverAddress.text.lastIndexOf(port) - 1);
    services.client.saveElectrumAddress(
      domain: domain,
      port: int.parse(port),
    );
    // flush out current connection and allow waiter to reestablish one
    streams.client.client.add(null);
    setState(() {});
  }
}
