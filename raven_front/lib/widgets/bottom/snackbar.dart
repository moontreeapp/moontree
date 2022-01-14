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
    var msg = Text(snack!.message,
        style: snack!.positive
            ? Theme.of(context).snackMessage
            : Theme.of(context).snackMessageBad);
    if (snack!.link == null) {
      // should I just return a SnackBar?
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: msg,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Color(0xDE000000),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0))),
          content: msg,
          action: SnackBarAction(
              label: snack?.label ?? 'Go',
              onPressed: snack!.link!.startsWith('/')
                  // app page
                  ? () => Navigator.pushNamed(context, snack!.link!,
                      arguments: snack?.arguments ?? {})
                  : snack!.details != null
                      // details
                      ? () => showDialog(
                          context: components.navigator.routeContext!,
                          builder: (BuildContext context) => AlertDialog(
                                  title: Text('Details'),
                                  content: Text(snack!.details!),
                                  actions: [
                                    TextButton(
                                        child: Text('Ok'),
                                        onPressed: () =>
                                            Navigator.of(context).pop())
                                  ]))
                      // external site
                      : () => showDialog(
                          context: components.navigator.routeContext!,
                          builder: (BuildContext context) => AlertDialog(
                                  //title: Text('External App'),
                                  content: Text('Open external app (browser)?'),
                                  actions: [
                                    TextButton(
                                        child: Text('Cancel'),
                                        onPressed: () =>
                                            Navigator.of(context).pop()),
                                    TextButton(
                                        child: Text('Continue'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          launch(snack!.link!);
                                        })
                                  ])))));
    }
  }
}
