import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/utils/auth.dart';
import 'package:client_front/widgets/widgets.dart';

class BackdropAppBar extends StatefulWidget implements PreferredSizeWidget {
  const BackdropAppBar({Key? key}) : super(key: key);

  @override
  State<BackdropAppBar> createState() => _BackdropAppBarState();

  @override
  Size get preferredSize => const Size(double.infinity, 56);
}

class _BackdropAppBarState extends State<BackdropAppBar> {
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];
  String pageTitle = '';

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.page.listen((String value) {
      if (value != pageTitle) {
        setState(() {
          pageTitle = value;
        });
      }
    }));

    /// this is here because we trigger logouts on backend.
    /// maybe we could call it from the back, but originally it seemed better to
    /// pass it to the front layer and have it do it, also because other things
    /// could listen to the logout behavior. could use a refactor.
    listeners.add(streams.app.logout.listen((bool value) {
      if (value && streams.app.page.value != 'Login') {
        logout();
      }
    }));
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return streams.app.splash.value
        ? PreferredSize(preferredSize: Size.zero, child: Container(height: 0))
        : BackdropAppBarContents();
  }
}
