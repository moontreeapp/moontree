import 'package:flutter/material.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/utils/data.dart';
import 'package:rxdart/rxdart.dart';

class Loader extends StatefulWidget {
  final String message;
  const Loader({
    this.message = 'Loading...',
  }) : super();

  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  Map<String, dynamic> data = {};
  //final BehaviorSubject stream;
  //final String request;

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    WidgetsBinding.instance!.addPostFrameCallback((_) => afterBuild(context));
    print('build $data');
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

  void afterBuild(BuildContext context) {
    print('afterbuild $data');
    data['stream'].add(data['request']);
  }
}
