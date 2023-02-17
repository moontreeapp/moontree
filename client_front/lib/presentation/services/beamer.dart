import 'package:beamer/beamer.dart';
import 'package:client_front/presentation/pagesv2/empty/location.dart';
import 'package:client_front/presentation/pages/login/location.dart';
import 'package:client_front/presentation/pagesv2/manage/location.dart';
import 'package:client_front/presentation/pagesv2/menu/location.dart';
import 'package:client_front/presentation/pagesv2/settings/location.dart';
import 'package:client_front/presentation/pagesv2/wallet/location.dart';
import 'package:flutter/material.dart';

class BeamerService {
  late BeamerDelegate rootDelegate;
  BeamerService();

  final Back back = Back(
    label: 'backBeamerKey',
    beamLocations: [
      BackWalletLocation(),
      BackMenuLocation(),
      BackEmptyLocation(),
    ],
  );
  final Front front = Front(
    label: 'frontBeamerKey',
    beamLocations: [
      FrontLoginLocation(),
      FrontWalletLocation(),
      FrontMenuLocation(),
      FrontManageLocation(),
      // add splash screen(),
      // add login / create process(),
    ],
  );
}

abstract class WrappedBeamer {
  late final GlobalKey<BeamerState> key;
  late final BeamerDelegate delegate;
  late final Beamer beamer;

  WrappedBeamer({
    required label,
    required List<BeamLocation<RouteInformationSerializable<dynamic>>>
        beamLocations,
  }) {
    key = GlobalKey<BeamerState>(debugLabel: label);
    delegate = BeamerDelegate(
      locationBuilder: BeamerLocationBuilder(beamLocations: beamLocations),
    );
    beamer = Beamer(key: key, routerDelegate: delegate);
  }

  Beamer call() => beamer;
}

class Back extends WrappedBeamer {
  Back({
    required label,
    required List<BeamLocation<RouteInformationSerializable<dynamic>>>
        beamLocations,
  }) : super(label: label, beamLocations: beamLocations);
}

class Front extends WrappedBeamer {
  Front({
    required label,
    required List<BeamLocation<RouteInformationSerializable<dynamic>>>
        beamLocations,
  }) : super(label: label, beamLocations: beamLocations);
}
