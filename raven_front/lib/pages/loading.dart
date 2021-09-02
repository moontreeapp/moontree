import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:raven/raven.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Future setupAccounts() async {
    await accountGenerationService.makeAndAwaitSaveAccount('Primary');
    await accountGenerationService.makeAndAwaitSaveAccount('Savings');
    await addressSubscriptionService
        .saveScripthashHistoryData(ScripthashHistoriesData(
      [
        Address(
            accountId: '0',
            walletId: '',
            address: '',
            hdIndex: -1,
            scripthash: '')
      ],
      [
        [ScripthashHistory(height: 0, txHash: 'abc1')]
      ],
      [
        [
          ScripthashUnspent(
              height: 0,
              txHash: 'abc2',
              scripthash: '',
              txPos: 0,
              value: 1000000000)
        ]
      ],
      [
        [
          ScripthashUnspent(
              height: 0,
              txHash: 'abc3',
              scripthash: '',
              txPos: 0,
              value: 5000000000,
              ticker: 'Magic Musk')
        ]
      ],
    ));
  }

  void setup() async {
    if (accounts.data.isEmpty) {
      await setupAccounts();
    }
    print('accounts: ${accounts.data}');
    print('wallets: ${wallets.data}');
    print('addresses: ${addresses.data}');
    print('histories: ${histories.data}');
    print('balances: ${balances.data}');
    print('rates: ${rates.data}');
    print('settings: ${settings.data}');
    // sleeping avoids error
    await Future.delayed(Duration(seconds: 1));
    sleep(Duration(seconds: 1));

    Navigator.pushReplacementNamed(context, '/home', arguments: {});

    /* I think this is being triggered by init process in raven because I removed new blocks stuff and it still happens...

    https://stackoverflow.com/questions/44485760/flutter-cannot-build-because-the-frawework-is-already-building
    https://stackoverflow.com/questions/57605244/this-overlay-widget-cannot-be-marked-as-needing-to-build-because-the-framework-i


    E/flutter ( 7699): [ERROR:flutter/lib/ui/ui_dart_state.cc(209)] Unhandled Exception: setState() or markNeedsBuild() called during build.
    E/flutter ( 7699): This Overlay widget cannot be marked as needing to build because the framework is already in the process of building widgets.  A widget can be marked as needing to be built during the build phase only if one of its ancestors is currently building. This exception is allowed because the framework builds parent widgets before children, which means a dirty descendant will always be built. Otherwise, the framework might not visit this widget during this build phase.
    E/flutter ( 7699): The widget on which setState() or markNeedsBuild() was called was:
    E/flutter ( 7699):   Overlay-[LabeledGlobalKey<OverlayState>#4d872]
    E/flutter ( 7699): The widget which was currently being built when the offending call was made was:
    E/flutter ( 7699):   Builder
    E/flutter ( 7699): #0      Element.markNeedsBuild.<anonymous closure> (package:flutter/src/widgets/framework.dart:4305:11)
    E/flutter ( 7699): #1      Element.markNeedsBuild (package:flutter/src/widgets/framework.dart:4320:6)
    E/flutter ( 7699): #2      State.setState (package:flutter/src/widgets/framework.dart:1108:15)
    E/flutter ( 7699): #3      OverlayState.rearrange (package:flutter/src/widgets/overlay.dart:438:5)
    E/flutter ( 7699): #4      NavigatorState._flushHistoryUpdates (package:flutter/src/widgets/navigator.dart:4096:16)
    E/flutter ( 7699): #5      NavigatorState._pushReplacementEntry (package:flutter/src/widgets/navigator.dart:4752:5)
    E/flutter ( 7699): #6      NavigatorState.pushReplacement (package:flutter/src/widgets/navigator.dart:4681:5)
    E/flutter ( 7699): #7      NavigatorState.pushReplacementNamed (package:flutter/src/widgets/navigator.dart:4311:12)
    E/flutter ( 7699): #8      Navigator.pushReplacementNamed (package:flutter/src/widgets/navigator.dart:1860:34)
    E/flutter ( 7699): #9      _LoadingState.setup (package:raven_mobile/pages/loading.dart:65:15)
    */

    /// TODO running into this error on occasion...
    /// E/flutter (12132): [ERROR:flutter/lib/ui/ui_dart_state.cc(209)] Unhandled Exception: SocketException: Connection timed out, host: testnet.rvn.rocks, port: 50002
    /// E/flutter (12132): #0      _NativeSocket.connect.<anonymous closure>.<anonymous closure> (dart:io-patch/socket_patch.dart:920:11)
    /// E/flutter (12132): #1      _rootRun (dart:async/zone.dart:1420:47)
    /// E/flutter (12132): #2      _CustomZone.run (dart:async/zone.dart:1328:19)
    /// E/flutter (12132): #3      Future.timeout.<anonymous closure> (dart:async/future_impl.dart:865:34)
    /// E/flutter (12132): #4      _rootRun (dart:async/zone.dart:1420:47)
    /// E/flutter (12132): #5      _CustomZone.run (dart:async/zone.dart:1328:19)
    /// E/flutter (12132): #6      _CustomZone.runGuarded (dart:async/zone.dart:1236:7)
    /// E/flutter (12132): #7      _CustomZone.bindCallbackGuarded.<anonymous closure> (dart:async/zone.dart:1276:23)
    /// E/flutter (12132): #8      _rootRun (dart:async/zone.dart:1428:13)
    /// E/flutter (12132): #9      _CustomZone.run (dart:async/zone.dart:1328:19)
    /// E/flutter (12132): #10     _CustomZone.bindCallback.<anonymous closure> (dart:async/zone.dart:1260:23)
    /// E/flutter (12132): #11     Timer._createTimer.<anonymous closure> (dart:async-patch/timer_patch.dart:18:15)
    /// E/flutter (12132): #12     _Timer._runTimers (dart:isolate-patch/timer_impl.dart:395:19)
    /// E/flutter (12132): #13     _Timer._handleMessage (dart:isolate-patch/timer_impl.dart:426:5)
    /// E/flutter (12132): #14     _RawReceivePortImpl._handleMessage (dart:isolate-patch/isolate_patch.dart:184:12)
    /// E/flutter (12132):
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(child: Text('Loading...')
            //SpinKitThreeBounce(color: Colors.white, size: 50.0)
            ));
  }
}
