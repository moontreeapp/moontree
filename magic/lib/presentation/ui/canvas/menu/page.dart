import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/domain/concepts/consent.dart';
import 'package:magic/presentation/theme/theme.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/animations/animations.dart';
import 'package:magic/presentation/widgets/animations/sliding.dart';
import 'package:magic/services/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) => Container(
      width: screen.width,
      height: screen.height,
      padding: EdgeInsets.only(top: screen.appbar.height),
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
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: screen.canvas.midHeight),
                      ]),
                  const LegalLinks(),
                ]),
            const HelpItem(),
            DifficultyItem(mode: state.mode),
            const SettingsItem(),
            const AboutItem(),
          ])));
}

class MenuItem extends StatelessWidget {
  final SubMenu sub;
  final int index;
  final Widget? onMenu;
  final Widget? onChosen;
  final Widget? onUnchosen;
  final Widget? onNotChosen;
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
    this.onElse,
    this.visual,
  });

  @override
  Widget build(BuildContext context) => BlocBuilder<MenuCubit, MenuState>(
      buildWhen: (MenuState previous, MenuState current) =>
          current.active && previous.sub != current.sub,
      builder: (context, state) {
        if (state.prior?.sub == SubMenu.none && state.sub == SubMenu.none) {
          return onMenu ??
              Padding(
                  padding: EdgeInsets.only(
                      top: screen.canvas.midHeight +
                          (screen.menu.itemHeight * index)),
                  child: GestureDetector(
                      onTap: () => maestro.activateSubMenu(sub),
                      child: visual));
        }
        if (state.prior?.sub == SubMenu.none && state.sub == sub) {
          return onChosen ??
              SlideOver(
                  begin: const Offset(0, 0),
                  end: const Offset(.5, -.67),
                  delay: fadeDuration * index * .5,
                  duration: fadeDuration,
                  curve: Curves.easeInOutCubic,
                  child: Padding(
                      padding: EdgeInsets.only(
                          top: screen.canvas.midHeight +
                              (screen.menu.itemHeight * index)),
                      child: GestureDetector(
                          onTap: () => maestro.activateSubMenu(sub),
                          child: GrowingAnimation(
                              begin: 1,
                              end: 2,
                              rebuild: true,
                              reverse: false,
                              curve: Curves.easeInOutCubic,
                              duration: fadeDuration * 1,
                              delay: fadeDuration * index * .5,
                              child: visual))));
        }
        if (state.prior?.sub == sub && state.sub != sub) {
          return onUnchosen ??
              FadeOutIn(
                  out: SlideOver(
                      begin: const Offset(.5, -.67),
                      end: const Offset(.5, -.67),
                      child: Padding(
                          padding: EdgeInsets.only(
                              top: screen.canvas.midHeight +
                                  (screen.menu.itemHeight * index)),
                          child: GrowingAnimation(
                              begin: 2,
                              end: 2,
                              rebuild: true,
                              reverse: true,
                              child: visual))),
                  child: Padding(
                      padding: EdgeInsets.only(
                          top: screen.canvas.midHeight +
                              (screen.menu.itemHeight * index)),
                      child: GestureDetector(
                          onTap: () => maestro.activateSubMenu(sub),
                          child: visual)));
        }
        if (state.prior?.sub == SubMenu.none && state.sub != sub) {
          return onNotChosen ??
              SlideOver(
                  begin: const Offset(0, 0),
                  end: const Offset(-1, 0),
                  delay: fadeDuration * index * .25,
                  child: Padding(
                      padding: EdgeInsets.only(
                          top: screen.canvas.midHeight +
                              (screen.menu.itemHeight * index)),
                      child: visual));
        }
        return onElse ??
            Padding(
                padding: EdgeInsets.only(
                    top: screen.canvas.midHeight +
                        (screen.menu.itemHeight * index)),
                child: GestureDetector(
                    onTap: () => maestro.activateSubMenu(sub), child: visual));
      });
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
      visual: SizedBox(
          height: screen.menu.itemHeight,
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            const Icon(Icons.settings_rounded, color: Colors.white),
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
      visual: SizedBox(
          height: screen.menu.itemHeight,
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            const Icon(Icons.info_rounded, color: Colors.white),
            const SizedBox(width: 16),
            Text('About', style: AppText.h2.copyWith(color: Colors.white)),
          ])));
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
