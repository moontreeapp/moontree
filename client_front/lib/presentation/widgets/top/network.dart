import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/components/components.dart';

class ChosenBlockchain extends StatefulWidget {
  const ChosenBlockchain({Key? key}) : super(key: key);

  @override
  _ChosenBlockchainState createState() => _ChosenBlockchainState();
}

class _ChosenBlockchainState extends State<ChosenBlockchain> {
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  late String pageTitle = '';

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
    return pageTitle == 'Login'
        ? Container()
        : GestureDetector(
            onTap: () => Navigator.of(components.routes.routeContext!)
                .pushNamed('/settings/network/blockchain'),
            child: Container(
                width: 36,
                alignment: Alignment.center,
                child: const Text('RVN',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600))),
          );
  }
}
