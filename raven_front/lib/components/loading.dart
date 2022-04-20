import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/widgets/widgets.dart';

class LoadingComponents {
  Future<void> screen({
    BuildContext? context,
    String? message,
    bool staticImage = false,
    bool returnHome = true,
  }) async {
    await showModalBottomSheet<void>(
        context: context ?? components.navigator.routeContext!,
        enableDrag: false,
        elevation: 0,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0))),
        builder: (BuildContext context) => Loader(
              message: message ?? 'Loading',
              returnHome: returnHome,
              staticImage: staticImage,
            ));
  }
}
