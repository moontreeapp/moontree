import 'package:flutter/material.dart';
import 'package:raven_front/backdrop/backdrop.dart';
import 'package:raven_back/streams/streams.dart';

void flingBackdrop(BuildContext context) {
  var open = Backdrop.of(context).isBackLayerRevealed ? false : true;
  streams.app.hideNav.add(open);
  streams.app.setting.add(open ? 'open' : null);
  Backdrop.of(context).fling();
}
