import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:client_front/presentation/pagesv2/manage/screen.dart';
import 'package:client_front/presentation/utilities/animation.dart';

class FrontManageLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => ['/manage'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      [const FadeTransitionPage(child: ManageScreen())];
}
