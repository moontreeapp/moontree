import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:rxdart/rxdart.dart';

enum NavHeight { tall, short, none }

enum LeadIcon {
  none, // remove
  dismiss, // exit, x (effectively back)
  back, // back arrow
  menu, // hamburger
  pass, // no override logic
}

class AppStreams {
  final BehaviorSubject<String?> status = appStatus$;
  final BehaviorSubject<bool> active = appActive$;
  final Stream<dynamic> ping =
      Stream<dynamic>.periodic(const Duration(seconds: 60 * 2));
  final BehaviorSubject<bool?> tap = BehaviorSubject<bool?>.seeded(null);
  final BehaviorSubject<bool> verify = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<String> page = BehaviorSubject<String>.seeded('main');
  final BehaviorSubject<String?> setting =
      BehaviorSubject<String?>.seeded(null);
  final BehaviorSubject<LeadIcon> lead =
      BehaviorSubject<LeadIcon>.seeded(LeadIcon.pass);
  final BehaviorSubject<AppContext> context =
      BehaviorSubject<AppContext>.seeded(AppContext.login);
  final BehaviorSubject<Snack?> snack = BehaviorSubject<Snack?>.seeded(null);
  final BehaviorSubject<NavHeight> navHeight =
      BehaviorSubject<NavHeight>.seeded(NavHeight.none);
  final BehaviorSubject<bool?> fling = BehaviorSubject<bool?>.seeded(null);
  final BehaviorSubject<bool> splash = BehaviorSubject<bool>.seeded(true);
  final BehaviorSubject<ThresholdTrigger?> triggers =
      BehaviorSubject<ThresholdTrigger?>.seeded(null);
  final BehaviorSubject<bool> loading = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<KeyboardStatus?> keyboard =
      BehaviorSubject<KeyboardStatus?>.seeded(null);
  //final locked = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<bool> logout = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<bool?> scrim =
      BehaviorSubject<bool?>.seeded(false); // null = disable
  final BehaviorSubject<TutorialStatus?> tutorial =
      BehaviorSubject<TutorialStatus?>.seeded(null);
  final BehaviorSubject<bool> authenticating = BehaviorSubject<bool>.seeded(
      false); // if we are minimized because of local auth do not logout
  final BehaviorSubject<bool> browsing = BehaviorSubject<bool>.seeded(
      false); // if we are minimized because of we are opening browser

  WalletSideStreams wallet = WalletSideStreams();
  ManageSideStreams manage = ManageSideStreams();
  SwapSideStreams swap = SwapSideStreams();
}

enum ThresholdTrigger { backup }

enum KeyboardStatus { up, down }

class WalletSideStreams {
  final BehaviorSubject<String?> asset = BehaviorSubject<String?>.seeded(null);
  final PublishSubject<bool> refresh = PublishSubject<bool>();
}

class ManageSideStreams {
  final BehaviorSubject<String?> asset = BehaviorSubject<String?>.seeded(null);
}

class SwapSideStreams {
  final BehaviorSubject<String?> asset = BehaviorSubject<String?>.seeded(null);
}

/// resumed inactive paused detached
final BehaviorSubject<String?> appStatus$ =
    BehaviorSubject<String?>.seeded('resumed');
final BehaviorSubject<bool> appActive$ = BehaviorSubject<bool>.seeded(true)
  ..addStream(appStatus$.map((String? status) => status == 'resumed'));

class Snack {
  Snack({
    required this.message,
    this.positive = true,
    this.details,
    this.label,
    this.link,
    this.copy,
    this.arguments,
    this.showOnLogin = false,
  });

  final String message;
  // not used
  final bool positive;
  final String? details; // if they click on the message, popup details
  final String? label; // link label
  final String? link;
  final String? copy;
  final Map<String, dynamic>? arguments;
  final bool showOnLogin;

  @override
  String toString() {
    return 'Snack(message: $message, positive: $positive, details: $details, '
        'label: $label, link: $link, copy: $copy, arguments: $arguments, '
        'showOnLogin: $showOnLogin)';
  }
}

enum AppContext { login, wallet, manage, swap }
