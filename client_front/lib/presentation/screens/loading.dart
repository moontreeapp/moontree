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
import 'package:client_front/presentation/components/components.dart';
import 'package:lottie/lottie.dart';

class LoadingLayer extends StatefulWidget {
  const LoadingLayer({Key? key}) : super(key: key);

  @override
  LoadingLayerState createState() => LoadingLayerState();
}

class LoadingLayerState extends State<LoadingLayer> {
  Color scrimColor = Colors.transparent;
  HitTestBehavior? behavior = null;
  double? height = 0;
  void Function()? onEnd = null;
  void Function()? onTap = null;

  @override
  void initState() {
    super.initState();
    onEnd = () => setState(() => height = 0);
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
    //print(streams.app.page.value);
    if (['Splash', 'Login'].contains(streams.app.page.value)) {
      return SizedBox.shrink();
    }

    final LoadingViewCubit cubit = BlocProvider.of<LoadingViewCubit>(context);
    //components.cubits.loadingViewCubit; //
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: BlocBuilder<LoadingViewCubit, LoadingViewState>(
            //bloc: cubit..enter(),
            builder: (BuildContext context, LoadingViewState state) {
          if (cubit.shouldShow) {
            activateScrim();
          }
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            onEnd: onEnd,
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

  void activateScrim() {
    setState(() {
      scrimColor = AppColors.scrimLight;
      behavior = HitTestBehavior.opaque;
      height = null;
      onEnd = null;
      onTap = removeScrim;
    });
  }

  void removeScrim() {
    components.cubits.loadingViewCubit.set(status: LoadingStatus.none);
    setState(() {
      scrimColor = Colors.transparent;
      behavior = null;
      onEnd = () => setState(() => height = 0);
      onTap = null;
    });
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
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.headline1),
            Text(msg ?? '', style: Theme.of(context).textTheme.bodyText1),
          ],
        )
      ],
    );
  }
}
