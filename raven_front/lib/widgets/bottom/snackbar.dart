import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:url_launcher/url_launcher.dart';
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
    //OutlinedBorder shape = RoundedRectangleBorder(
    //  //side: BorderSide(), // no effect
    //  borderRadius: BorderRadius.only(
    //    topLeft: Radius.circular(8.0),
    //    topRight: Radius.circular(8.0),
    //    //bottomLeft: Radius.circular(-8.0), // no effect
    //    //bottomRight: Radius.circular(-8.0), // no effect
    //  ),
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
    var msg = Container(
      height: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(height: 8, color: Colors.transparent),
          //SizedBox(height: 8),
          Container(
            height: 8,
            //color: Colors.transparent,
            decoration: BoxDecoration(
                color: const Color(0xFF212121),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0x33000000),
                      //offset: Offset(0, 5),
                      blurRadius: 5),
                  BoxShadow(
                      color: const Color(0x1F000000),
                      //offset: Offset(0, 3),
                      blurRadius: 14),
                  BoxShadow(
                      color: const Color(0x3D000000),
                      //offset: Offset(0, 8),
                      blurRadius: 10)
                  //BoxShadow(
                  //    color: const Color(0x33000000),
                  //    offset: Offset(0, -3),
                  //    blurRadius: 5),
                  //BoxShadow(
                  //    color: const Color(0x1F000000),
                  //    offset: Offset(0, -1),
                  //    blurRadius: 18),
                  //BoxShadow(
                  //    color: const Color(0x24000000),
                  //    offset: Offset(0, -6),
                  //    blurRadius: 10),
                ]),
          ),
          Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Text(snack!.message,
                  style: snack!.positive
                      ? Theme.of(context).snackMessage
                      : Theme.of(context).snackMessageBad)),
          Container(
            height: 16,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  // this one is to hide the shadow put on snackbars by default
                  BoxShadow(color: const Color(0xFFFFFFFF), spreadRadius: 1),
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
    if (snack!.link == null && snack!.details == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        elevation: 0,
        backgroundColor: const Color(0xFF212121),
        //shape: RoundedRectangleBorder(borderRadius: shape),
        content: msg,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 102),
        padding: EdgeInsets.only(
          top: 0,
          bottom: 0,
        ),
      ));
    } else if (snack!.link != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          elevation: 0,
          backgroundColor: const Color(0xFF212121),
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
                                  style: Theme.of(context).sendConfirm),
                              actions: [
                                TextButton(
                                    child: Text('Cancel',
                                        style: Theme.of(context)
                                            .sendConfirmButton),
                                    onPressed: () =>
                                        Navigator.of(context).pop()),
                                TextButton(
                                    child: Text('Continue',
                                        style: Theme.of(context)
                                            .sendConfirmButton),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      launch(snack!.link!);
                                    })
                              ])))));
    } else if (snack!.details != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          elevation: 0,
          backgroundColor: const Color(0xFF212121),
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
                              style: Theme.of(context).supportHeading),
                          content: Text(snack!.details!,
                              style: Theme.of(context).sendConfirm),
                          actions: [
                            TextButton(
                                child: Text('Ok',
                                    style: Theme.of(context).sendConfirmButton),
                                onPressed: () => Navigator.of(context).pop())
                          ])))));
    }
    Navigator.popUntil(
        components.navigator.routeContext!, ModalRoute.withName('/home'));
  }
}
