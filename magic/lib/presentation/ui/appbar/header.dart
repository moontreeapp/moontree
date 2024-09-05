import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magic/cubits/app/cubit.dart';
import 'package:magic/cubits/appbar/cubit.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/domain/server/serverv2_client.dart';
import 'package:magic/presentation/theme/theme.dart';
import 'package:magic/presentation/ui/appbar/scanner.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/animations/animations.dart';
import 'package:magic/presentation/widgets/assets/icons.dart';
import 'package:magic/services/services.dart' show screen;
import 'package:magic/utils/log.dart';

class AppbarHeader extends StatelessWidget {
  const AppbarHeader({super.key});

  @override
  Widget build(BuildContext context) => Container(
      height: (Platform.isIOS ? screen.appbar.statusBarHeight : 0) +
          screen.appbar.height,
      alignment: Alignment.bottomCenter,
      child: Container(
          height: screen.appbar.height,
          width: screen.width,
          alignment: Alignment.center,
          //padding: const EdgeInsets.only(left: 24, top: 16.0, right: 24),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Leading(),
                const Expanded(child: Title()),
                //AppLifecycleReactor(),
                const AppActivityWatcher(),
                const ConnectionIndicator(),
                if (!Platform.isIOS) const Scanner(),

                //GestureDetector(
                //    //onTap: () => cubits.fade.update(fade: FadeEvent.fadeOut),
                //    //onTap: () => cubits.pane.update(height: screen.pane.minHeight),
                //    //onTap: () => cubits.pane.update(max: .8),
                //    child: Text('menu',
                //        style: Theme.of(context)
                //            .textTheme
                //            .h2!
                //            .copyWith(color: Colors.white, shadows: [
                //          const Shadow(
                //              offset: Offset(1.0, 1.0),
                //              blurRadius: 1.0,
                //              color: Color.fromRGBO(0, 0, 0, 0.50))
                //        ]))),
                //GestureDetector(
                //    onTap: () => cubits.fade.update(fade: FadeEvent.fadeIn),
                //    //onTap: () => cubits.pane.update(height: screen.pane.midHeight),
                //    child: Text('title',
                //        style: Theme.of(context)
                //            .textTheme
                //            .h2!
                //            .copyWith(color: Colors.white, shadows: [
                //          const Shadow(
                //              offset: Offset(1.0, 1.0),
                //              blurRadius: 1.0,
                //              color: Color.fromRGBO(0, 0, 0, 0.50))
                //        ]))),
                //GestureDetector(
                //    onTap: () => cubits.pane.update(height: screen.pane.maxHeight),
                //    child: Text('icons',
                //        style: Theme.of(context)
                //            .textTheme
                //            .h2!
                //            .copyWith(color: Colors.white, shadows: [
                //          const Shadow(
                //              offset: Offset(1.0, 1.0),
                //              blurRadius: 1.0,
                //              color: Color.fromRGBO(0, 0, 0, 0.50))
                //        ]))),
              ])));
}

class Leading extends StatelessWidget {
  const Leading({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AppbarCubit, AppbarState>(
      buildWhen: (AppbarState previous, AppbarState current) =>
          previous.leading != current.leading ||
          previous.onLead != current.onLead,
      builder: (context, state) {
        return GestureDetector(
            onTap: state.onLead,
            child: Container(
                height: 16 + screen.iconMedium + 16,
                width: 24 + screen.iconMedium,
                alignment: Alignment.centerRight,
                color: Colors.transparent,
                child: () {
                  if (state.leading == AppbarLeading.menu) {
                    return Icon(Icons.menu_rounded,
                        color: Colors.white, size: screen.iconMedium);
                    //Container(
                    //    height: screen.iconMedium,
                    //    width: screen.iconMedium,
                    //    alignment: Alignment.center,
                    //    decoration: BoxDecoration(
                    //        color: Colors.green,
                    //        borderRadius: BorderRadius.circular(8)),
                    //    child: Icon(Icons.wifi,
                    //        color: Colors.green, size: screen.iconMedium)));
                  }
                  if (state.leading == AppbarLeading.back) {
                    return Container(
                        height: screen.iconMedium,
                        width: screen.iconMedium,
                        alignment: Alignment.center,
                        child: Icon(Icons.chevron_left_rounded,
                            color: Colors.white, size: screen.iconMedium));
                  }
                  if (state.leading == AppbarLeading.close) {
                    return Container(
                        height: screen.iconMedium,
                        width: screen.iconMedium,
                        alignment: Alignment.center,
                        child: Icon(Icons.close_rounded,
                            color: Colors.white, size: screen.iconMedium));
                  }
                  return const SizedBox.shrink();
                }()));
      });
}

class Title extends StatelessWidget {
  const Title({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AppbarCubit, AppbarState>(
      buildWhen: (AppbarState previous, AppbarState current) =>
          previous.title != current.title ||
          previous.onTitle != current.onTitle,
      builder: (context, state) => GestureDetector(
          onTap: state.onTitle,
          child: Container(
              height: screen.appbar.height,
              //width: screen.width - (24 + screen.iconMedium + 24) - 16 - 10,
              alignment: Alignment.centerLeft,
              color: Colors.transparent,
              child: state.title == '' && state.titleChild != null
                  ? state.titleChild
                  : (state.title == 'Magic'
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8, top: 8.0),
                          child: SvgPicture.asset(
                            LogoIcons.magic,
                            height: screen.appbar.logoHeight,
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                          ))
                      : Padding(
                          padding: const EdgeInsets.only(left: 16, top: 2.0),
                          child: Text(state.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .sub1
                                  .copyWith(color: Colors.white)))))));
}

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AppCubit, AppState>(
      buildWhen: (AppState previous, AppState current) =>
          previous.connection != current.connection,
      builder: (context, state) {
        /// Hicons:
        /// status-ok
        /// status-offline
        /// loading - gif
        return GestureDetector(
            onTap: () => cubits.toast.flash(
                    msg: ToastMessage(
                  title: 'connection status:',
                  text: state.connection.name,
                )),
            child: Container(
                height: 16 + screen.iconMedium + 16,
                width: 24 + screen.iconMedium,
                alignment: Alignment.centerLeft,
                color: Colors.transparent,
                child: () {
                  if (state.connection == StreamingConnectionStatus.connected) {
                    return FadeOut(
                        duration: slowFadeDuration * 10,
                        child: SvgPicture.asset(
                          'assets/icons/status-ok.svg',
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                          width: screen.iconMedium,
                        ));
                  }
                  if (state.connection ==
                          StreamingConnectionStatus.waitingToRetry ||
                      state.connection ==
                          StreamingConnectionStatus.connecting) {
                    return Stack(alignment: Alignment.centerLeft, children: [
                      SvgPicture.asset(
                        'assets/icons/status-cloud.svg',
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                        width: screen.iconMedium,
                      ),
                      FadeFlashIcon(
                        assetName: 'assets/icons/status-x.svg',
                        width: screen.iconMedium,
                      ),
                    ]);
                  }
                  if (state.connection ==
                      StreamingConnectionStatus.disconnected) {
                    return SvgPicture.asset(
                      'assets/icons/status-offline.svg',
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      width: screen.iconMedium,
                    );
                  }
                  return const SizedBox.shrink();
                }()));
      });
}

class AppActivityWatcher extends StatelessWidget {
  const AppActivityWatcher({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AppCubit, AppState>(
      buildWhen: (AppState previous, AppState current) =>
          previous.status != current.status,
      builder: (context, state) {
        see('AppActivityWatcher: ${state.status}');
        if (state.status == 'resumed') {
          see('refreshing assets');
          Future.delayed(const Duration(seconds: 1)).then((_) {
            cubits.wallet.populateAssets().then((value) {
              see('refreshing holding');
              if (cubits.holding.state.holding != const Holding.empty() &&
                  cubits.wallet.state.holdings.isNotEmpty) {
                see('refreshing holding ${cubits.holding.state.holding.symbol} ${[
                  for (final x in cubits.wallet.state.holdings) x.symbol
                ]}');
                cubits.holding.update(
                    holding: cubits.wallet
                        .getHoldingFrom(holding: cubits.holding.state.holding));
              }
              if (cubits.transactions.state.active) {
                see('refreshing transactions');
                //cubits.transactions.clearTransactions();
                cubits.transactions.populateAllTransactions(
                    holding: cubits.holding.state.holding);
              }
            });
          });
        }
        return const SizedBox.shrink();
      });
}
