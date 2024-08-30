import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/presentation/theme/text.dart';
//import 'package:magic/presentation/widgets/assets/shadows.dart';
import 'package:magic/services/services.dart' show screen;
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/theme/extensions.dart';
import 'package:magic/presentation/theme/fonts.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/animations/fading.dart';

class ToastLayer extends StatelessWidget {
  const ToastLayer({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<ToastCubit, ToastState>(
      buildWhen: (ToastState previous, ToastState current) =>
          previous.msg != current.msg || previous.showType != current.showType,
      builder: (BuildContext context, ToastState state) {
        if (state.msg != null) {
          final content = ToastContent(state: state);
          final toast = Container(
              padding: const EdgeInsets.all(4.0),
              color: Colors.transparent,
              child: GestureDetector(
                  onTap: state.onTap,
                  child: Container(
                      padding: const EdgeInsets.only(
                          top: 9, bottom: 9, left: 9, right: 16),
                      decoration: BoxDecoration(
                        color: AppColors.toast,
                        borderRadius: BorderRadius.circular(100.0),
                        //boxShadow: frontLayer,
                      ),
                      child: Visibility(
                          visible: false,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Row(children: [
                            //SvgPicture.asset(
                            //  moontreeIcons.wonupToastLoc,
                            //  width: 24,
                            //  height: 24,
                            //  //fit: BoxFit.contain,
                            //  alignment: Alignment.center,
                            //),
                            const SizedBox(width: 8),
                            Text('${state.msg!.title} ',
                                style: AppText.toastTitle),
                            //const SizedBox(width: 4),
                            Text(state.msg!.text, style: AppText.toastText),
                          ])))));
          late Widget showBackground;
          late Widget showContent;
          if (state.showType == ToastShowType.normal) {
            showBackground = FadeOut(
                refade: true,
                delay: (state.msg?.duration ?? state.duration) + fadeDuration,
                child: FadeIn(
                  refade: true,
                  duration: fadeDuration,
                  child: toast,
                ));
            showContent = FadeOut(
                refade: true,
                delay: (state.msg?.duration ?? state.duration) +
                    fadeDuration +
                    fadeDuration,
                child: FadeIn(
                  refade: true,
                  duration: fadeDuration,
                  child: content,
                ));
          } else if (state.showType == ToastShowType.fadeAway) {
            showBackground = FadeOut(
              refade: true,
              child: toast,
            );
            showContent = FadeOut(
              refade: true,
              child: content,
            );
          }
          return Stack(alignment: Alignment.topCenter, children: [
            Positioned(
                top: state.height ?? screen.toast, child: showBackground),
            Positioned(top: state.height ?? screen.toast, child: showContent),
          ]);
        }
        return const SizedBox.shrink();
      });
}

class ToastContent extends StatelessWidget {
  final ToastState state;
  const ToastContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final toast = Container(
        padding: const EdgeInsets.all(4.0),
        color: Colors.transparent,
        child: Container(
            padding:
                const EdgeInsets.only(top: 9, bottom: 9, left: 9, right: 16),
            child: Row(children: [
              //SvgPicture.asset(
              //  moontreeIcons.wonupToastLoc,
              //  width: 24,
              //  height: 24,
              //  //fit: BoxFit.contain,
              //  alignment: Alignment.center,
              //),
              const SizedBox(width: 8),
              Text('${state.msg!.title} ', style: AppText.toastTitle),
              //const SizedBox(width: 4),
              Text(state.msg!.text, style: AppText.toastText),
            ])));
    late Widget show;
    if (state.showType == ToastShowType.normal) {
      show = FadeOut(
          refade: true,
          delay: (state.msg?.duration ?? state.duration) + fadeDuration,
          child: FadeIn(
            refade: true,
            duration: fadeDuration,
            child: toast,
          ));
    } else if (state.showType == ToastShowType.fadeAway) {
      show = FadeOut(
        refade: true,
        child: toast,
      );
    }
    return show;
  }
}
