import 'package:rxdart/rxdart.dart';

enum NavHeight { tall, short, none }

class AppStreams {
  final status = appStatus$;
  final active = appActive$;
  final ping = Stream.periodic(Duration(seconds: 60));
  final tap = BehaviorSubject<bool?>.seeded(null);
  final verify = BehaviorSubject<bool>.seeded(false);
  final page = BehaviorSubject<String>.seeded('main');
  final setting = BehaviorSubject<String?>.seeded(null);
  final xlead = BehaviorSubject<bool>.seeded(false);
  final context = BehaviorSubject<AppContext>.seeded(AppContext.login);
  final snack = BehaviorSubject<Snack?>.seeded(null);
  final navHeight = BehaviorSubject<NavHeight>.seeded(NavHeight.none);
  final fling = BehaviorSubject<bool?>.seeded(null);
  final splash = BehaviorSubject<bool>.seeded(true);
  final triggers = BehaviorSubject<ThresholdTrigger?>.seeded(null);
  final loading = BehaviorSubject<bool>.seeded(false);
  final keyboard = BehaviorSubject<KeyboardStatus?>.seeded(null);
  //final locked = BehaviorSubject<bool>.seeded(false);
  final logout = BehaviorSubject<bool>.seeded(false);
  final scrim = BehaviorSubject<bool>.seeded(false);
  final authenticating = BehaviorSubject<bool>.seeded(
      false); // if we are minimized because of local auth do not logout
  final browsing = BehaviorSubject<bool>.seeded(
      false); // if we are minimized because of we are opening browser

  WalletSideStreams wallet = WalletSideStreams();
  ManageSideStreams manage = ManageSideStreams();
  SwapSideStreams swap = SwapSideStreams();
}

enum ThresholdTrigger { backup }

enum KeyboardStatus { up, down }

class WalletSideStreams {
  final asset = BehaviorSubject<String?>.seeded(null);
  final refresh = PublishSubject<bool>();
}

class ManageSideStreams {
  final asset = BehaviorSubject<String?>.seeded(null);
}

class SwapSideStreams {
  final asset = BehaviorSubject<String?>.seeded(null);
}

/// resumed inactive paused detached
final appStatus$ = BehaviorSubject<String?>.seeded('resumed');
final appActive$ = BehaviorSubject<bool>.seeded(true)
  ..addStream(appStatus$.map((status) => status == 'resumed' ? true : false));

class Snack {
  final String message;
  // not used
  final bool positive;
  final String? details; // if they click on the message, popup details
  final String? label; // link label
  final String? link;
  final Map<String, dynamic>? arguments;
  final bool showOnLogin;

  Snack({
    required this.message,
    this.positive = true,
    this.details,
    this.link,
    this.arguments,
    this.label,
    this.showOnLogin = false,
  });

  @override
  String toString() {
    return 'Snack(message: $message, positive: $positive, details: $details, '
        'label: $label, link: $link, arguments: $arguments, '
        'showOnLogin: $showOnLogin)';
  }
}

enum AppContext { login, wallet, manage, swap }
