import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/application/layers/loading/cubit.dart';
import 'package:client_front/presentation/utils/animation.dart';
import 'package:client_front/presentation/services/services.dart' as uiservices;
import 'package:client_front/presentation/widgets/front_curve.dart'
    show FrontCurve;
import 'package:lottie/lottie.dart';

class LoadingLayer extends StatefulWidget {
  const LoadingLayer({Key? key}) : super(key: key);

  @override
  LoadingLayerState createState() => LoadingLayerState();
}

class LoadingLayerState extends State<LoadingLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late LoadingViewCubit cubit;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: slideDuration,
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<LoadingViewCubit, LoadingViewState>(
          //bloc: cubit..enter(),
          builder: (BuildContext context, LoadingViewState state) {
        cubit = BlocProvider.of<LoadingViewCubit>(context);
        if (cubit.shouldShow) {
          animationController.reverse();
        } else {
          animationController.forward();
        }
        return AnimatedBuilder(
          animation: animationController,
          builder: (BuildContext context, Widget? child) {
            return Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.translationValues(
                    0,
                    cubit.moving
                        ? (uiservices.screen.app.height +
                                uiservices.screen.app.systemStatusBarHeight) *
                            animationController.value
                        : cubit.hidden
                            ? (uiservices.screen.app.height +
                                uiservices.screen.app.systemStatusBarHeight)
                            : 0,
                    0),
                child: GestureDetector(
                  /* for testing - remove onTap later */
                  //onTap: cubit.hide,
                  behavior: HitTestBehavior.opaque,
                  child: LoadingContent(
                      title: state.title ?? 'Loading',
                      msg: state.msg ?? 'Please wait',
                      scrim: const Color(0xFFFFFFFF)
                      //.withOpacity(1 - .12),
                      ),
                ));
          },
        );
      });
}

class LoadingContent extends StatelessWidget {
  final String title;
  final String? msg;
  final Color scrim;
  const LoadingContent({
    Key? key,
    required this.title,
    this.msg,
    required this.scrim,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => FrontCurve(
      fuzzyTop: false,
      frontLayerBoxShadow: const <BoxShadow>[],
      color: scrim,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 32),
            if (msg != null)
              Text(msg!, style: Theme.of(context).textTheme.displayMedium),
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
