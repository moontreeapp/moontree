import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/streams.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/services/account.dart';
import 'package:raven_front/theme/extensions.dart';

class NavDrawerBody extends StatefulWidget {
  final Widget child;

  NavDrawerBody({Key? key, required this.child}) : super(key: key);

  @override
  _NavDrawerBodyState createState() => _NavDrawerBodyState();
}

class _NavDrawerBodyState extends State<NavDrawerBody> {
  List listeners = [];

  @override
  void initState() {
    super.initState();
    //listeners.add(streams.app.page.stream.listen((value) {
    //  if (value != pageTitle) {
    //    setState(() {
    //      pageTitle = value;
    //    });
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
    return Container(
        padding: EdgeInsets.only(top: 80), //23+56
        color: Theme.of(context).backgroundColor,
        child:
            //Column(children: <Widget>[
            //  Text('test'),
            Container(
                child: widget.child,
                // if color below are not transparent, push it down
                //padding: EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8.0),
                        topLeft: Radius.circular(8.0)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0x33000000),
                          offset: Offset(1, 0),
                          blurRadius: 5),
                    ]))
        //])
        );
  }
}
