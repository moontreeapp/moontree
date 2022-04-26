import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            /// makes a black area for the clock -- superceeded by SafeArea
            /// and black backgroundColor on Scaffold
            //systemOverlayStyle: SystemUiOverlayStyle(
            //  // Status bar color
            //  statusBarColor: Colors.red, //Colors.black,
            //  // Status bar brightness (optional)
            //  statusBarIconBrightness: Brightness.light, // For Android
            //  statusBarBrightness: Brightness.dark, // For iOS
            //),

            /// rounded top corners
            shape: components.shape.topRounded,
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
              PeristentKeyboardWatcher(),
            ],
          );
  }
}
