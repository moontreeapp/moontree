import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/components/components.dart';

class Loader extends StatefulWidget {
  final String message;
  const Loader({this.message = 'Loading...'}) : super();

  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  late List listeners = [];

  @override
  void initState() {
    super.initState();
    //listeners.add(streams.app.import.success.listen((bool? value) {
    //  if (value ?? false) {
    //    Navigator.popUntil(
    //        components.navigator.routeContext!, ModalRoute.withName('/home'));
    //  } else {
    //    Navigator.of(components.navigator.routeContext!).pop();
    //  }
    //}));
    //listeners.add(streams.app.spending.success.listen((bool? value) {
    //  if (value ?? false) {
    //    Navigator.popUntil(
    //        components.navigator.routeContext!, ModalRoute.withName('/home'));
    //  } else {
    //    Navigator.of(components.navigator.routeContext!).pop();
    //  }
    //}));
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
    // maybe on click just go home?
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(widget.message, style: Theme.of(context).loaderText),
          SizedBox(height: 4),
          Image.asset('assets/logo/moontree_logo_56.png',
              height: 56, width: 56),
        ]);
  }
}
