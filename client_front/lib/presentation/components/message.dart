import 'package:flutter/material.dart';
import 'package:client_front/presentation/components/components.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_back/client_back.dart';

class MessageComponents {
  Future<void> giveChoices(
    BuildContext context, {
    required Map<String, VoidCallback> behaviors,
    String? title = 'Open in External App',
    String? content = 'Open discord app or browser?',
    Widget? child,
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
              content: child != null && content != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                            width: MediaQuery.of(context).size.width -
                                (24 - 24 - 40 - 40),
                            child: Text(content,
                                overflow: TextOverflow.fade,
                                softWrap: true,
                                maxLines: 10,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(color: AppColors.black38))),
                        child,
                      ],
                    )
                  : child ??
                      (content != null
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width -
                                  (24 - 24 - 40 - 40),
                              child: Text(content,
                                  overflow: TextOverflow.fade,
                                  softWrap: true,
                                  maxLines: 10,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(color: AppColors.black38)))
                          : null),
              actions: <Widget>[
                for (String key in behaviors.keys)
                  TextButton(
                      onPressed: behaviors[key],
                      child: Text(key,
                          style: Theme.of(context).textTheme.button!.copyWith(
                              fontWeight: FontWeights.semiBold,
                              color: AppColors.primary)))
              ]);
        }).then((dynamic value) => streams.app.scrim.add(false));
  }
}
