import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/canvas/menu/cubit.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/domain/concepts/consent.dart';
import 'package:moontree/presentation/theme/theme.dart';
import 'package:moontree/presentation/utils/animation.dart';
import 'package:moontree/services/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) => Container(
      width: screen.width,
      height: screen.height,
      padding:
          EdgeInsets.only(top: screen.appbar.height + screen.canvas.midHeight),
      alignment: Alignment.topCenter,
      child: Container(
          padding: const EdgeInsets.only(left: 16, right: 16),
          width: screen.width,
          height: screen.canvas.bottomHeight,
          alignment: Alignment.center,
          child: const AnimatedMenu()));
}

class AnimatedMenu extends StatelessWidget {
  const AnimatedMenu({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<MenuCubit, MenuState>(
      buildWhen: (MenuState previous, MenuState current) =>
          current.active &&
          (previous.faded != current.faded || previous.mode != current.mode),
      builder: (context, state) => AnimatedOpacity(
          duration: fadeDuration,
          curve: Curves.easeInOutCubic,
          opacity: state.faded ? .12 : 1,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                          onTap: () => launchUrl(
                              Uri.parse('https://discord.gg/cGDebEXgpW')),
                          child: Container(
                              height: screen.menu.itemHeight,
                              color: Colors.transparent,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.help_rounded,
                                        color: Colors.white),
                                    const SizedBox(width: 16),
                                    Text('Need Help? Chat Now!',
                                        style: AppText.h2
                                            .copyWith(color: Colors.white)),
                                  ]))),
                      GestureDetector(
                          onTap: cubits.menu.toggleDifficulty,
                          child: Container(
                              height: screen.menu.itemHeight,
                              color: Colors.transparent,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(state.mode.icon, color: Colors.white),
                                    const SizedBox(width: 16),
                                    Text('Mode: ${state.mode.name}',
                                        style: AppText.h2
                                            .copyWith(color: Colors.white)),
                                  ]))),
                      SizedBox(
                          height: screen.menu.itemHeight,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.settings_rounded,
                                    color: Colors.white),
                                const SizedBox(width: 16),
                                Text('Settings',
                                    style: AppText.h2
                                        .copyWith(color: Colors.white)),
                              ])),
                      SizedBox(
                          height: screen.menu.itemHeight,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_rounded,
                                    color: Colors.white),
                                const SizedBox(width: 16),
                                Text('About',
                                    style: AppText.h2
                                        .copyWith(color: Colors.white)),
                              ])),
                    ]),
                Column(children: [
                  //Row(
                  //    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //    children: [
                  //      Text('User Agreement',
                  //          style:
                  //              AppText.body2.copyWith(color: Colors.white60)),
                  //      Text('Privacy Policy',
                  //          style:
                  //              AppText.body2.copyWith(color: Colors.white60)),
                  //      Text('Risk Disclosure',
                  //          style:
                  //              AppText.body2.copyWith(color: Colors.white60)),
                  //    ]),
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
                                launchUrl(Uri.parse(documentEndpoint(
                                    ConsentDocument.userAgreement)));
                              }),
                        const TextSpan(text: '   '),
                        TextSpan(
                            text: 'Privacy Policy',
                            style: AppText.underlinedLink(AppText.body2),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrl(Uri.parse(documentEndpoint(
                                    ConsentDocument.privacyPolicy)));
                              }),
                        const TextSpan(text: '   '),
                        TextSpan(
                            text: 'Risk Disclosure',
                            style: AppText.underlinedLink(AppText.body2),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrl(Uri.parse(documentEndpoint(
                                    ConsentDocument.riskDisclosures)));
                              }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ]),
              ])));
}
