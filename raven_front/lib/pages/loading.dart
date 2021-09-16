import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/services/history_mock.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Future setupAccounts() async {
    await accountGenerationService.makeSaveAccount('Primary');
    await accountGenerationService.makeSaveAccount('Savings');
  }

  Future setup() async {
    var hiveInit = HiveInitializer(init: (dbDir) => Hive.initFlutter());
    await hiveInit.setUp();
    await init();
    if (accounts.data.isEmpty) {
      MockHistories().init();
      await setupAccounts();
    }
    settings.setCurrentAccountId();
    print('accounts: ${accounts.data}');
    print('wallets: ${wallets.data}');
    print('addresses: ${addresses.data}');
    print('histories: ${histories.data}');
    print('balances: ${balances.data}');
    print('rates: ${rates.data}');
    print('settings: ${settings.data}');
    Future.microtask(
        () => Navigator.pushReplacementNamed(context, '/home', arguments: {}));

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
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
            Center(child: SpinKitThreeBounce(color: Colors.black, size: 50.0)));
  }
}
