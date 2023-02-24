import 'dart:async';

import 'package:client_front/application/cubits.dart';
import 'package:client_front/presentation/widgets/backdrop/curve.dart';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/widgets/top/connection.dart';
import 'package:client_front/presentation/widgets/other/speech_bubble.dart';
import 'package:client_front/presentation/widgets/other/other.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:lottie/lottie.dart';

class LoadingLayerV1 extends StatefulWidget {
  const LoadingLayerV1({Key? key}) : super(key: key);

  @override
  LoadingLayerV1State createState() => LoadingLayerV1State();
}

class LoadingLayerV1State extends State<LoadingLayerV1> {
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];
  Color scrimColor = Colors.transparent;
  HitTestBehavior? behavior;
  double? height = 0;
  bool active = false;
  bool hasBeenActivated = false;
  void Function()? onEnd;
  void Function()? onTap;

  @override
  void initState() {
    super.initState();
    onEnd = () => setState(() => height = 0);

    /// this listener is on this page because the cubit doesn't exist first.
    listeners.add(streams.app.page.listen((String? value) async {
      if (['Splash', 'Login', 'Setup', 'Createlogin'].contains(value)) {
        if (active) {
          setState(() {
            height = 0;
            active = false;
          });
        }
      } else if (!active) {
        setState(() {
          active = true;
          hasBeenActivated = true;
        });
      }
    }));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// cubits aren't initialized until after login because they require access
    /// to the current wallet, etc. so we reference cubits after login.
    /// we will have to add a listener to trigger this on login or sometihng.
    if (!hasBeenActivated && !active) {
      return SizedBox.shrink();
    }

    final LoadingViewCubit cubit = BlocProvider.of<LoadingViewCubit>(context);
    //components.cubits.loadingViewCubit; //
    //WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: BlocBuilder<LoadingViewCubit, LoadingViewState>(
            //bloc: cubit..enter(),
            builder: (BuildContext context, LoadingViewState state) {
          if (cubit.shouldShow) {
            // this conditions allows us to bring back loading after login
            if (streams.app.page.value != 'Login') {
              scrimColor = AppColors.scrimLight;
              behavior = HitTestBehavior.opaque;
              height = MediaQuery.of(context).size.height;
              onTap = removeScrim;
            }
          } else {
            removeScrim();
          }
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: height,
            child: GestureDetector(
              onTap: onTap,
              behavior: behavior,
              child: LoadingContent(
                title: 'Loading',
                msg: null,
                scrim: scrimColor,
              ),
            ),
          );
        }));
  }

  void removeScrim() {
    components.cubits.loadingView.set(status: LoadingStatus.none);
    scrimColor = Colors.transparent;
    behavior = null;
    height = 0;
    onTap = null;
  }
}

class LoadingContent extends StatelessWidget {
  final String title;
  final String? msg;
  final Color? scrim;
  const LoadingContent({
    Key? key,
    required this.title,
    this.msg,
    this.scrim,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FrontCurve(
        fuzzyTop: false,
        frontLayerBoxShadow: const <BoxShadow>[],
        color: scrim ?? AppColors.white87,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.headline2,
              ),
              const SizedBox(height: 16),
              if (msg != null)
                Text(
                  msg!,
                  style: Theme.of(context).textTheme.headline2,
                ),
              const SizedBox(height: 16),
              Lottie.asset(
                'assets/spinner/moontree_spinner_v2_002_1_recolored.json',
                animate: true,
                repeat: true,
                width: 100,
                height: 58.6,
                fit: BoxFit.fitWidth,
              ),
            ]));
  }
}
