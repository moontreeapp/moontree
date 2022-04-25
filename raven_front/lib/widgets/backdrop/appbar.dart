import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_front/components/components.dart';

class BackdropAppBar extends StatefulWidget implements PreferredSizeWidget {
  const BackdropAppBar({Key? key}) : super(key: key);

  @override
  State<BackdropAppBar> createState() => _BackdropAppBarState();

  @override
  Size get preferredSize => const Size(double.infinity, 56);
}

class _BackdropAppBarState extends State<BackdropAppBar> {
  late List listeners = [];

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.splash.listen((bool value) {
      setState(() {});
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
    return streams.app.splash.value
        ? PreferredSize(preferredSize: Size(0, 0), child: Container(height: 0))
        : AppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            automaticallyImplyLeading: false,
            elevation: 0,
            leading: streams.app.page.value == 'Login'
                ? null
                : PageLead(mainContext: context),
            title: /*FittedBox(fit: BoxFit.fitWidth, child: */ PageTitle() /*)*/,
            actions: <Widget>[
              components.status,
              ConnectionLight(),
              QRCodeContainer(),
              SnackBarViewer(),
              SizedBox(width: 6),
            ],
          );
  }
}
