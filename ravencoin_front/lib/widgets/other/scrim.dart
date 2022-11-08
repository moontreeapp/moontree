import 'package:flutter/material.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_back/streams/streams.dart';

class ScrimPro extends StatefulWidget {
  final String pageTitle;
  final bool light;

  ScrimPro({
    Key? key,
    this.pageTitle = 'Home',
    this.light = true,
  }) : super(key: key);

  @override
  _ScrimProState createState() => _ScrimProState();
}

class _ScrimProState extends State<ScrimPro> {
  Color scrimColor = AppColors.scrim;
  HitTestBehavior? behavior = HitTestBehavior.opaque;
  late List listeners = [];

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.scrimpro.listen((bool? value) async {
      if (value == true) {
        activateScrim();
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

  void activateScrim() {
    setState(() {
      scrimColor = AppColors.scrim;
      behavior = HitTestBehavior.opaque;
    });
  }

  void removeScrim() {
    streams.app.scrimpro.add(false);
    setState(() {
      scrimColor = Colors.transparent;
      behavior = null;
    });
  }

  @override
  Widget build(BuildContext context) => behavior == null
      ? Container()
      : GestureDetector(
          onTap: behavior == null ? () {} : removeScrim,
          behavior: behavior,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: scrimColor,
                ),
              ),
            ],
          ),
        );
}
