import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/theme/colors.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_back/streams/app.dart';

class BackdropAppBarContents extends StatelessWidget
    implements PreferredSizeWidget {
  final bool spoof;

  const BackdropAppBarContents({Key? key, this.spoof = false})
      : super(key: key);

  @override
  Size get preferredSize => const Size(double.infinity, 56);

  @override
  Widget build(BuildContext context) {
    final appBar = Platform.isIOS
        ? buildAppBar(
            context,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.black,
              statusBarIconBrightness: Brightness.light, // For Android
              statusBarBrightness: Brightness.dark, // For iOS
            ),
            backgroundColor: Colors.transparent,
            shape: components.shape.topRounded,
          )
        : buildAppBar(
            context,
            backgroundColor: Theme.of(context).backgroundColor,
            shape: components.shape.topRounded,
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
        GestureDetector(
          onTap: () =>
              streams.app.snack.add(Snack(message: 'Sucessful Import')),
          child: appBar,
        ),
        alphaBar,
      ],
    );
  }

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
        leading: streams.app.page.value == 'Login'
            ? null
            : PageLead(mainContext: context),
        centerTitle: spoof,
        title: PageTitle(),
        actions: <Widget>[
          if (!spoof) components.status,
          if (!spoof) spoof ? SpoofedConnectionLight() : ConnectionLight(),
          if (!spoof) QRCodeContainer(),
          if (!spoof) SnackBarViewer(),
          if (!spoof) SizedBox(width: 6),
          if (!spoof) PeristentKeyboardWatcher(),
        ],
      );
}
