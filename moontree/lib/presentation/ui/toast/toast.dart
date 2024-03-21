import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moontree/cubits/toast/cubit.dart';
import 'package:moontree/presentation/widgets/assets/icons.dart';
import 'package:moontree/presentation/widgets/assets/shadows.dart';
import 'package:moontree/services/services.dart' show screen;
import 'package:moontree/presentation/theme/colors.dart';
import 'package:moontree/presentation/theme/extensions.dart';
import 'package:moontree/presentation/theme/fonts.dart';
import 'package:moontree/presentation/utils/animation.dart';
import 'package:moontree/presentation/widgets/animations/fading.dart';

class ToastLayer extends StatelessWidget {
  const ToastLayer({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<ToastCubit, ToastState>(
      buildWhen: (ToastState previous, ToastState current) =>
          previous.msg != current.msg || previous.showType != current.showType,
      builder: (BuildContext context, ToastState state) {
        if (state.msg != null) {
          final toast = Container(
              padding: const EdgeInsets.all(4.0),
              color: Colors.transparent,
              child: GestureDetector(
                  onTap: state.onTap,
                  child: Container(
                      padding: const EdgeInsets.only(
                          top: 9, bottom: 9, left: 9, right: 16),
                      decoration: BoxDecoration(
                        color: AppColors.textFieldBackground,
                        borderRadius: BorderRadius.circular(100.0),
                        boxShadow: frontLayer,
                      ),
                      child: Row(children: [
                        //SvgPicture.asset(
                        //  moontreeIcons.wonupToastLoc,
                        //  width: 24,
                        //  height: 24,
                        //  //fit: BoxFit.contain,
                        //  alignment: Alignment.center,
                        //),
                        const SizedBox(width: 8),
                        Text(state.msg!.title + ' ',
                            style: Theme.of(context).textTheme.body2!.copyWith(
                                  color: AppColors.black60,
                                  fontWeight: FontWeights.extraBold,
                                )),
                        //const SizedBox(width: 4),
                        Text(
                          state.msg!.text,
                          style: Theme.of(context).textTheme.body2!.copyWith(
                                color: AppColors.black60,
                                height: 0,
                              ),
                        ),
                      ]))));
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
          return Positioned(top: state.height ?? screen.toast, child: show);
        }
        return const SizedBox.shrink();
      });
}
