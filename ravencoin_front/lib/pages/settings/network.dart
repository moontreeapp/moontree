import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ravencoin_back/streams/app.dart';

import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/theme/colors.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/client.dart';
import 'package:ravencoin_front/widgets/front/choices/download_activity.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

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
  ConnectionStatus? connectionStatus;

  @override
  void initState() {
    super.initState();
    streams.app.verify.add(false);
    serverAddress.text =
        '${services.client.currentDomain}:${services.client.currentPort}';
    listeners.add(pros.settings.changes
        .listen((Change<Setting> changes) => setState(() {})));
    listeners.add(streams.client.connected.listen((ConnectionStatus value) {
      if (value == ConnectionStatus.connected &&
          value != connectionStatus &&
          pressed) {
        setState(() {});
        streams.app.snack.add(Snack(message: 'Successfully Connected'));
      }
    }));
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
              ? VerifyAuthentication(parentState: this)
              : body(),
        )));
  }

  Widget body() => CustomScrollView(slivers: <Widget>[
        //SliverToBoxAdapter(
        //    child: Padding(
        //        padding:
        //            EdgeInsets.only(left: 16, right: 16, top: 36, bottom: 16),
        //        child: Container(
        //            alignment: Alignment.topLeft, child: NetworkChoice()))),

        //SliverToBoxAdapter(child: SizedBox(height: 6)),
        //SliverToBoxAdapter(
        //    child: Padding(
        //        padding:
        //            EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
        //        child: networkTextField)),
        SliverToBoxAdapter(
            child: Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                child: serverTextField)),
        if (pros.settings.advancedDeveloperMode)
          SliverToBoxAdapter(
              child: Padding(
                  padding:
                      EdgeInsets.only(left: 16, right: 16, top: 36, bottom: 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Most Recent Network Activity',
                            style: Theme.of(context).textTheme.bodyText1),
                      ]))),
        if (pros.settings.advancedDeveloperMode)
          SliverToBoxAdapter(
              child: Padding(
                  padding:
                      EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 16),
                  child: Container(
                      alignment: Alignment.topLeft,
                      child: DownloadActivity()))),

        //SliverToBoxAdapter(
        //    child: Container(height: MediaQuery.of(context).size.height / 2)),
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
      child: TextFieldFormatted(
        focusNode: networkFocus,
        autocorrect: false,
        controller: network,
        textInputAction: TextInputAction.done,
        labelText: 'Network',
        onEditingComplete: () {
          network.text = network.text.trim();
        },
      ));

  Widget get serverTextField => TextFieldFormatted(
        focusNode: serverFocus,
        autocorrect: false,
        controller: serverAddress,
        textInputAction: TextInputAction.done,
        labelText: 'Server',
        hintText: services.client.ravenElectrumClient != null
            ? '${services.client.ravenElectrumClient!.host}:${services.client.ravenElectrumClient!.port}'
            : '${services.client.currentDomain}:${services.client.currentPort.toString()}',
        helperText: validated
            ? services.client.connectionStatus &&
                    matches &&
                    streams.client.connected.value == ConnectionStatus.connected
                ? 'Connected'
                : null
            : null,
        errorText: validated ? null : 'Invalid Server',
        helperStyle: Theme.of(context)
            .textTheme
            .caption!
            .copyWith(height: .8, color: AppColors.success),
        alwaysShowHelper: true,
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

  void save() async {
    var port = serverAddress.text.split(':').last;
    var domain = serverAddress.text
        .substring(0, serverAddress.text.lastIndexOf(port) - 1);
    components.loading.screen(
      message: 'Connecting',
      playCount: 1,
      then: () async {
        await services.client.saveElectrumAddress(
          domain: domain,
          port: int.parse(port),
        );
        // flush out current connection and allow waiter to reestablish one
        await services.client.createClient();
      },
      returnHome: true,
    );
    pressed = true;
  }
}
