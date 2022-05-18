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

import 'asset_details/asset_details_bloc.dart';

class Transactions extends StatefulWidget {
  const Transactions({Key? key}) : super(key: key);

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  late List<StreamSubscription> listeners = [];
  Widget? cachedMetadataView;
  DraggableScrollableController dController = DraggableScrollableController();
  @override
  void initState() {
    super.initState();
    assetDetailsBloc.reset();
    listeners.add(streams.client.busy.listen((bool value) {
      if (!value) {
        setState(() {});
      }
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    assetDetailsBloc.scrollObserver.close();
    super.dispose();
  }

  AssetDetailsBloc get bloc => assetDetailsBloc;

  @override
  Widget build(BuildContext context) {
    bloc.data = populateData(context, bloc.data);

    cachedMetadataView = _metadataView(bloc.security, context);
    minHeight =
        0.65.figmaAppHeight + (cachedMetadataView != null ? 48.ofAppHeight : 0);
    var maxExtent = (bloc.currentTxs.length * 80 +
            80 +
            40 +
            (!services.download.history.isComplete ? 80 : 0))
        .ofMediaHeight(context);
    return BackdropLayers(
      back: CoinDetailsHeader(bloc.security, cachedMetadataView),
      front: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          DraggableScrollableSheet(
              initialChildSize: minHeight,
              minChildSize: minHeight,
              maxChildSize: min(1.0, max(minHeight, maxExtent)),
              controller: dController,
              builder: (context, scrollController) {
                bloc.scrollObserver.add(dController.size);
                return CoinDetailsGlidingSheet(
                  _metadataView(bloc.security, context),
                  dController,
                  scrollController,
                );
              }),
          AssetNavbar()
        ],
      ),
    );
  }

  Widget? _metadataView(Security security, BuildContext context) {
    var securityAsset = security.asset;
    if (securityAsset == null || securityAsset.hasMetadata == false) {
      return null;
    }
    var chilren = <Widget>[];
    if (securityAsset.primaryMetadata == null &&
        securityAsset.hasData &&
        securityAsset.data!.isIpfs) {
      return Container(
        alignment: Alignment.topCenter,
        height: (assetDetailsBloc.scrollObserver.value.ofMediaHeight(context) +
                16 +
                16) /
            2,
        child: Padding(
          padding: EdgeInsets.only(top: 16),
          child: components.buttons.actionButtonSoft(
            context,
            label: 'View Data',
            onPressed: () => components.message.giveChoices(
              context,
              title: 'View Data',
              content: 'View data in external browser?',
              behaviors: {
                'CANCEL': Navigator.of(context).pop,
                'BROWSER': () {
                  Navigator.of(context).pop();
                  launch('https://ipfs.io/ipfs/${securityAsset.metadata}');
                },
              },
            ),
          ),
        ),
      );
    } else if (securityAsset.primaryMetadata == null) {
      chilren = [SelectableText(securityAsset.metadata)];
    } else if (securityAsset.primaryMetadata!.kind == MetadataType.ImagePath) {
      chilren = [
        Image.file(AssetLogos()
            .readImageFileNow(securityAsset.primaryMetadata!.data ?? ''))
      ];
    } else if (securityAsset.primaryMetadata!.kind == MetadataType.JsonString) {
      chilren = [SelectableText(securityAsset.primaryMetadata!.data ?? '')];
    } else if (securityAsset.primaryMetadata!.kind == MetadataType.Unknown) {
      chilren = [
        SelectableText(securityAsset.primaryMetadata!.metadata),
        SelectableText(securityAsset.primaryMetadata!.data ?? '')
      ];
    }
    return ListView(padding: EdgeInsets.all(10.0), children: chilren);
  }
}



