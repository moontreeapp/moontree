/// this status component should track the status of the app - if the user has
/// the app open and active or not - on change it should notify a stream below
/// in the raven lib so that certain logic can be executed given each case.
/// as such, I think this component need to be attached to each page.

import 'package:flutter/material.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/utils/log.dart';

const AppLifecycleReactor status = AppLifecycleReactor();

class AppLifecycleReactor extends StatefulWidget {
  const AppLifecycleReactor({super.key});

  @override
  State<AppLifecycleReactor> createState() => _AppLifecycleReactorState();
}

class _AppLifecycleReactorState extends State<AppLifecycleReactor>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //late AppLifecycleState _notification = AppLifecycleState.resumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    see('app state: ${state.name}');
    cubits.app.update(status: state);
    //setState(() {
    //  _notification = state;
    //});
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
