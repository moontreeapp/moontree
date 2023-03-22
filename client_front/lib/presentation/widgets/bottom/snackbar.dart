import 'dart:async';
import 'dart:io' show Platform;
import 'package:client_front/presentation/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/presentation/components/shapes.dart' as shapes;
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/domain/utils/extensions.dart';

class SnackBarViewer extends StatefulWidget {
  const SnackBarViewer({Key? key}) : super(key: key);

  @override
  _SnackBarViewerState createState() => _SnackBarViewerState();
}

class _SnackBarViewerState extends State<SnackBarViewer> {
  Snack? snack;
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.snack.listen((Snack? value) {
      if (value != null && value != snack) {
        snack = value;
        if (snack != null) {
          show();
        }
      }
    }));
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox(height: 0, width: 0);

  TextStyle style() => snack!.positive
      ? Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.white)
      : Theme.of(context)
          .textTheme
          .bodyText2!
          .copyWith(color: AppColors.errorlight);

  static const Set<String> emptyLocations = {
    '',
    '/',
    '/splash',
    '/login/create',
    '/login/native',
    '/login/password',
  };

  Future<void> show() async {
    /// don't show snackbars on login screen
    if (emptyLocations.contains(sail.latestLocation) && !snack!.showOnLogin) {
      return;
    }

    final NavHeight navHeight;
    if (streams.app.page.value == 'Home' && streams.app.setting.value == null) {
      navHeight = NavHeight.short; // should be tall
    } else if (streams.app.page.value == 'Home' &&
        streams.app.setting.value != null) {
      navHeight = NavHeight.none;
    } else if (<String>['Support'].contains(streams.app.page.value)) {
      navHeight = NavHeight.tall;
    } else if (<String>[
      'Setup',
      'Createlogin',
      'Login',
      'Locked',
      'Change',
      'Mining',
      'Database',
      'Developer',
      'Advanced',
      'Addresses',
      'Transaction',
    ].contains(streams.app.page.value)) {
      navHeight = NavHeight.none;
    } else if (<String>[
      'Blockchain',
      'Import',
      'Sweep',
      'Backup',
      'Backupconfirm',
      'Receive',
      'Transactions',
      'Send',
      'Checkout',
    ].contains(streams.app.page.value)) {
      navHeight = NavHeight.short;
    } else {
      navHeight = streams.app.navHeight.value;
    }

    final bool copy = services.developer.developerMode && snack!.copy != null;
    final Row row = Row(
        mainAxisAlignment:
            copy ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (copy)
            SizedBox(
                width: (MediaQuery.of(context).size.width - 32) * 0.75,
                child: Text(
                  snack!.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style(),
                ))
          else
            SizedBox(
                width: (MediaQuery.of(context).size.width - 32),
                child: Text(
                  snack!.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style(),
                )),
          if (copy)
            SizedBox(
                width: (MediaQuery.of(context).size.width - 32) * 0.25,
                child: Text(
                  snack!.label ?? snack!.copy ?? 'copy',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style(),
                ))
        ]);
    GestureDetector msg = GestureDetector(
        onTap: () {
          if (copy) {
            Clipboard.setData(ClipboardData(text: snack!.copy));
          }
          ScaffoldMessenger.of(context).clearSnackBars();
        },
        child: navHeight == NavHeight.none
            ? Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 12, bottom: 12),
                child: row)
            : Stack(alignment: Alignment.bottomCenter, children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  height: 64,
                  decoration: BoxDecoration(
                      color: AppColors.snackBar,
                      borderRadius: shapes.topRoundedBorder8),
                  child: Padding(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 12),
                      child: row),
                ),
                Container(
                    height: 16,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: shapes.topRoundedBorder16,
                        boxShadow: const <BoxShadow>[
                          // this one is to hide the shadow put on snackbars by default
                          BoxShadow(color: Color(0xFFFFFFFF), spreadRadius: 1),
                          BoxShadow(
                              color: Color(0x33FFFFFF),
                              offset: Offset(0, 5),
                              blurRadius: 5),
                          BoxShadow(
                              color: Color(0x1FFFFFFF),
                              offset: Offset(0, 3),
                              blurRadius: 14),
                          BoxShadow(
                              color: Color(0x3DFFFFFF),
                              offset: Offset(0, 8),
                              blurRadius: 10)
                        ]))
              ]));
    if (navHeight == NavHeight.none) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        elevation: 1,
        dismissDirection: DismissDirection.horizontal,
        backgroundColor: AppColors.snackBar,
        shape: shapes.topRounded8,
        content: msg,
        padding: EdgeInsets.zero,
      ));
    } else if (navHeight == NavHeight.short) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        elevation: 0,
        dismissDirection: DismissDirection.none,
        backgroundColor: AppColors.white,
        shape: shapes.topRounded8,
        content: msg,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: (Platform.isIOS ? 32 : 60).figmaH),
        padding: EdgeInsets.zero,
        //action: (snack!.copy != null)
        //    ? SnackBarAction(
        //        label: ' ',
        //        onPressed: () =>
        //            Clipboard.setData(ClipboardData(text: snack!.copy)))
        //    : null,
      ));
    } else /*if (snack!.link == null && snack!.details == null)*/ {
      /// make sure we don't display until we've been sent back home
      int x = 0;
      while (streams.app.page.value != 'Home') {
        await Future<void>.delayed(const Duration(milliseconds: 665));
        x += 1;
        if (x > 10) {
          break;
        }
      }

      /// this configuration of the snackbar always shows on top of the nav bar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        elevation: 0,
        dismissDirection: DismissDirection.none,
        backgroundColor: AppColors.white,
        shape: shapes.topRounded8,
        content: msg,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: (Platform.isIOS ? 77 : 106).figmaH),
        padding: EdgeInsets.zero,
      ));
    }
    /*
    /// These are not used if we want to use them implement them this way:
    /// https://github.com/moontreeapp/moontree/issues/271#issuecomment-1059342537
    /// (leaving this here for future reference and easier implementation)
    } else if (snack!.link != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          elevation: 0,
          backgroundColor: AppColors.snackBar,
          shape:shapes.topRounded,
          content: msg,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 102),
          padding: const EdgeInsets.only(
            top: 0,
            bottom: 0,
          ),
          action: SnackBarAction(
              label: snack?.label ?? 'go',
              onPressed: snack!.link!.startsWith('/')
                  // app page
                  ? () => Navigator.pushNamed(context, snack!.link!,
                      arguments: snack?.arguments ?? {})
                  // external site
                  : () => showDialog(
                      context: components.routes.routeContext!,
                      builder: (BuildContext context) => AlertDialog(
                              //title: Text('External App'),
                              content: Text('Open external app (browser)?',
                                  style: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.black60)),
                              actions: <Widget>[
                                TextButton(
                                    child: Text('Cancel',
                                        style: Theme.of(context)
                                            .textTheme.bodyText2!.copyWith(fontWeight: FontWeights.bold, letterSpacing: 1.25, color: AppColors.primary))),
                                    onPressed: () =>
                                        Navigator.of(context).pop()),
                                TextButton(
                                    child: Text('Continue',
                                        style: Theme.of(context)
                                            .textTheme.bodyText2!.copyWith(fontWeight: FontWeights.bold,      letterSpacing: 1.25,      color: AppColors.primary))),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      launch(snack!.link!);
                                    })
                              ])))));
    } else if (snack!.details != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          elevation: 0,
          backgroundColor: AppColors.snackBar,
          shape:shapes.topRounded,
          content: msg,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 102),
          padding: const EdgeInsets.only(
            top: 0,
            bottom: 0,
          ),
          action: SnackBarAction(
              label: snack?.label ?? 'details',
              onPressed: () => showDialog(
                  context: components.routes.routeContext!,
                  builder: (BuildContext context) => AlertDialog(
                          title: Text('Details',
                              style: Theme.of(context).testTheme.body2),
                          content: Text(snack!.details!,
                              style: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.black60)),
                          actions: <Widget>[
                            TextButton(
                                child: Text('Ok',
                                    style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeights.bold,      letterSpacing: 1.25,      color: AppColors.primary))),
                                onPressed: () => Navigator.of(context).pop())
                          ])))));
    }
    */
    //Navigator.popUntil(
    //    components.routes.routeContext!, ModalRoute.withName('/home'));
  }
}
