import 'package:client_front/presentation/widgets/other/sliding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/application/snackbar/cubit.dart';
import 'package:client_front/presentation/utils/animation.dart';
import 'package:client_front/presentation/widgets/front_curve.dart'
    show FrontCurve;
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/presentation/components/shadows.dart' as shadows;
import 'package:client_front/presentation/services/services.dart' show screen;

class SnackbarLayer extends StatefulWidget {
  const SnackbarLayer({Key? key}) : super(key: key);

  @override
  SnackbarLayerState createState() => SnackbarLayerState();
}

class SnackbarLayerState extends State<SnackbarLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late SnackbarCubit cubit;

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
      BlocBuilder<SnackbarCubit, SnackbarCubitState>(
          builder: (BuildContext context, SnackbarCubitState state) {
        final percent =
            components.cubits.navbar.state.height / screen.app.height;
        print(percent);
        if (state.snack != null) {
          return SlideUp(
              heightPercentage: percent + .06,
              child: GestureDetector(
                  onTap: components.cubits.snackbar.clear,
                  behavior: HitTestBehavior.opaque,
                  child: FrontCurve(
                      fuzzyTop: false,
                      frontLayerBoxShadow: shadows.snackbar,
                      color: const Color(0xFF000000),
                      child: Text(state.snack?.message ?? 'message'))));
        }
        if (state.prior != null)
          return SlideUp(
              enter: false,
              heightPercentage: percent + .06,
              child: GestureDetector(
                  onTap: components.cubits.snackbar.clear,
                  behavior: HitTestBehavior.opaque,
                  child: FrontCurve(
                      fuzzyTop: false,
                      color: const Color(0xFF000000),
                      child: Text(state.prior?.message ?? 'message'))));
        return SizedBox.shrink();
      });
}
