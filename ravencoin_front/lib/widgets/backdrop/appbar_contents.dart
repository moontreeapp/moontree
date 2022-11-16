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
            streams.app.snack.add(Snack(
                message:
                    '${streams.app.page.value} | ${streams.app.setting.value}',
                showOnLogin: true));
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
        leading:
            ['ChooseMethod', 'Login', 'Setup'].contains(streams.app.page.value)
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
