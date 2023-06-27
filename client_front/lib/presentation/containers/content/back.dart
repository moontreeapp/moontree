import 'package:client_front/presentation/pages/manage/back/holding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/application/containers/back/cubit.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/containers/back/menu.dart';
import 'package:client_front/presentation/pages/wallet/back/holding.dart';
import 'package:client_front/presentation/pages/wallet/back/send.dart';
import 'package:client_front/presentation/widgets/other/fading.dart';

class BackContainer extends StatelessWidget {
  const BackContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<BackContainerCubit,
          BackContainerCubitState>(
      builder: (context, state) => Container(
          width: MediaQuery.of(context).size.width,
          color: AppColors.primary,
          height: state.height,
          alignment: Alignment.topCenter,
          child: state.path.startsWith('/menu')
              ? Menu(path: state.path, prior: state.priorPath)
              : state.path.endsWith('/send/coinspec')
                  ? FadeIn(child: BackSendScreen())
                  : state.path == '/manage/holding/coinspec'
                      ? FadeIn(child: BackManageHoldingScreen())
                      : state.path.endsWith('/coinspec')
                          ? FadeIn(child: BackHoldingScreen())
                          : SizedBox.shrink()
          //AnimatedSwitcher(
          //  duration: animation.fadeDuration,
          //  transitionBuilder: (Widget child, Animation<double> animation) =>
          //      FadeTransition(
          //          opacity: animation.drive(Tween<double>(begin: 0, end: 1)
          //              .chain(CurveTween(curve: Curves.easeInOutCubic))),
          //          child: child),
          //  child: state.child,
          //)),
          ));
}
