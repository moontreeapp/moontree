import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_back/streams/streams.dart';

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

  void show() {
    var msg = snack!.atBottom
        ? Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Text(snack!.message,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(color: AppColors.white)))
        : Container(
            height: 64,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 0, color: Colors.transparent),
                Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Text(snack!.message,
                        style: snack!.positive
                            ? Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(color: AppColors.white)
                            : Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(color: AppColors.error))),
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
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
                      ]),
                )
              ],
            ),
          );
    if (snack!.atBottom) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          elevation: 1,
          backgroundColor: AppColors.snackBar,
          shape: RoundedRectangleBorder(borderRadius: shape),
          content: msg,
          action: snack!.positive
              ? null
              : SnackBarAction(
                  label: 'copy',
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: snack!.message)))));
    } else if (snack!.link == null && snack!.details == null) {
      /// this configuration of the snackbar always shows on top of the nav bar
      streams.app.hideNav.add(false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          elevation: 0,
          backgroundColor: AppColors.snackBar,
          shape: RoundedRectangleBorder(borderRadius: shape),
          content: msg,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * (106 / 760)),
          padding: EdgeInsets.only(top: 0, bottom: 0),
          action: snack!.positive
              ? null
              : SnackBarAction(
                  label: 'copy',
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: snack!.message)))));
    }
    /*
    /// These are not used if we want to use them implement them this way:
    /// https://github.com/moontreeapp/moontree/issues/271#issuecomment-1059342537
    /// (leaving this here for future reference and easier implementation)
    } else if (snack!.link != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          elevation: 0,
          backgroundColor: AppColors.snackBar,
          shape: RoundedRectangleBorder(borderRadius: shape),
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
          shape: RoundedRectangleBorder(borderRadius: shape),
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
