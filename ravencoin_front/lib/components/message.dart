import 'package:flutter/material.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

class MessageComponents {
  Future<void> giveChoices(
    BuildContext context, {
    required Map<String, VoidCallback> behaviors,
    String? title = 'Open in External App',
    String? content = 'Open discord app or browser?',
  }) async {
    // add scrim to appbar with stream here?
    await showDialog(
        context: context,
        barrierColor: AppColors.black38,
        useSafeArea: false,
        builder: (BuildContext context) {
          streams.app.scrim.add(true);
          return AlertDialog(
              elevation: 0,
              shape: components.shape.rounded8,
              title: title == null
                  ? null
                  : Text(title, style: Theme.of(context).textTheme.headline2),
              content: content == null
                  ? null
                  : Container(
                      height: 24,
                      width: MediaQuery.of(context).size.width -
                          (24 - 24 - 40 - 40),
                      child: Text(content,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(color: AppColors.black38))),
              actions: [
                for (var key in behaviors.keys)
                  TextButton(
                      child: Text(key,
                          style: Theme.of(context).textTheme.button!.copyWith(
                              fontWeight: FontWeights.semiBold,
                              color: AppColors.primary)),
                      onPressed: behaviors[key])
              ]);
        }).then((value) => streams.app.scrim.add(false));
  }
}
