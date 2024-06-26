import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/domain/concepts/side.dart';
import 'package:magic/presentation/theme/text.dart';
import 'package:magic/presentation/ui/canvas/menu/settings.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/animations/sliding.dart';
import 'package:magic/services/services.dart';
import 'package:magic/cubits/cubit.dart';

class SubMenus extends StatelessWidget {
  final MenuState state;
  const SubMenus({super.key, required this.state});

  @override
  Widget build(BuildContext context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: screen.appbar.height),
            SizedBox(height: screen.canvas.midHeight),
            SubMenuItem(
                state: state,
                sub: SubMenu.about,
                delay: slideDuration * 1.25,
                alignment: Alignment.center,
                child: const AboutSubMenu()),
            SubMenuItem(
                state: state,
                sub: SubMenu.settings,
                delay: slideDuration * 1,
                alignment: Alignment.topLeft,
                child: SettingsSubMenu(state: state)),
          ]);
}

class SubMenuItem extends StatelessWidget {
  final SubMenu sub;
  final MenuState state;
  final Duration delay;
  final Alignment alignment;
  final Widget child;
  const SubMenuItem({
    super.key,
    required this.state,
    required this.sub,
    required this.delay,
    required this.alignment,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          if (state.prior?.sub != sub && state.sub == sub)
            Container(
                width: screen.width - 32,
                alignment: alignment,
                //child: FadeIn(delay: fadeDuration * 4 * .5, child: child)),
                child: SlideSide(
                    delay: delay,
                    modifier: 32 / screen.width,
                    side: Side.right,
                    enter: true,
                    child: child)),
          if (state.prior?.sub == sub && state.sub != sub)
            Container(
                width: screen.width - 32,
                alignment: alignment,
                //child: FadeOut(child: child)),
                child: SlideSide(
                    side: Side.right,
                    modifier: 32 / screen.width,
                    enter: false,
                    child: child)),
        ],
      );
}

class SettingsSubMenu extends StatelessWidget {
  final MenuState state;

  const SettingsSubMenu({super.key, required this.state});

  @override
  Widget build(BuildContext context) => BlocBuilder<MenuCubit, MenuState>(
      buildWhen: (MenuState previous, MenuState current) =>
          current.active &&
          (previous.setting != current.setting ||
              previous.mode != current.mode),
      builder: (context, state) => SizedBox(
          width: screen.width - 32,
          child: Column(children: [
            DifficultyItem(mode: state.mode),
            //NotificationItem(state: state),
            if (cubits.menu.isInDevMode) const BackupItem(),
            if (cubits.menu.isInDevMode) const ImportItem(),
            if (cubits.menu.isInDevMode) const WalletsItem(),
          ])));

  //Text('Some Setting', style: AppText.h1.copyWith(color: Colors.white));
}

class AboutSubMenu extends StatelessWidget {
  const AboutSubMenu({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
      height: screen.canvas.bottomHeight - 40 - 32,
      width: screen.width - 32,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text('built by Moontree',
                textAlign: TextAlign.center,
                style: AppText.h1.copyWith(color: Colors.white))),
        Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text('connection status: ${cubits.app.state.connection.name}',
              textAlign: TextAlign.center,
              style: AppText.body2.copyWith(color: Colors.white)),
          Text('version 0.0.1',
              textAlign: TextAlign.center,
              style: AppText.body2.copyWith(color: Colors.white)),
        ])
      ]));
}
