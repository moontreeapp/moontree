import 'package:flutter/material.dart';
import 'package:client_front/components/components.dart';
import 'package:client_front/widgets/widgets.dart';

class LoadingComponents {
  Future<void> screen({
    BuildContext? context,
    String? message,
    int? playCount,
    bool returnHome = true,
    Function? then,
    bool staticImage = false,
  }) async =>
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
                //staticImage: staticImage,
              ));

  /// unable to get this to work yet:
/*
  import 'package:flutter/foundation.dart';
  Future<T> screenCompute<T>({
    required T Function() during,
    BuildContext? context,
    String? message,
    int? playCount,
    bool returnHome = true,
    Function? then,
    bool staticImage = false,
  }) async {
    showModalBottomSheet<void>(
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
    return await compute((_) async =>  during(), null);
  }
  */
}
