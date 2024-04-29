import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magic/cubits/appbar/cubit.dart';
import 'package:magic/presentation/theme/theme.dart';
import 'package:magic/presentation/widgets/assets/icons.dart';
import 'package:magic/services/services.dart' show screen;

class AppbarHeader extends StatelessWidget {
  const AppbarHeader({super.key});

  @override
  Widget build(BuildContext context) => Container(
      height: screen.appbar.height,
      width: screen.width,
      alignment: Alignment.center,
      //padding: const EdgeInsets.only(left: 24, top: 16.0, right: 24),
      child: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Leading(),
            Title(),
            //GestureDetector(
            //    //onTap: () => cubits.fade.update(fade: FadeEvent.fadeOut),
            //    //onTap: () => cubits.pane.update(height: screen.pane.minHeight),
            //    //onTap: () => cubits.pane.update(max: .8),
            //    child: Text('menu',
            //        style: Theme.of(context)
            //            .textTheme
            //            .h2!
            //            .copyWith(color: Colors.white, shadows: [
            //          const Shadow(
            //              offset: Offset(1.0, 1.0),
            //              blurRadius: 1.0,
            //              color: Color.fromRGBO(0, 0, 0, 0.50))
            //        ]))),
            //GestureDetector(
            //    onTap: () => cubits.fade.update(fade: FadeEvent.fadeIn),
            //    //onTap: () => cubits.pane.update(height: screen.pane.midHeight),
            //    child: Text('title',
            //        style: Theme.of(context)
            //            .textTheme
            //            .h2!
            //            .copyWith(color: Colors.white, shadows: [
            //          const Shadow(
            //              offset: Offset(1.0, 1.0),
            //              blurRadius: 1.0,
            //              color: Color.fromRGBO(0, 0, 0, 0.50))
            //        ]))),
            //GestureDetector(
            //    onTap: () => cubits.pane.update(height: screen.pane.maxHeight),
            //    child: Text('icons',
            //        style: Theme.of(context)
            //            .textTheme
            //            .h2!
            //            .copyWith(color: Colors.white, shadows: [
            //          const Shadow(
            //              offset: Offset(1.0, 1.0),
            //              blurRadius: 1.0,
            //              color: Color.fromRGBO(0, 0, 0, 0.50))
            //        ]))),
          ]));
}

class Leading extends StatelessWidget {
  const Leading({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AppbarCubit, AppbarState>(
      buildWhen: (AppbarState previous, AppbarState current) =>
          previous.leading != current.leading ||
          previous.onLead != current.onLead,
      builder: (context, state) {
        return GestureDetector(
            onTap: state.onLead,
            child: Container(
                height: 16 + screen.iconMedium + 16,
                width: 24 + screen.iconMedium,
                alignment: Alignment.centerRight,
                color: Colors.transparent,
                child: () {
                  if (state.leading == AppbarLeading.menu) {
                    return Icon(Icons.menu_rounded,
                        color: Colors.white, size: screen.iconMedium);
                    //Container(
                    //    height: screen.iconMedium,
                    //    width: screen.iconMedium,
                    //    alignment: Alignment.center,
                    //    decoration: BoxDecoration(
                    //        color: Colors.green,
                    //        borderRadius: BorderRadius.circular(8)),
                    //    child: Icon(Icons.wifi,
                    //        color: Colors.green, size: screen.iconMedium)));
                  }
                  if (state.leading == AppbarLeading.back) {
                    return Container(
                        height: screen.iconMedium,
                        width: screen.iconMedium,
                        alignment: Alignment.center,
                        child: Icon(Icons.chevron_left_rounded,
                            color: Colors.white, size: screen.iconMedium));
                  }
                  if (state.leading == AppbarLeading.close) {
                    return Container(
                        height: screen.iconMedium,
                        width: screen.iconMedium,
                        alignment: Alignment.center,
                        child: Icon(Icons.close_rounded,
                            color: Colors.white, size: screen.iconMedium));
                  }
                  return const SizedBox.shrink();
                }()));
      });
}

class Title extends StatelessWidget {
  const Title({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AppbarCubit, AppbarState>(
      buildWhen: (AppbarState previous, AppbarState current) =>
          previous.title != current.title ||
          previous.onTitle != current.onTitle,
      builder: (context, state) => GestureDetector(
          onTap: state.onTitle,
          child: Container(
              height: screen.appbar.height,
              width: screen.width - (24 + screen.iconMedium + 24) - 16,
              alignment: Alignment.centerLeft,
              color: Colors.transparent,
              child: state.title == 'Magic'
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8, top: 8.0),
                      child: SvgPicture.asset(
                        LogoIcons.magic,
                        height: screen.appbar.logoHeight,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ))
                  : Padding(
                      padding: const EdgeInsets.only(left: 24, top: 8.0),
                      child: Text(state.title,
                          style: Theme.of(context)
                              .textTheme
                              .sub1
                              .copyWith(color: Colors.white))))));
}
