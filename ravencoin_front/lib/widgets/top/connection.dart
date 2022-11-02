import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/client.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_front/widgets/front/choices/blockchain_choice.dart'
    show produceAssetModal;

class ConnectionLight extends StatefulWidget {
  ConnectionLight({Key? key}) : super(key: key);

  @override
  _ConnectionLightState createState() => _ConnectionLightState();
}

class _ConnectionLightState extends State<ConnectionLight>
    with TickerProviderStateMixin {
  List<StreamSubscription> listeners = [];
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;
  Color connectionStatusColor = AppColors.error;
  Map<ConnectionStatus, Color> connectionColor = {
    ConnectionStatus.connected: AppColors.success,
    ConnectionStatus.connecting: AppColors.yellow,
    ConnectionStatus.disconnected: AppColors.error,
  };
  /* alternative */
  bool connectionBusy = false;
  /* blinking animations */
  //bool busy = false;

  /* fancy movement animations
  bool connectionBusy = false;
  late DateTime startTime;
  final int durationV = 1236;
  final int durationH = 2000;

  late AnimationController _controllerH;
  late AnimationController _controllerV;
  late Animation<Offset> _offsetAnimationH;
  late Animation<Offset> _offsetAnimationV;

  Map<ConnectionStatus, Color> connectionColor = {
    ConnectionStatus.connected: AppColors.success,
    ConnectionStatus.connecting: AppColors.yellow,
    ConnectionStatus.disconnected: AppColors.error,
  };

  void createAnimations() {
    _controllerH = AnimationController(
      duration: Duration(milliseconds: durationH),
      vsync: this,
    );
    _controllerH.value = .5;
    _controllerH.repeat(reverse: true);
    _controllerV = AnimationController(
      duration: Duration(milliseconds: durationV),
      vsync: this,
    );
    _controllerV.value = .5;
    _controllerV.repeat(reverse: true);
    _offsetAnimationH = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controllerH,
      curve: Curves.easeInOut,
    ));
    _offsetAnimationV = Tween<Offset>(
      begin: const Offset(0, -.1),
      end: const Offset(0, .1),
    ).animate(CurvedAnimation(
      parent: _controllerV,
      curve: Curves.easeInOut,
    ));
  }*/

  @override
  void initState() {
    super.initState();
    listeners.add(streams.client.connected.listen((ConnectionStatus value) {
      if (value != connectionStatus) {
        setState(() {
          connectionStatus = value;
          connectionStatusColor = connectionColor[value]!;
        });
      }
    }));
    listeners.add(streams.client.busy.listen((bool value) async {
      if (value != connectionBusy) {
        setState(() => connectionBusy = value);
      }

      /* blinking animations */
      //if (value && !connectionBusy) {
      //  setState(() => connectionBusy = value);
      //  //rebuildMe();
      //}
      //if (!value && connectionBusy) {
      //  setState(() => connectionBusy = value);
      //}
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  /* blinking animations */
  //Future<void> rebuildMe() async {
  //  await Future.delayed(Duration(milliseconds: 600));
  //  if (connectionBusy) {
  //    // don't blink when spinner runs... separate into different streams?
  //    if (!['Login', 'Createlogin'].contains(streams.app.page.value) &&
  //        !services.wallet.leader.newLeaderProcessRunning) {
  //      setState(() => busy = !busy);
  //    }
  //    rebuildMe();
  //  } else {
  //    if (busy) {
  //      setState(() => busy = !busy);
  //    }
  //  }
  //}

  @override
  Widget build(BuildContext context) {
    final circleIcon = AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(20),
      ),
    );
    return GestureDetector(
        onTap: navToBlockchain,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 400),
          alignment: Alignment.center,
          padding: EdgeInsets.zero,
          child: pros.settings.chain == Chain.none
              ? IconButton(
                  splashRadius: 28,
                  padding: EdgeInsets.zero,
                  icon: circleIcon,
                  onPressed: navToBlockchain,
                )
              : Stack(alignment: Alignment.center, children: [
                  ColorFiltered(
                      colorFilter:
                          ColorFilter.mode(statusColor, BlendMode.srcIn),
                      child: components.icons.assetAvatar(
                          chainSymbol(pros.settings.chain),
                          net: pros.settings.net,
                          height: 28,
                          width: 28)),
                  components.icons.assetAvatar(chainSymbol(pros.settings.chain),
                      net: pros.settings.net, height: 24, width: 24),
                ]),
        ));
  }

  Color get statusColor => connectionStatus == ConnectionStatus.connected &&
          connectionBusy // && busy
      ? AppColors.logoGreen
      : connectionStatusColor;

  void navToBlockchain() {
    if (streams.app.scrim.value == true) return;
    if (streams.app.loading.value == true) return;
    if (![
      'Login',
      'Createlogin',
      'Network',
      'Scan',
      'Setup',
    ].contains(streams.app.page.value)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      streams.app.xlead.add(true);
      produceAssetModal(components.navigator.routeContext!);
      //Navigator.of(components.navigator.routeContext!)
      //    .pushNamed('/settings/network/blockchain');
    }
  }
}

class SpoofedConnectionLight extends StatelessWidget {
  SpoofedConnectionLight({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color connectionStatusColor = AppColors.success;
    var icon = ColorFiltered(
        colorFilter: ColorFilter.mode(connectionStatusColor, BlendMode.srcATop),
        child: SvgPicture.asset('assets/status/icon.svg'));
    return IconButton(
      splashRadius: 24,
      padding: EdgeInsets.zero,
      onPressed: () {},
      icon: icon,
    );
  }
}
