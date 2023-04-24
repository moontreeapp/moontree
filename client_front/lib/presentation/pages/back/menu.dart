import 'package:client_front/presentation/widgets/other/fading.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/services/consent.dart';
import 'package:client_front/domain/utils/auth.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:client_front/presentation/widgets/other/sliding.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/services/services.dart' show sail;
import 'package:client_front/presentation/components/components.dart'
    as components;

import 'package:client_front/presentation/utils/animation.dart' as animation;

class MenuRouter extends StatelessWidget {
  final String path;
  final String prior;
  const MenuRouter({Key? key, required this.path, required this.prior})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (path == '/menu' && prior == '/') {
      return FadeIn(duration: animation.fadeDuration * 2, child: MainMenu());
    } else if (path == '/menu' && prior == '/menu/restore') {
      return SlideOutIn(left: MainMenu(), right: RestoreMenu(), enter: false);
    } else if (path == '/menu' && prior == '/menu/settings') {
      return SlideOutIn(left: MainMenu(), right: SettingsMenu(), enter: false);
    } else if (path == '/menu/restore') {
      return SlideOutIn(left: MainMenu(), right: RestoreMenu());
    } else if (path == '/menu/settings') {
      return SlideOutIn(left: MainMenu(), right: SettingsMenu());
    } else {
      return FadeIn(duration: animation.fadeDuration * 2, child: MainMenu());
    }
  }
}

class Menu extends StatelessWidget {
  final String path;
  final String prior;
  const Menu({Key? key, required this.path, required this.prior})
      : super(key: key);

  @override
  Widget build(BuildContext context) =>

      //todo: use animated switcher to make nice transitions slide to the right.
      //      requires putting the various sets of settings into their own
      //      widgets and might require us keep memory of last one on the cubit.
      //AnimatedSwitcher(
      //  duration: animation.fadeDuration,
      //  transitionBuilder: (Widget child, Animation<double> animation) =>
      //      FadeTransition(
      //          opacity: animation.drive(Tween<double>(begin: 0, end: 1)
      //              .chain(CurveTween(curve: Curves.easeInOutCubic))),
      //          child: child),
      //  child: state.child,
      //)),
      //(options[components.cubits.backContainer.state.path] ??
      //    options['/menu'])!
      Container(
          color: Theme.of(context).backgroundColor,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(children: <Widget>[
                  if (pros.wallets.length > 1)
                    const Divider(indent: 0, color: AppColors.white12),
                  MenuRouter(path: path, prior: prior),
                ]),
                if (services.password.required)
                  Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    child: BottomButton(
                                  enabled: true,
                                  invert: true,
                                  onPressed: logout,
                                  label: 'Logout',
                                ))
                              ],
                            )),
                        //SizedBox(height: .065.ofMediaHeight(context) + 16)
                        SizedBox(height: 40 * 2)
                      ])
                else
                  Container(),
              ]));
}

/// unused, made to facilitate animatedswitcher, but haven't been able to get
/// that to work yet. MenuContainer(child: SettingsMenu) for example
class MenuContainer extends StatelessWidget {
  final Widget child;
  const MenuContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(children: <Widget>[
              if (pros.wallets.length > 1)
                const Divider(indent: 0, color: AppColors.white12),
              child,
            ]),
            if (services.password.required)
              Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: BottomButton(
                              enabled: true,
                              invert: true,
                              onPressed: logout,
                              label: 'Logout',
                            ))
                          ],
                        )),
                    //SizedBox(height: .065.ofMediaHeight(context) + 16)
                    SizedBox(height: 40 * 2)
                  ])
            else
              Container(),
          ]));
}

//'/menu': ,
class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: <Widget>[
          MenuLink(
            //icon: MdiIcons.linkBoxVariant, //MdiIcons.linkVariant,
            widget: Stack(alignment: Alignment.center, children: [
              SvgPicture.asset('assets/icons/custom/white/blockchain.svg'),
              Container(
                  alignment: Alignment.center,
                  height: 24,
                  width: 24,
                  child: Icon(MdiIcons.linkVariant, color: Colors.white)),
            ]),
            name: 'Blockchain',
            link: '/network/blockchain',
          ),
          if (!services.developer.developerMode)
            MenuLink(
                icon: MdiIcons.shieldKey,
                svg: SvgPicture.asset('assets/icons/custom/mobile/import.svg'),
                name: 'Import',
                link: '/restore/import'),
          if (false && // not yet supported
              !services.developer.developerMode &&
              Current.balanceRVN.value > 0)
            MenuLink(
              icon: MdiIcons.broom,
              name: 'Sweep',
              link: '/sweep',
            ),
          if (services.developer.developerMode)
            MenuLink(
              icon: MdiIcons.shieldKey,
              svg: SvgPicture.asset(
                  'assets/icons/custom/mobile/import-export.svg'),
              name: 'Import & Export',
              link: '/menu/restore',
              arrow: true,
            ),
          MenuLink(
            icon: MdiIcons.drawPen,
            svg: SvgPicture.asset('assets/icons/custom/mobile/backup.svg'),
            name: 'Backup',
            link: Current.wallet is LeaderWallet
                ? '/backup/intro'
                : '/backup/keypair',
          ),
          MenuLink(
            icon: Icons.settings,
            svg: SvgPicture.asset('assets/icons/custom/mobile/settings.svg'),
            name: 'Settings',
            link: '/menu/settings',
            arrow: true,
          ),
          /*
          MenuLink(
            icon: Icons.feedback,
            name: 'Feedback',
            link: '/menu/feedback',
          ),
          */
          MenuLink(
            icon: Icons.help,
            svg: SvgPicture.asset('assets/icons/custom/mobile/support.svg'),
            name: 'Support',
            link: '/support/support',
          ),
          MenuLink(
            icon: Icons.info_rounded,
            svg: SvgPicture.asset('assets/icons/custom/mobile/about.svg'),
            name: 'About',
            link: '/support/about',
          ),

          /*
          MenuLink(
              icon: Icons.info_outline_rounded,
              name: 'Clear Database',
              link: '/home',
              execute: ravenDatabase.deleteDatabase),
          ListTile(
              title: Text('test'),
              leading: Icon(Icons.info_outline_rounded),
              onTap: () async {
                
              }),
          */
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style:
                  Theme.of(components.routes.routeContext!).textTheme.bodyText2,
              children: <TextSpan>[
                TextSpan(
                    text: 'User Agreement',
                    style: Theme.of(components.routes.routeContext!)
                        .textTheme
                        .underlinedMenuLink,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse(
                            documentEndpoint(ConsentDocument.user_agreement)));
                      }),
                const TextSpan(text: '   '),
                TextSpan(
                    text: 'Privacy Policy',
                    style: Theme.of(components.routes.routeContext!)
                        .textTheme
                        .underlinedMenuLink,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse(
                            documentEndpoint(ConsentDocument.privacy_policy)));
                      }),
                const TextSpan(text: '   '),
                TextSpan(
                    text: 'Risk Disclosure',
                    style: Theme.of(components.routes.routeContext!)
                        .textTheme
                        .underlinedMenuLink,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse(documentEndpoint(
                            ConsentDocument.risk_disclosures)));
                      }),
              ],
            ),
          )
        ],
      );
}

//'/menu/restore': ,
class RestoreMenu extends StatelessWidget {
  const RestoreMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: <Widget>[
          MenuLink(
              icon: MdiIcons.keyPlus,
              svg: SvgPicture.asset('assets/icons/custom/mobile/import.svg'),
              name: 'Import',
              link: '/restore/import'),
          if (false // not yet supported
          )
            MenuLink(
                icon: MdiIcons.keyMinus,
                svg: SvgPicture.asset('assets/icons/custom/mobile/export.svg'),
                name: 'Export',
                link: '/restore/export',
                disabled: !services.developer.advancedDeveloperMode),
          if (false && // not yet supported
              services.developer.developerMode &&
              (pros.securities.currentCoin.balance?.value ?? 0) > 0)
            MenuLink(
              icon: MdiIcons.broom,
              name: 'Sweep',
              link: '/sweep',
            ),
        ],
      );
}

///'/menu/settings'
class SettingsMenu extends StatelessWidget {
  const SettingsMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: <Widget>[
          MenuLink(
            icon: Icons.lock_rounded,
            svg: SvgPicture.asset('assets/icons/custom/mobile/security.svg'),
            name: 'Security',
            link: '/setting/security',
          ),
          /*
          if (!pros.settings.authMethodIsNativeSecurity)
            MenuLink(
              icon: Icons.lock_rounded,
              name: 'Password',
              link: '/settings/password/change',
            ),
            */
          /*
          MenuLink(
              icon: MdiIcons.accountCog,
              name: 'User Level',
              link: '/menu/level'),
          
          MenuLink( // has been combined with blockchain
            icon: MdiIcons.network,
            name: 'Network',
            link: '/menu/network',
          ),
          */
          /// we no longer derive all addresses on startup so... we have to
          /// either derive once we go to this page, or remove it entirely.
          //if (services.developer.advancedDeveloperMode)
          //  MenuLink(
          //    icon: Icons.format_list_bulleted_rounded,
          //    name: 'Addresses',
          //    link: '/addresses',
          //  ),
          if (false) // not necessary anymore with new serverside backend
            MenuLink(
              icon: MdiIcons.pickaxe,
              name: 'Mining',
              link: '/setting/mining',
            ),
          if (services.developer.developerMode)
            MenuLink(
              icon: MdiIcons.database,
              name: 'Database',
              link: '/setting/database',
            ),
          if (services.developer.advancedDeveloperMode == true)
            MenuLink(
              icon: MdiIcons.rocketLaunchOutline,
              name: 'Advanced',
              link: '/mode/advanced',
            ),
          MenuLink(
            widget: Container(
                alignment: Alignment.center,
                height: 24,
                width: 24,
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.developer_mode_rounded, color: Colors.white)),
            name: 'Developer',
            link: '/mode/developer',
          ),
        ],
      );
}

class MenuLink extends StatelessWidget {
  final String name;
  final String link;
  final IconData? icon;
  final Image? image;
  final SvgPicture? svg;
  final Widget? widget;
  final bool arrow;
  final Map<String, dynamic>? arguments;
  final Function? execute;
  final Function? executeAfter;
  final bool disabled;
  const MenuLink({
    super.key,
    required this.name,
    required this.link,
    this.icon,
    this.image,
    this.svg,
    this.widget,
    this.arguments,
    this.execute,
    this.executeAfter,
    this.arrow = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: disabled
            ? () {}
            : () {
                if (execute != null) {
                  execute!();
                }
                if (!arrow) {
                  // todo: should snackbars be managed here or in sail? why is
                  //       this here?
                  ScaffoldMessenger.of(context).clearSnackBars();
                  sail.to(link, arguments: arguments);
                } else {
                  // todo: stream unused. maybe this needs to talk to the cubit?
                  //streams.app.setting.add(link);
                  components.cubits.backContainer.update(path: link);
                }
                if (executeAfter != null) {
                  executeAfter!();
                }
              },
        leading: widget != null
            ? widget
            : svg != null
                ? svg
                : icon != null
                    ? Icon(icon,
                        color: disabled ? AppColors.white60 : Colors.white)
                    : image!,
        title: Text(name,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: disabled ? AppColors.white60 : AppColors.white)),
        trailing: arrow
            ? SvgPicture.asset('assets/icons/custom/white/chevron-right.svg')
            //Icon(Icons.chevron_right,
            //  color: disabled ? AppColors.white60 : Colors.white)
            : null,
      );
}
