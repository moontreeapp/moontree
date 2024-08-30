/// this status component should track the status of the app - if the user has
/// the app open and active or not - on change it should notify a stream below
/// in the raven lib so that certain logic can be executed given each case.
/// as such, I think this component need to be attached to each page.

import 'package:flutter/material.dart';
//import 'package:magic/infrastructure/streams/streams.dart' as streams;
import 'package:magic/cubits/cubit.dart';

const AppLifecycleReactor status = AppLifecycleReactor();

class AppLifecycleReactor extends StatefulWidget {
  const AppLifecycleReactor({Key? key}) : super(key: key);

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

  late AppLifecycleState _notification = AppLifecycleState.resumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //streams.app.active.status.add(state.name);
    cubits.app.update(status: state.name);
    setState(() {
      _notification = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(visible: false, child: Text(_notification.name));
  }
}
