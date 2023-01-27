import 'dart:async';

import 'package:client_front/application/cubits.dart';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/widgets/top/connection.dart';
import 'package:client_front/presentation/widgets/other/speech_bubble.dart';
import 'package:client_front/presentation/widgets/other/other.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/presentation/components/components.dart';

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
    //print(streams.app.page.value);
    if (['Splash', 'Login'].contains(streams.app.page.value)) {
      return SizedBox.shrink();
    }

    final LoadingViewCubit cubit = BlocProvider.of<LoadingViewCubit>(context);
    //components.cubits.loadingViewCubit; //
    if (cubit.state.status == LoadingStatus.busy) {
      activateScrim();
    }
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: BlocBuilder<LoadingViewCubit, LoadingViewState>(
            //bloc: cubit..enter(),
            builder: (BuildContext context, LoadingViewState state) {
          if (cubit.shouldShow) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              onEnd: onEnd,
              height: height,
              color: scrimColor,
              child: GestureDetector(
                onTap: onTap,
                behavior: behavior,
                child: LoadingContent(title: 'Loading', msg: null),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }));
  }

  void activateScrim() {
    setState(() {
      scrimColor = AppColors.scrim;
      behavior = HitTestBehavior.opaque;
      height = null;
      onEnd = null;
      onTap = removeScrim;
    });
  }

  void removeScrim() {
    streams.app.tutorial.add(null);
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
  const LoadingContent({
    Key? key,
    required this.title,
    this.msg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Text('Tap to switch Blockchains',
          style: Theme.of(context).textTheme.bodyText1),
    ]);
  }
}
