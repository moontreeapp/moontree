import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/application/containers/front/cubit.dart';
import 'package:client_front/presentation/widgets/front_curve.dart';
import 'package:client_front/presentation/utils/animation.dart' as animation;

class FrontContainer extends StatelessWidget {
  final Widget? child;
  const FrontContainer({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<FrontContainerCubit, FrontContainerCubitState>(
          builder: (context, state) => FrontContainerView(
                height: state.height,
                hide: state.hide,
                child: child,
              ));
}

/// broken out so it can be used elsewhere as well
class FrontContainerView extends StatelessWidget {
  final Widget? child;
  final double? height;
  final bool hide;
  const FrontContainerView({
    Key? key,
    this.height,
    this.hide = false,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.bottomCenter,
        child: AnimatedContainer(
          height: height,
          width: MediaQuery.of(context).size.width,
          duration: animation.slideDuration,
          curve: Curves.easeInOutCubic,
          child: Stack(
/* ran into error on ultra small screen
'package:flutter/src/widgets/framework.dart': Failed assertion: line 5472 pos 14: '() {
framework.dart:5472
        // check that it really is our descendant
        Element? ancestor = dependent._parent;
        while (ancestor != this && ancestor != null) {
          ancestor = ancestor._parent;
        }
        return ancestor == this;
      }()': is not true.
*/

            alignment: Alignment.bottomCenter,
            children: [
              if (!hide) FrontCurve(color: Colors.white),
              //AnimatedOpacity(
              //    duration: animation.fadeDuration,
              //    opacity: state.hideContent ? 0.0 : 1.0,
              //    child:
              child ?? SizedBox.shrink()
              //),
            ],
          ),
        ),
      );
}
