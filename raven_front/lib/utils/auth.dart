import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';

Future logout() async {
  res.ciphers.clear();
  Navigator.pushReplacementNamed(
      components.navigator.routeContext!, '/security/login',
      arguments: {});
  streams.app.splash.add(false);
}
