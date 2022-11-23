import 'dart:async';
import 'dart:io' show Platform;
import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/services/auth.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:ravencoin_front/services/wallet.dart';
import 'package:ravencoin_front/theme/colors.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;

class BackdropAppBarContents extends StatelessWidget
    implements PreferredSizeWidget {
  final bool spoof;
  final bool animate;

  const BackdropAppBarContents({
    Key? key,
    this.spoof = false,
    this.animate = true,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size(double.infinity, 56);

  @override
  Widget build(BuildContext context) {
    final appBar = Platform.isIOS
        ? buildAppBar(
            context,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarBrightness: Brightness.dark, // For iOS
            ),
            backgroundColor: Colors.transparent,
            shape: components.shape.topRounded8,
          )
        : buildAppBar(
            context,
            backgroundColor: AppColors.primary,
            shape: components.shape.topRounded8,
          );
    /*final alphaBar = Platform.isIOS
        ? Container(
            height: 56,
            child: ClipRect(
              child: Container(
                alignment: Alignment.topRight,
                child: Banner(
                  message: 'alpha',
                  location: BannerLocation.topEnd,
                  color: AppColors.success,
                ),
              ),
            ))
        : ClipRect(
            child: Container(
              alignment: Alignment.topRight,
              child: Banner(
                message: 'alpha',
                location: BannerLocation.topEnd,
                color: AppColors.success,
              ),
            ),
          );*/
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        if (Platform.isIOS)
          FrontCurve(
            height: 56,
            color: Theme.of(context).backgroundColor,
            fuzzyTop: false,
            frontLayerBoxShadow: const [],
          ),
        testAppBar(appBar, test: true),
        // alphaBar,
        AppBarScrim(),
      ],
    );
  }

  Widget testAppBar(Widget appBar, {bool test = false}) => test
      ? GestureDetector(
          onTap: () async {
            if (services.developer.advancedDeveloperMode) {
              //streams.app.snack.add(Snack(
              //    message:
              //        '${streams.app.page.value} | ${streams.app.setting.value}',
              //    showOnLogin: true));
              //
              //print(pros.addresses.byAddress
              //    .getOne('Eagq7rNFUEnR7kciQafV38kzpocef74J44'));
              //4779042ef9d30eb2b1f5a1afbf286f30a4c5d0634d3030b9e00ccda76084985f
              //
              //await services.balance.recalculateAllBalances();
              //print([for (var x in Current.wallet.unspents) x.value].sum());
              //print([for (var x in Current.wallet.balances) x.value].sum());
              //
              //for (var x in Current.wallet.balances) {
              //  print(x);
              //}
              //for (var x in Current.wallet.unspents) {
              //  print(x);
              //}
              //print(pros.addresses.byAddress
              //    .getOne('EZxVbSaaJpRBoNE3q9hTuqWxhL7vbJMkvV'));
              //for (var x in pros.assets) {
              //  print(x);
              //}
              //for (var x in pros.securities) {
              //  print(x);
              //}
              //
              //print(await services.client.api.getAssetUnspents([
              //  'c38edbf38b247807f581f8d2ef4094e62f1d71179fcd799a959136898caf83da'
              //]));
              //print(pros.addresses.byScripthash.getOne(
              //    'c38edbf38b247807f581f8d2ef4094e62f1d71179fcd799a959136898caf83da'));
              ////print(await services.client.api.getAssetUnspents([
              ////  '577d2e12c4e221a0ba98a8225d58d54b7353a3615a59d4bf5fae2898f623a261'
              ////]));
              //print(pros.unspents.getSymbolsByWallet(Current.walletId));
              //
              print(components.navigator.routeStack.first.settings.name);
            }
          },
          child: appBar,
        )
      : appBar;

  Widget buildAppBar(
    BuildContext context, {
    SystemUiOverlayStyle? systemOverlayStyle,
    Color? backgroundColor,
    ShapeBorder? shape,
  }) =>
      AppBar(
        systemOverlayStyle: systemOverlayStyle,
        backgroundColor: backgroundColor,
        shape: shape,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: ['ChooseMethod', 'Login', 'Setup', 'Backupintro']
                    .contains(streams.app.page.value) ||
                streams.app.lead.value == LeadIcon.none
            ? null
            : PageLead(mainContext: context),
        centerTitle: spoof,
        title: PageTitle(animate: animate),
        actions: <Widget>[
          /// thought it might be nice to have an indicator of which blockchain
          /// is being used, but I think we can make better use of the real
          /// estate by moving the options to the network page, and moving the
          /// validation to during the "connect" process rather than before the
          /// page is shown, so commenting out here for now. instead of the
          /// status light we could show the icon of the current blockchain with
          /// an overlay color of the status. then if the option was on the
          /// network page that would make sense.
          //if (!spoof) ChosenBlockchain(),
          /// this is not needed since we have a shimmer and we'll subtle color
          /// the connection light in the event that we have network activity.
          //if (!spoof) ActivityLight(),
          if (!spoof) spoof ? SpoofedConnectionLight() : ConnectionLight(),
          if (!spoof) QRCodeContainer(),
          if (!spoof) SnackBarViewer(),
          if (!spoof) SizedBox(width: 6),
          if (!spoof) components.status,
          if (!spoof) PeristentKeyboardWatcher(),
        ],
      );
}
