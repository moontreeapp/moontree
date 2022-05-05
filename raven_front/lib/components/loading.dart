import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/widgets/widgets.dart';

class LoadingComponents {
  Future<void> screen({
    BuildContext? context,
    String? message,
    int? playCount,
    bool returnHome = true,
    Function? then,
    bool staticImage = false,
  }) async {
    await showModalBottomSheet<void>(
        context: context ?? components.navigator.routeContext!,
        enableDrag: false,
        elevation: 0,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.transparent,
        shape: components.shape.topRounded8,
        builder: (BuildContext context) => Loader(
              message: message ?? 'Loading',
              playCount: playCount,
              returnHome: returnHome,
              then: then,
              staticImage: staticImage,
            ));
  }
}
