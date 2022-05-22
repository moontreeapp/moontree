import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/pages/wallet/asset_details/assset_details_components.dart';
import 'package:raven_front/services/storage.dart';
import 'package:raven_front/utils/data.dart';
import 'package:raven_front/utils/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_front/components/components.dart';
import 'package:url_launcher/url_launcher.dart';

import 'asset_details_bloc.dart';

class Transactions extends StatefulWidget {
  const Transactions({Key? key}) : super(key: key);

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  DraggableScrollableController dController = DraggableScrollableController();
  @override
  void initState() {
    super.initState();
    assetDetailsBloc.reset();
  }

  @override
  void dispose() {
    super.dispose();
  }

  AssetDetailsBloc get bloc => assetDetailsBloc;

  @override
  Widget build(BuildContext context) {
    bloc.data = populateData(context, bloc.data);

    minHeight = 0.65.figmaAppHeight + (bloc.nullCacheView ? 0 : 48.ofAppHeight);
    return BackdropLayers(
      back: CoinDetailsHeader(bloc.security, bloc.nullCacheView),
      front: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          DraggableScrollableSheet(
              initialChildSize: minHeight,
              minChildSize: minHeight,
              maxChildSize: min(1.0, max(minHeight, getMaxExtent(context))),
              controller: dController,
              builder: (context, scrollController) {
                bloc.scrollObserver.add(dController.size);
                return CoinDetailsGlidingSheet(
                  bloc.nullCacheView ? null : MetadataView(),
                  dController,
                  scrollController,
                );
              }),
          AssetNavbar()
        ],
      ),
    );
  }

  double getMaxExtent(BuildContext context) {
    return (bloc.currentTxs.length * 80 +
            80 +
            40 +
            (!services.download.history.isComplete ? 80 : 0))
        .ofMediaHeight(context);
  }
}
