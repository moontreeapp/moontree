import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:client_back/client_back.dart';

/// the notifier seems to slow down the animation so we're going to comment it
/// out using /** notifier */ and alternative solution with /** notifier-alt */
/// it didn't seem to help much so I think we may have to do something with
/// an animation with vsync on this widget or something, idk.

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.appContext,
  }) : super(key: key);

  final AppContext appContext;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];
  bool ignoring = false;
  static const double minExtent = .065; //.0736842105263158;
  //minExtent = 1-(MediaQuery.of(context).size.height - 56)  // pix
  final Duration animationDuration = const Duration(milliseconds: 300);
  late final ScrollController _scrollController = ScrollController();
  late AnimationController _slideController;
  late final Animation<Offset> _slideAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0, 1 - minExtent),
  ).animate(CurvedAnimation(
    parent: _slideController,
    curve: Curves.easeInOut,
  ));

  @override
  void initState() {
    super.initState();
    _slideController =
        AnimationController(vsync: this, duration: animationDuration);
    listeners.add(streams.app.fling.listen((bool? value) async {
      if (value != null) {
        await fling(value == false ? value : null);
        streams.app.fling.add(null);
      }
    }));
  }

  @override
  void dispose() {
    _slideController.dispose();
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropLayers(
      back: const NavMenu(),
      front: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          SlideTransition(
            position: _slideAnimation,
            child: FrontCurve(
                child: IgnorePointer(ignoring: ignoring, child: assetHomeView)),
          ),
          AnimatedBuilder(
              animation: _slideAnimation,
              builder: (BuildContext context, _) {
                return Transform.translate(
                    offset: Offset(0.0, _slideController.value * 140),
                    child: NavBar(
                      appContext: widget.appContext,
                      placeholderManage:
                          !services.developer.advancedDeveloperMode,
                      placeholderSwap:
                          !services.developer.advancedDeveloperMode,
                    ));
              }),
        ],
      ),
    );
  }

  Widget get assetHomeView => Container(
        child: widget.appContext == AppContext.wallet
            ? HoldingList(scrollController: _scrollController)
            : widget.appContext == AppContext.manage
                ? !services.developer.advancedDeveloperMode
                    ? ComingSoonPlaceholder(
                        scrollController: _scrollController,
                        message: 'Create & Manage Assets',
                        placeholderType: PlaceholderType.asset)
                    // ignore: dead_code
                    : AssetList(scrollController: _scrollController)
                : true
                    ? ComingSoonPlaceholder(
                        scrollController: _scrollController,
                        message: 'Decentralized Asset Swaps',
                        placeholderType: PlaceholderType.swap)
                    // ignore: dead_code
                    : ListView(
                        controller: _scrollController,
                        children: const <Widget>[
                          Text('swap\n\n\n\n\n\n\n\n\n\n\n\n'),
                        ],
                      ),
      );

  Future<void> fling([bool? open]) async {
    if ((open ?? false)) {
      await flingDown();
    } else if (!(open ?? true)) {
      await flingUp();
    } else if (_slideController.isCompleted) {
      await flingUp();
    } else {
      await flingDown();
    }
  }

  Future<void> flingDown() async {
    streams.app.setting.add('/settings');
    _scrollController.animateTo(
      0,
      duration: animationDuration,
      curve: Curves.easeInOut,
    );
    await _slideController.forward();
    setState(() {
      ignoring = true;
    });
  }

  Future<void> flingUp() async {
    /// trigger this when you change wallets streams.client.busy
    streams.app.setting.add(null);
    await _slideController.reverse();
    setState(() {
      ignoring = false;
    });
  }
}