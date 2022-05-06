import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_electrum/raven_electrum.dart';

import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/colors.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/client.dart';
import 'package:raven_front/widgets/widgets.dart';

class ElectrumNetwork extends StatefulWidget {
  final dynamic data;
  const ElectrumNetwork({this.data}) : super();

  @override
  _ElectrumNetworkState createState() => _ElectrumNetworkState();
}

class _ElectrumNetworkState extends State<ElectrumNetwork> {
  List<StreamSubscription> listeners = [];
  TextEditingController network = TextEditingController(text: 'Ravencoin');
  TextEditingController serverAddress = TextEditingController(text: '');
  FocusNode networkFocus = FocusNode();
  FocusNode serverFocus = FocusNode();
  FocusNode connectFocus = FocusNode();
  bool validated = true;
  bool pressed = false;
  bool enableSubmit = false;
  RavenElectrumClient? client;

  @override
  void initState() {
    serverAddress.text =
        '${services.client.currentDomain}:${services.client.currentPort}';
    listeners.add(res.settings.changes
        .listen((Change<Setting> changes) => setState(() {})));
    listeners
        .add(streams.client.client.listen((RavenElectrumClient? ravenClient) {
      if (ravenClient != null && client != ravenClient && pressed) {
        setState(() {});
        streams.app.snack
            .add(Snack(message: 'Successfully Connected', atBottom: true));
      }
    }));
    super.initState();
  }

  @override
  void dispose() {
    connectFocus.dispose();
    networkFocus.dispose();
    serverFocus.dispose();
    network.dispose();
    serverAddress.dispose();
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropLayers(
        back: BlankBack(),
        front: FrontCurve(
            child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: services.password.askCondition
              ? VerifyPassword(parentState: this)
              : body(),
        )));
  }

  Widget body() => CustomScrollView(slivers: <Widget>[
        //SliverToBoxAdapter(child: SizedBox(height: 6)),
        //SliverToBoxAdapter(
        //    child: Padding(
        //        padding:
        //            EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
        //        child: networkTextField)),
        SliverToBoxAdapter(
            child: Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
                child: serverTextField)),
        SliverToBoxAdapter(
            child: Container(height: MediaQuery.of(context).size.height / 2)),
        SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 100),
                  components.containers
                      .navBar(context, child: Row(children: [submitButton])),
                ])),
      ]);

  Widget get networkTextField => Container(
      height: 81,
      alignment: Alignment.bottomCenter,
      child: TextField(
        focusNode: networkFocus,
        autocorrect: false,
        controller: network,
        textInputAction: TextInputAction.done,
        decoration: components.styles.decorations.textField(
          context,
          focusNode: networkFocus,
          labelText: 'Network',
        ),
        onEditingComplete: () {
          network.text = network.text.trim();
        },
      ));

  Widget get serverTextField => TextField(
        focusNode: serverFocus,
        autocorrect: false,
        controller: serverAddress,
        textInputAction: TextInputAction.done,
        decoration: components.styles.decorations.textField(
          context,
          focusNode: serverFocus,
          labelText: 'Server',
          hintText: streams.client.client.value != null
              ? '${streams.client.client.value!.host}:${streams.client.client.value!.port}'
              : '${services.client.currentDomain}:${services.client.currentPort.toString()}',
          helperText: validated
              ? services.client.connectionStatus &&
                      matches &&
                      streams.client.connected.value ==
                          ConnectionStatus.connected
                  ? 'Connected'
                  : null
              : null,
          errorText: validated ? null : 'Invalid Server',
          helperStyle: Theme.of(context)
              .textTheme
              .caption!
              .copyWith(height: .8, color: AppColors.success),
          alwaysShowHelper: true,
        ),
        onChanged: (String value) {
          enableSubmit = true;
          validated = validateDomainPort(value);
        },
        onEditingComplete: () {
          enableSubmit = true;
          serverAddress.text = serverAddress.text.trim();
          validated = validateDomainPort(serverAddress.text);
          FocusScope.of(context).requestFocus(connectFocus);
          setState(() {});
        },
      );

  bool get matches =>
      serverAddress.text ==
      '${services.client.currentDomain}:${services.client.currentPort.toString()}';

  Widget get submitButton => components.buttons.actionButton(
        context,
        focusNode: connectFocus,
        enabled: validateDomainPort(serverAddress.text) && enableSubmit,
        label: 'Connect',
        onPressed: attemptSave,
      );

  void attemptSave() {
    if (validateDomainPort(serverAddress.text)) {
      FocusScope.of(context).unfocus();
      save();
    }
  }

  // validate domain:port structure
  bool validateDomainPort(String value) =>
      value.contains(':') && value.split(':').last.isInt;

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
    components.loading.screen(message: 'Connecting', returnHome: false);
    pressed = true;
  }
}
