import 'dart:async';

import 'package:client_front/presentation/widgets/other/fading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_back/streams/client.dart';
import 'package:client_front/presentation/services/services.dart' show sail;
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/presentation/utils/animation.dart' as animation;
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/widgets/front/choices/blockchain_choice.dart'
    show produceBlockchainModal;

class ConnectionLight extends StatefulWidget {
  const ConnectionLight({Key? key}) : super(key: key);

  @override
  _ConnectionLightState createState() => _ConnectionLightState();
}

class _ConnectionLightState extends State<ConnectionLight>
    with TickerProviderStateMixin {
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;
  Color connectionStatusColor = AppColors.error;
  Map<ConnectionStatus, Color> connectionColor = <ConnectionStatus, Color>{
    ConnectionStatus.connected: AppColors.success,
    ConnectionStatus.connecting: AppColors.yellow,
    ConnectionStatus.disconnected: AppColors.error,
  };
  /* alternative */
  bool connectionBusy = false;
  /* blinking animations */
  //bool busy = false;

  static const Set<String> disabledLocations = {
    '/',
    '/login/create',
    '/login/native',
    '/login/password',
    '/login/create/native',
    '/login/create/password',
    '/backup/intro',
    '/backup/seed',
    '/backup/verify',
    '/backup/keypair',
  };

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
    }));
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AnimatedContainer circleIcon = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(20),
      ),
    );
    return FadeIn(
        duration: animation.slowFadeDuration,
        child: GestureDetector(
          onTap: navToBlockchain,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            alignment: Alignment.center,
            padding: EdgeInsets.zero,
            child: pros.settings.chain == Chain.none
                ? IconButton(
                    splashRadius: 26,
                    padding: EdgeInsets.zero,
                    icon: circleIcon,
                    onPressed: navToBlockchain,
                  )
                : Stack(alignment: Alignment.center, children: <Widget>[
                    ColorFiltered(
                        colorFilter:
                            ColorFilter.mode(statusColor, BlendMode.srcIn),
                        child: components.icons.assetAvatar(
                          pros.settings.chain.symbol,
                          net: pros.settings.net,
                          height: 28,
                          width: 28,
                        )),
                    components.icons.assetAvatar(pros.settings.chain.symbol,
                        net: pros.settings.net, height: 24, width: 24),
                  ]),
          ),
        ));
  }

  Color get statusColor => connectionStatus == ConnectionStatus.connected &&
          connectionBusy // && busy
      ? AppColors.logoGreen
      : connectionStatusColor;

  void navToBlockchain() {
    if (streams.app.scrim.value ?? false) {
      return;
    }
    if (streams.app.loading.value == true) {
      return;
    }
    if (!disabledLocations.contains(sail.latestLocation)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      streams.app.lead.add(LeadIcon.dismiss);
      produceBlockchainModal(context: components.routes.routeContext!);
      //Navigator.of(components.routes.routeContext!)
      //    .pushNamed('/settings/network/blockchain');
    }
  }
}

class SpoofedConnectionLight extends StatelessWidget {
  const SpoofedConnectionLight({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color connectionStatusColor = AppColors.success;
    final ColorFiltered icon = ColorFiltered(
        colorFilter:
            const ColorFilter.mode(connectionStatusColor, BlendMode.srcATop),
        child: SvgPicture.asset('assets/status/icon.svg'));
    return IconButton(
      splashRadius: 24,
      padding: EdgeInsets.zero,
      onPressed: () {},
      icon: icon,
    );
  }
}
