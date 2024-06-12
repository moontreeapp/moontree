import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/presentation/theme/text.dart';
import 'package:magic/presentation/ui/canvas/menu/settings.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/animations/fading.dart';
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
                alignment: Alignment.center,
                sub: SubMenu.about,
                child: const AboutSubMenu()),
            SubMenuItem(
                state: state,
                alignment: Alignment.topLeft,
                sub: SubMenu.settings,
                child: SettingsSubMenu(state: state)),
          ]);
}

class SubMenuItem extends StatelessWidget {
  final MenuState state;
  final Alignment alignment;
  final SubMenu sub;
  final Widget child;
  const SubMenuItem({
    super.key,
    required this.state,
    required this.sub,
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
                child: FadeIn(delay: fadeDuration * 4 * .5, child: child)),
          if (state.prior?.sub == sub && state.sub != sub)
            Container(
                width: screen.width - 32,
                alignment: alignment,
                child: FadeOut(child: child)),
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
      builder: (context, state) => Column(children: [
            DifficultyItem(mode: state.mode),
            //NotificationItem(state: state),
            if (cubits.menu.isInDevMode) const BackupItem(),
            if (cubits.menu.isInDevMode) const ImportItem(),
            if (cubits.menu.isInDevMode) const WalletsItem(),
          ]));

  //Text('Some Setting', style: AppText.h1.copyWith(color: Colors.white));
}

class AboutSubMenu extends StatelessWidget {
  const AboutSubMenu({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
      height: screen.canvas.bottomHeight - 40 - 32,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('built by Moontree',
            textAlign: TextAlign.center,
            style: AppText.h1.copyWith(color: Colors.white)),
        Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text('connection status: ${cubits.app.state.connection.name}',
              textAlign: TextAlign.center,
              style: AppText.body2.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text('version 0.0.1',
              textAlign: TextAlign.center,
              style: AppText.body2.copyWith(color: Colors.white)),
          const SizedBox(height: 32),
        ])
      ]));
}
