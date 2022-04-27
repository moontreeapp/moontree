import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/theme/colors.dart';
import 'package:raven_front/utils/auth.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_front/components/components.dart';

class BackdropAppBar extends StatefulWidget implements PreferredSizeWidget {
  const BackdropAppBar({Key? key}) : super(key: key);

  @override
  State<BackdropAppBar> createState() => _BackdropAppBarState();

  @override
  Size get preferredSize => const Size(double.infinity, 56);
}

class _BackdropAppBarState extends State<BackdropAppBar> {
  late List listeners = [];

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.splash.listen((bool value) {
      setState(() {});
    }));
    listeners.add(streams.app.logout.listen((bool value) {
      if (value) {
        logout();
      }
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = Platform.isIOS
        ? buildAppBar(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.black,
              statusBarIconBrightness: Brightness.light, // For Android
              statusBarBrightness: Brightness.dark, // For iOS
            ),
            backgroundColor: Colors.transparent,
            shape: components.shape.topRounded,
          )
        : buildAppBar(
            backgroundColor: Theme.of(context).backgroundColor,
          );
    final alphaBar = Platform.isIOS
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
          );
    return streams.app.splash.value
        ? PreferredSize(preferredSize: Size(0, 0), child: Container(height: 0))
        : Stack(
            alignment: Alignment.bottomCenter,
            children: [
              if (Platform.isIOS)
                FrontCurve(
                  height: 56,
                  color: Theme.of(context).backgroundColor,
                  fuzzyTop: false,
                  frontLayerBoxShadow: const [],
                ),
              appBar,
              alphaBar,
            ],
          );
  }

  Widget buildAppBar({
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
        leading: streams.app.page.value == 'Login'
            ? null
            : PageLead(mainContext: context),
        title: /*FittedBox(fit: BoxFit.fitWidth, child: */ PageTitle() /*)*/,
        actions: <Widget>[
          components.status,
          ConnectionLight(),
          QRCodeContainer(),
          SnackBarViewer(),
          SizedBox(width: 6),
          PeristentKeyboardWatcher(),
        ],
      );
}
