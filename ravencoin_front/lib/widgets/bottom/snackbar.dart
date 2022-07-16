import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/streams/streams.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/utils/extensions.dart';

class SnackBarViewer extends StatefulWidget {
  SnackBarViewer({Key? key}) : super(key: key);

  @override
  _SnackBarViewerState createState() => _SnackBarViewerState();
}

class _SnackBarViewerState extends State<SnackBarViewer> {
  Snack? snack;
  late List listeners = [];
  final BorderRadius shape = BorderRadius.only(
    topLeft: Radius.circular(8.0),
    topRight: Radius.circular(8.0),
  );

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
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(height: 0, width: 0);
  }

  TextStyle style() => snack!.positive
      ? Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.white)
      : Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.error);

  Future<void> show() async {
    var msg = GestureDetector(
        onTap: () {
          print('clearing snackbar?');
          ScaffoldMessenger.of(context).clearSnackBars();
        },
        child: snack!.atBottom
            ? Padding(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Text(
                  snack!.message,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: style(),
                ))
            : Stack(alignment: Alignment.bottomCenter, children: [
                Container(
                    alignment: Alignment.topLeft,
                    height: 64,
                    decoration: BoxDecoration(
                        color: AppColors.snackBar,
                        borderRadius: components.shape.topRoundedBorder8),
                    child: Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, top: 12),
                        child: Text(
                          snack!.message,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: style(),
                        ))),
                Container(
                    height: 16,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: components.shape.topRoundedBorder16,
                        boxShadow: [
                          // this one is to hide the shadow put on snackbars by default
                          BoxShadow(
                              color: const Color(0xFFFFFFFF), spreadRadius: 1),
                          BoxShadow(
                              color: const Color(0x33FFFFFF),
                              offset: Offset(0, 5),
                              blurRadius: 5),
                          BoxShadow(
                              color: const Color(0x1FFFFFFF),
                              offset: Offset(0, 3),
                              blurRadius: 14),
                          BoxShadow(
                              color: const Color(0x3DFFFFFF),
                              offset: Offset(0, 8),
                              blurRadius: 10)
                        ]))
              ]));
    if (snack!.atBottom) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        elevation: 1,
        dismissDirection: DismissDirection.horizontal,
        backgroundColor: AppColors.snackBar,
        shape: components.shape.topRounded8,
        content: msg,
      ));
    } else if (snack!.atMiddle) {
      streams.app.hideNav.add(false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        elevation: 0,
        dismissDirection: DismissDirection.none,
        backgroundColor: AppColors.white,
        shape: components.shape.topRounded8,
        content: msg,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: (Platform.isIOS ? 51.6 : 60).figmaH),
        padding: EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 0),
        //action: SnackBarAction(
        //    label: ' ',
        //    onPressed: () =>
        //        Clipboard.setData(ClipboardData(text: snack!.message))),
      ));
    } else /*if (snack!.link == null && snack!.details == null)*/ {
      /// make sure we don't display until we've been sent back home
      var x = 0;
      while (streams.app.page.value != 'Home') {
        await Future.delayed(Duration(milliseconds: 665));
        x += 1;
        if (x > 10) {
          break;
        }
      }

      /// this configuration of the snackbar always shows on top of the nav bar
      streams.app.hideNav.add(false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        elevation: 0,
        dismissDirection: DismissDirection.none,
        backgroundColor: AppColors.white,
        shape: components.shape.topRounded8,
        content: msg,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: (Platform.isIOS ? 76 : 106).figmaH),
        padding: EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 0),
        //action: SnackBarAction(
        //    label: ' ',
        //    onPressed: () =>
        //        Clipboard.setData(ClipboardData(text: snack!.message))),
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
          shape:components.shape.topRounded,
          content: msg,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 102),
          padding: EdgeInsets.only(
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
                      context: components.navigator.routeContext!,
                      builder: (BuildContext context) => AlertDialog(
                              //title: Text('External App'),
                              content: Text('Open external app (browser)?',
                                  style: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.black60)),
                              actions: [
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
          shape:components.shape.topRounded,
          content: msg,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 102),
          padding: EdgeInsets.only(
            top: 0,
            bottom: 0,
          ),
          action: SnackBarAction(
              label: snack?.label ?? 'details',
              onPressed: () => showDialog(
                  context: components.navigator.routeContext!,
                  builder: (BuildContext context) => AlertDialog(
                          title: Text('Details',
                              style: Theme.of(context).testTheme.body2),
                          content: Text(snack!.details!,
                              style: Theme.of(context).textTheme.bodyText2!.copyWith(color: AppColors.black60)),
                          actions: [
                            TextButton(
                                child: Text('Ok',
                                    style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeights.bold,      letterSpacing: 1.25,      color: AppColors.primary))),
                                onPressed: () => Navigator.of(context).pop())
                          ])))));
    }
    */
    //Navigator.popUntil(
    //    components.navigator.routeContext!, ModalRoute.withName('/home'));
  }
}
