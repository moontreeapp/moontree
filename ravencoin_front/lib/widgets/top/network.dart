import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/components/components.dart';

class ChosenBlockchain extends StatefulWidget {
  ChosenBlockchain({Key? key}) : super(key: key);

  @override
  _ChosenBlockchainState createState() => _ChosenBlockchainState();
}

class _ChosenBlockchainState extends State<ChosenBlockchain> {
  List<StreamSubscription> listeners = [];
  late String pageTitle = '';

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.page.listen((value) {
      if (value != pageTitle) {
        setState(() {
          pageTitle = value;
        });
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
    return pageTitle == 'Login'
        ? Container()
        : GestureDetector(
            onTap: () => Navigator.of(components.navigator.routeContext!)
                .pushNamed('/settings/network/blockchain'),
            child: Container(
                width: 36,
                alignment: Alignment.center,
                child: Text('RVN',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600))),
          );
  }
}
