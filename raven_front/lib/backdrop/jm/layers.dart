import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/theme.dart';

class BackdropLayers extends StatefulWidget {
  final Widget? back;
  final Widget? front;
  const BackdropLayers({Key? key, this.back, this.front}) : super(key: key);

  @override
  State<BackdropLayers> createState() => _BackdropLayersState();
}

class _BackdropLayersState extends State<BackdropLayers> {
  List<StreamSubscription> listeners = [];

  @override
  void initState() {
    super.initState();

    /// refresh?
    //  listeners.add(
    //      res.vouts.batchedChanges.listen((List<Change<Vout>> batchedChanges) {
    //    // if vouts in our account has changed...
    //    if (batchedChanges
    //        .where(
    //            (change) => change.data.address?.wallet?.id == Current.walletId)
    //        .isNotEmpty) {
    //      setState(() {});
    //    }
    //  }));
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
    return Expanded(
      child: Stack(children: [
        Container(
            color: Colors.transparent,
            alignment: Alignment.topCenter,
            child: widget.back),
        Container(
            color: Colors.transparent,
            alignment: Alignment.bottomCenter,
            child: widget.front),
      ]),
    );
  }
}
