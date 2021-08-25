import 'dart:io';

import 'package:flutter/material.dart';
import '../services/account_mock.dart' as mock;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:raven/init/services.dart';
import 'package:raven/init/reservoirs.dart' as res;

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  void setup() async {
    print('accounts: ${res.accounts.data}');
    print('wallets: ${res.wallets.data}');
    // (flutter) if no accounts -> create account, set default account setting
    if (res.accounts.data.isEmpty) {
      // create one
      var account =
          await accountGenerationService.makeAndAwaitSaveAccount('Primary');
      print(account);
      // set its id as settings default account id
      //sett.settings.add({'default Account': account.id});
    }
    //res.accounts.changes.listen((changes) {
    //  build(context);
    //}); // //sett
    print('accounts: ${res.accounts.data}');
    print('wallets: ${res.wallets.data}');

    /// TODO make sure you wait for all reservoir defaults to be applied here...

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
    await mock.Accounts.instance.load();
    Navigator.pushReplacementNamed(context, '/home', arguments: {
      'account': 'accountId1',
      'accounts': mock.Accounts.instance.accounts,
      'transactions': mock.Accounts.instance.transactions,
      'holdings': mock.Accounts.instance.holdings,
    });
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
            Center(child: SpinKitThreeBounce(color: Colors.white, size: 50.0)));
  }
}
