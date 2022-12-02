import 'dart:async';

import 'package:flutter/material.dart';

class BackdropLayers extends StatefulWidget {
  final Widget back;
  final Widget front;
  final Color? backColor;
  final Color? frontColor;
  final double? backHeight;
  final double? frontHeight;
  final Alignment? backAlignment;
  final Alignment? frontAlignment;

  const BackdropLayers({
    Key? key,
    required this.back,
    required this.front,
    this.backColor,
    this.frontColor,
    this.backHeight,
    this.backAlignment,
    this.frontAlignment,
    this.frontHeight,
  }) : super(key: key);

  @override
  State<BackdropLayers> createState() => _BackdropLayersState();
}

class _BackdropLayersState extends State<BackdropLayers> {
  List<StreamSubscription> listeners = [];

  @override
  void initState() {
    super.initState();

    /// refresh? fling?
    //  listeners.add(
    //      pros.vouts.batchedChanges.listen((List<Change<Vout>> batchedChanges) {
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
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
          color: widget.backColor ?? Theme.of(context).backgroundColor,
          height: widget.backHeight,
          alignment: widget.backAlignment ?? Alignment.topCenter,
          child: widget.back),
      Container(
        color: widget.frontColor ?? null,
        height: widget.frontHeight,
        alignment: widget.frontAlignment ?? Alignment.bottomCenter,
        child: widget.front,
      ),
    ]);
  }
}
