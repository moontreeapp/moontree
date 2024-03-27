import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/appbar/cubit.dart';
import 'package:moontree/presentation/theme/theme.dart';
import 'package:moontree/services/services.dart' show screen;

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
            ConnectionIndicator(),
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

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AppbarCubit, AppbarState>(
      buildWhen: (AppbarState previous, AppbarState current) =>
          previous.leading != current.leading,
      builder: (context, state) {
        if (state.leading == AppbarLeading.connection) {
          return Container(
              height: 16 + screen.iconMedium + 16,
              width: 24 + screen.iconMedium + 24,
              alignment: Alignment.center,
              child: Container(
                  height: screen.iconMedium,
                  width: screen.iconMedium,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.wifi,
                      color: Colors.green, size: screen.iconMedium)));
        }
        if (state.leading == AppbarLeading.back) {
          return Container(
              height: 16 + screen.iconMedium + 16,
              width: 24 + screen.iconMedium + 24,
              alignment: Alignment.center,
              child: Container(
                  height: screen.iconMedium,
                  width: screen.iconMedium,
                  alignment: Alignment.center,
                  child: Icon(Icons.chevron_left_rounded,
                      color: Colors.white, size: screen.iconMedium)));
        }
        if (state.leading == AppbarLeading.close) {
          return Container(
              height: 16 + screen.iconMedium + 16,
              width: 24 + screen.iconMedium + 24,
              alignment: Alignment.center,
              child: Container(
                  height: screen.iconMedium,
                  width: screen.iconMedium,
                  alignment: Alignment.center,
                  child: Icon(Icons.close_rounded,
                      color: Colors.white, size: screen.iconMedium)));
        }
        return SizedBox(
          height: 16 + screen.iconMedium + 16,
        );
      });
}

class Title extends StatelessWidget {
  const Title({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AppbarCubit, AppbarState>(
      buildWhen: (AppbarState previous, AppbarState current) =>
          previous.title != current.title,
      builder: (context, state) => Container(
          height: screen.appbar.height,
          width: screen.width - (24 + screen.iconMedium + 24) - 16,
          alignment: Alignment.centerLeft,
          child: Text(state.title,
              style: Theme.of(context)
                  .textTheme
                  .sub1
                  .copyWith(color: Colors.white))));
}
