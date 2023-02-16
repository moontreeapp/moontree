import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/application/loadingv2/cubit.dart';
import 'package:client_front/presentation/utilities/animation.dart';
import 'package:client_front/presentation/services/services.dart' as uiservices;

class LoadingLayerv2 extends StatefulWidget {
  const LoadingLayerv2({Key? key}) : super(key: key);

  @override
  LoadingLayerState createState() => LoadingLayerState();
}

class LoadingLayerState extends State<LoadingLayerv2>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late LoadingViewCubitv2 cubit;

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
      BlocBuilder<LoadingViewCubitv2, LoadingViewStatev2>(
          //bloc: cubit..enter(),
          builder: (BuildContext context, LoadingViewStatev2 state) {
        cubit = BlocProvider.of<LoadingViewCubitv2>(context);
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
                  onTap: cubit.hide,
                  behavior: HitTestBehavior.opaque,
                  child: LoadingContent(
                    title: 'Loading',
                    msg: 'Please wait',
                    scrim: const Color(0xFFFFFFFF).withOpacity(1 - .12),
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
  Widget build(BuildContext context) => Container(
      width: MediaQuery.of(context).size.width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scrim,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
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
            Text(
              'assets/logo/moontree_logo.png',
              style: Theme.of(context).textTheme.headline2,
            ),
            //Image.asset(
            //  'assets/logo/moontree_logo.png',
            //  height: 56,
            //  width: 56,
            //)
          ]));
}
