import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/utils/auth.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class BackdropAppBar extends StatefulWidget implements PreferredSizeWidget {
  const BackdropAppBar({Key? key}) : super(key: key);

  @override
  State<BackdropAppBar> createState() => _BackdropAppBarState();

  @override
  Size get preferredSize => const Size(double.infinity, 56);
}

class _BackdropAppBarState extends State<BackdropAppBar> {
  late List listeners = [];
  LeadIcon lead = LeadIcon.pass;

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.splash.listen((bool value) {
      setState(() {});
    }));
    listeners.add(streams.app.logout.listen((bool value) {
      if (value && streams.app.page.value != 'Login') {
        logout();
      }
    }));
    listeners.add(streams.app.lead.listen((LeadIcon value) {
      if (lead != value) {
        setState(() => lead = value);
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
    return streams.app.splash.value
        ? PreferredSize(preferredSize: Size(0, 0), child: Container(height: 0))
        : BackdropAppBarContents();
  }
}
