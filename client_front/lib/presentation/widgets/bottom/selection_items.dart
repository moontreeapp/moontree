/// In order to extend the scrim to the entire page, including the app bar...
/// this should probably be a permanent fixture on the main scaffold,
/// which changes based upon a page or messages from a stream... idk, but,
/// for now we'll put it here because it'll be easy to move to main if we want.
import 'dart:math';

import 'package:client_front/presentation/widgets/front_curve.dart';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/presentation/components/shapes.dart' as shapes;
import 'package:client_front/presentation/components/components.dart'
    as components;

enum SelectionOption {
  // list of my assets
  Admins,

  // for admins
  Restricted_Symbol,

  // what to access or create
  Main_Asset,
  Restricted_Asset,
  Qualifier_Asset,
  Admin_Asset,
  NFT_Asset,
  Main,
  Restricted,
  Qualifier,
  Admin,
  Sub_Asset,
  NFT,
  Messaging_Channel_Asset,

  // Main,
  Sub,
  Sub_Admin,
  // NFT,
  // Channel,
  // Admin,
  // Restricted,
  Restricted_Admin,
  // Qualifier,
  Sub_Qualifier,
  QualifierSub,
  Channel,

  // decimals divisibility
  Dec8,
  Dec7,
  Dec6,
  Dec5,
  Dec4,
  Dec3,
  Dec2,
  Dec1,
  Dec0,

  //feedback
  Change,
  Bug,

  // manage
  Reissue,
  Issue_Dividend,

  // Test Widgets
  CustomName,
}

class SimpleSelectionItems {
  SimpleSelectionItems(this.context, {required this.items, this.then});
  final BuildContext context;
  late List<Widget> items;
  late void Function()? then;

  Future<void> build() async {
    await showModalBottomSheet<void>(
        context: context, //components.routes.mainContext!,
        elevation: 1,
        isScrollControlled: true,
        barrierColor: AppColors.black38,
        shape: shapes.topRounded8,
        builder: (BuildContext context) {
          if (streams.app.behavior.scrim.value == false) {
            streams.app.behavior.scrim.add(true);
          }
          final DraggableScrollableController draggableScrollController =
              DraggableScrollableController();
          final double minExtent =
              min((items.length * 52 + 16 + 24).ofMediaHeight(context), 0.5);
          final double initialExtent = minExtent;
          double maxExtent = (items.length * 52 + 16).ofMediaHeight(context);
          maxExtent = min(1.0, max(minExtent, maxExtent));

          /// failed attempt to use set state
          //return StatefulBuilder(builder: (BuildContext context,
          //    StateSetter setState /*You can rename this!*/) {
          return DraggableScrollableSheet(
            controller: draggableScrollController,
            expand: false,
            initialChildSize: initialExtent,
            minChildSize: minExtent,
            maxChildSize: maxExtent,
            builder: (BuildContext context, ScrollController scrollController) {
              return FrontCurve(
                  alignment: Alignment.topCenter,
                  child: ListView(
                    shrinkWrap: true,
                    controller: scrollController,
                    children: <Widget>[
                      ...[const SizedBox(height: 8)],
                      ...items,
                      ...[const SizedBox(height: 8)],
                    ],
                  ));
            },
          );
          //});
        }).then((value) {
      if (streams.app.behavior.scrim.value == true) {
        streams.app.behavior.scrim.add(false);
      }
      if (then != null) {
        then!();
      }
    });
  }
}

class SimpleScrim {
  SimpleScrim(this.context, {this.then});
  final BuildContext context;
  late void Function()? then;

  Future<void> build() async {
    await showModalBottomSheet<void>(
        context: components.routes.routeContext!,
        elevation: 1,
        isScrollControlled: true,
        barrierColor: AppColors.black38,
        shape: shapes.topRounded8,
        builder: (BuildContext context) {
          if (streams.app.behavior.scrim.value == false) {
            streams.app.behavior.scrim.add(true);
          }
          return Container(height: 0);
        }).then((value) {
      if (streams.app.behavior.scrim.value == true) {
        streams.app.behavior.scrim.add(false);
      }
      if (then != null) {
        then!();
      }
    });
  }
}
