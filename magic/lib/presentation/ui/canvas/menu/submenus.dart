import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/presentation/theme/text.dart';
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
          current.active && (previous.setting != current.setting),
      builder: (context, state) => GestureDetector(
          onTap: cubits.menu.toggleSetting,
          child: Container(
              height: screen.menu.itemHeight,
              color: Colors.transparent,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Icon(
                    state.setting
                        ? Icons.notifications_on_rounded
                        : Icons.notifications_off_rounded,
                    color: Colors.white),
                const SizedBox(width: 16),
                Text('Notification: ${state.setting ? 'On' : 'Off'}',
                    style: AppText.h2.copyWith(color: Colors.white)),
              ]))));

  //Text('Some Setting', style: AppText.h1.copyWith(color: Colors.white));
}

class AboutSubMenu extends StatelessWidget {
  const AboutSubMenu({super.key});

  @override
  Widget build(BuildContext context) => Text('built by Moontree',
      textAlign: TextAlign.center,
      style: AppText.h1.copyWith(color: Colors.white));
}
