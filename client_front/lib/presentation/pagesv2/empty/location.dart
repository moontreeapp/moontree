import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:client_front/presentation/pagesv2/empty/screen.dart';

class BackEmptyLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns =>
      ['/empty', '/wallet/holdings', '/login/create'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      [const BeamPage(child: EmptyScreen())];
}
