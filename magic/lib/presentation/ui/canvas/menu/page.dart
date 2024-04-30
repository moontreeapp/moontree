import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/domain/concepts/consent.dart';
import 'package:magic/presentation/theme/theme.dart';
import 'package:magic/presentation/ui/canvas/menu/submenus.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/animations/animations.dart';
import 'package:magic/services/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) => Container(
      width: screen.width,
      height: screen.height,
      //
      alignment: Alignment.topCenter,
      child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16),
          width: screen.width,
          //height: screen.canvas.bottomHeight,
          height: screen.canvas.maxHeight,
          alignment: Alignment.center,
          child: const AnimatedMenu()));
}

class AnimatedMenu extends StatelessWidget {
  const AnimatedMenu({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<MenuCubit, MenuState>(
      buildWhen: (MenuState previous, MenuState current) =>
          current.active &&
          (previous.faded != current.faded ||
              previous.mode != current.mode ||
              previous.sub != current.sub),
      builder: (context, state) => AnimatedOpacity(
          duration: fadeDuration,
          curve: Curves.easeInOutCubic,
          opacity: state.faded ? .12 : 1,
          child: Stack(children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SubMenus(state: state),
                  const LegalLinks(),
                ]),
            const HelpItem(),
            DifficultyItem(mode: state.mode),
            const SettingsItem(),
            const AboutItem(),
          ])));
}

class HelpItem extends StatelessWidget {
  const HelpItem({super.key});

  @override
  Widget build(BuildContext context) => MenuItem(
        sub: SubMenu.help,
        index: 0,
        visual: GestureDetector(
            onTap: () => launchUrl(Uri.parse('https://discord.gg/cGDebEXgpW')),
            child: Container(
                height: screen.menu.itemHeight,
                width: screen.width,
                color: Colors.transparent,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  const Icon(Icons.help_rounded, color: Colors.white),
                  const SizedBox(width: 16),
                  Text('Need Help? Chat Now!',
                      style: AppText.h2.copyWith(color: Colors.white)),
                ]))),
      );
}

class DifficultyItem extends StatelessWidget {
  final DifficultyMode mode;
  const DifficultyItem({super.key, required this.mode});

  @override
  Widget build(BuildContext context) => MenuItem(
        sub: SubMenu.mode,
        index: 1,
        visual: GestureDetector(
            onTap: cubits.menu.toggleDifficulty,
            child: Container(
                height: screen.menu.itemHeight,
                width: screen.width,
                color: Colors.transparent,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Icon(mode.icon, color: Colors.white),
                  const SizedBox(width: 16),
                  Text('Mode: ${mode.name}',
                      style: AppText.h2.copyWith(color: Colors.white)),
                ]))),
      );
}

class SettingsItem extends StatelessWidget {
  const SettingsItem({super.key});

  @override
  Widget build(BuildContext context) => MenuItem(
      sub: SubMenu.settings,
      index: 2,
      visual: Container(
          height: screen.menu.itemHeight,
          width: screen.width,
          color: Colors.transparent,
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            BlocBuilder<MenuCubit, MenuState>(
                buildWhen: (MenuState previous, MenuState current) =>
                    current.active && previous.sub != current.sub,
                builder: (context, state) {
                  const icon =
                      Icon(Icons.settings_rounded, color: Colors.white);
                  if (cubits.menu.state.sub == SubMenu.settings) {
                    return SlideOver(
                        begin: const Offset(0, 0),
                        end: const Offset(-3, 0),
                        delay: fadeDuration * (2 - 1) * .5,
                        duration: fadeDuration,
                        curve: Curves.easeInOutCubic,
                        child: icon);
                  }
                  if (cubits.menu.state.sub == SubMenu.none) {
                    return SlideOver(
                        begin: const Offset(-3, 0),
                        end: const Offset(0, 0),
                        delay: fadeDuration * (2 - 1) * .5,
                        duration: fadeDuration,
                        curve: Curves.easeInOutCubic,
                        child: icon);
                  }
                  return icon;
                }),
            const SizedBox(width: 16),
            Text('Settings', style: AppText.h2.copyWith(color: Colors.white)),
          ])));
}

class AboutItem extends StatelessWidget {
  const AboutItem({super.key});

  @override
  Widget build(BuildContext context) => MenuItem(
      sub: SubMenu.about,
      index: 3,
      visual: Container(
          height: screen.menu.itemHeight,
          width: screen.width,
          color: Colors.transparent,
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            BlocBuilder<MenuCubit, MenuState>(
                buildWhen: (MenuState previous, MenuState current) =>
                    current.active && previous.sub != current.sub,
                builder: (context, state) {
                  const icon = Icon(Icons.info_rounded, color: Colors.white);
                  if (cubits.menu.state.sub == SubMenu.about) {
                    return SlideOver(
                        begin: const Offset(0, 0),
                        end: const Offset(-3, 0),
                        delay: fadeDuration * (3 - 1) * .5,
                        duration: fadeDuration,
                        curve: Curves.easeInOutCubic,
                        child: icon);
                  }
                  if (cubits.menu.state.sub == SubMenu.none) {
                    return SlideOver(
                        begin: const Offset(-3, 0),
                        end: const Offset(0, 0),
                        delay: fadeDuration * (3 - 1) * .5,
                        duration: fadeDuration,
                        curve: Curves.easeInOutCubic,
                        child: icon);
                  }
                  return icon;
                }),
            const SizedBox(width: 16),
            Text('About', style: AppText.h2.copyWith(color: Colors.white)),
          ])));
}

class MenuItem extends StatelessWidget {
  final SubMenu sub;
  final int index;
  final Widget? onMenu;
  final Widget? onChosen;
  final Widget? onUnchosen;
  final Widget? onNotChosen;
  final Widget? onWasNotChosen;
  final Widget? onElse;
  final Widget? visual;

  const MenuItem({
    super.key,
    required this.sub,
    required this.index,
    this.onMenu,
    this.onChosen,
    this.onUnchosen,
    this.onNotChosen,
    this.onWasNotChosen,
    this.onElse,
    this.visual,
  });

  @override
  Widget build(BuildContext context) => BlocBuilder<MenuCubit, MenuState>(
      buildWhen: (MenuState previous, MenuState current) =>
          current.active && previous.sub != current.sub,
      builder: (context, state) {
        final padding = EdgeInsets.only(
            top: screen.appbar.height +
                screen.canvas.midHeight +
                (screen.menu.itemHeight * index));
        if (state.prior?.sub == SubMenu.none && state.sub == SubMenu.none) {
          return onMenu ??
              Padding(
                  padding: padding,
                  child: GestureDetector(
                      onTap: () => maestro.activateSubMenu(sub),
                      child: visual));
        }
        if (state.prior?.sub == SubMenu.none && state.sub == sub) {
          return onChosen ??
              SlideOver(
                  begin: const Offset(0, 0),
                  end: Offset(0, -.866 - ((index - 1) * 0.014)),
                  delay: fadeDuration * index * .5,
                  duration: fadeDuration,
                  curve: Curves.easeInOutCubic,
                  child: Padding(
                      padding: padding,
                      child: GestureDetector(
                          onTap: () => maestro.deactivateSubMenu(),
                          child: GrowingAnimation(
                              begin: 1,
                              end: 1,
                              rebuild: true,
                              reverse: false,
                              curve: Curves.easeInOutCubic,
                              duration: fadeDuration * 1,
                              delay: fadeDuration * index * .5,
                              child: visual))));
        }
        if (state.prior?.sub == sub && state.sub != sub) {
          return onUnchosen ??
              SlideOver(
                  begin: Offset(0, -.866 - ((index - 1) * 0.014)),
                  end: const Offset(0, 0),
                  delay: fadeDuration * .25,
                  child: Padding(
                      padding: padding,
                      child: GrowingAnimation(
                          begin: 1,
                          end: 1,
                          rebuild: true,
                          reverse: true,
                          child: GestureDetector(
                              onTap: () => maestro.activateSubMenu(sub),
                              child: visual))));
        }
        if (state.prior?.sub == SubMenu.none && state.sub != sub) {
          return onNotChosen ??
              SlideOver(
                  begin: const Offset(0, 0),
                  end: const Offset(-1, 0),
                  delay: fadeDuration * index * .25,
                  child: Padding(padding: padding, child: visual));
        }
        if (state.prior?.sub != sub && state.sub == SubMenu.none) {
          return onWasNotChosen ??
              SlideOver(
                  begin: const Offset(-1, 0),
                  end: const Offset(0, 0),
                  delay: (fadeDuration * 1) + (fadeDuration * index * .25),
                  child: Padding(
                      padding: padding,
                      child: GestureDetector(
                          onTap: () => maestro.activateSubMenu(sub),
                          child: visual)));
        }
        return onElse ??
            Padding(
                padding: padding,
                child: GestureDetector(
                    onTap: () => maestro.activateSubMenu(sub), child: visual));
      });
}

class LegalLinks extends StatelessWidget {
  const LegalLinks({super.key});

  @override
  Widget build(BuildContext context) => Column(children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppText.body2.copyWith(color: Colors.white60),
            children: <TextSpan>[
              TextSpan(
                  text: 'User Agreement',
                  style: AppText.underlinedLink(AppText.body2),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Uri.parse(
                          documentEndpoint(ConsentDocument.userAgreement)));
                    }),
              const TextSpan(text: '   '),
              TextSpan(
                  text: 'Privacy Policy',
                  style: AppText.underlinedLink(AppText.body2),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Uri.parse(
                          documentEndpoint(ConsentDocument.privacyPolicy)));
                    }),
              const TextSpan(text: '   '),
              TextSpan(
                  text: 'Risk Disclosure',
                  style: AppText.underlinedLink(AppText.body2),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Uri.parse(
                          documentEndpoint(ConsentDocument.riskDisclosures)));
                    }),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ]);
}
