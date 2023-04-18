import 'package:rxdart/rxdart.dart';
import 'package:equatable/equatable.dart';
import 'package:moontree_utils/moontree_utils.dart'
    show ReadableIdentifierExtension;
import 'package:client_back/client_back.dart';

enum NavHeight { tall, short, none }

enum LeadIcon {
  none, // remove
  dismiss, // exit, x (effectively back)
  back, // back arrow
  menu, // hamburger
  pass, // no override logic
}

class AppStreams {
  /// resumed inactive paused detached
  static final BehaviorSubject<String?> appStatus$ =
      BehaviorSubject<String?>.seeded('resumed');
  final BehaviorSubject<String?> status = appStatus$..name = 'app.status';
  final BehaviorSubject<bool> active = BehaviorSubject<bool>.seeded(true)
    ..addStream(appStatus$.map((String? status) => status == 'resumed'))
    ..name = 'app.active';
  final BehaviorSubject<bool?> tap = BehaviorSubject<bool?>.seeded(null)
    ..name = 'app.tap';
  final BehaviorSubject<bool> verify = BehaviorSubject<bool>.seeded(false)
    ..name = 'app.verify';
  final BehaviorSubject<String> page = BehaviorSubject<String>.seeded('main')
    ..name = 'app.page';
  final BehaviorSubject<Snack?> snack = BehaviorSubject<Snack?>.seeded(null)
    ..name = 'app.snack';
  final BehaviorSubject<bool> splash = BehaviorSubject<bool>.seeded(true)
    ..name = 'app.splash';
  final BehaviorSubject<KeyboardStatus?> keyboard =
      BehaviorSubject<KeyboardStatus?>.seeded(null)..name = 'app.keyboard';
  //final locked = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<bool> logout = BehaviorSubject<bool>.seeded(false)
    ..name = 'app.logout';
  final BehaviorSubject<bool?> scrim = BehaviorSubject<bool?>.seeded(false)
    ..name = 'app.scrim'; // null = disable
  final BehaviorSubject<bool> authenticating = BehaviorSubject<bool>.seeded(
      false)
    ..name =
        'app.authenticating'; // if we are minimized because of local auth do not logout
  final BehaviorSubject<bool> browsing = BehaviorSubject<bool>.seeded(false)
    ..name =
        'app.browsing'; // if we are minimized because of we are opening browser

  WalletSideStreams wallet = WalletSideStreams();
  ManageSideStreams manage = ManageSideStreams();
  SwapSideStreams swap = SwapSideStreams();
}

enum ThresholdTrigger { backup }

enum KeyboardStatus { up, down }

class WalletSideStreams {
  final BehaviorSubject<String?> asset = BehaviorSubject<String?>.seeded(null)
    ..name = 'app.wallet.asset';
  final PublishSubject<bool> refresh = PublishSubject<bool>()
    ..name = 'app.refresh';
}

class ManageSideStreams {
  final BehaviorSubject<String?> asset = BehaviorSubject<String?>.seeded(null)
    ..name = 'app.manage.asset';
}

class SwapSideStreams {
  final BehaviorSubject<String?> asset = BehaviorSubject<String?>.seeded(null)
    ..name = 'app.swap.asset';
}

class Snack with EquatableMixin {
  final String message;
  // not used
  final bool positive;
  //final String? details; // if they click on the message, popup details
  final String? label; // link label
  final String? link;
  final String? copy;
  final Map<String, dynamic>? arguments;
  final bool showOnLogin;
  final int seconds;
  final int delay;

  Snack({
    required this.message,
    this.positive = true,
    //this.details,
    this.label,
    this.link,
    this.copy,
    this.arguments,
    this.showOnLogin = false,
    this.seconds = 5,
    this.delay = 1,
  });

  @override
  List<Object?> get props => [
        message,
        positive,
        //details,
        label,
        link,
        copy,
        arguments,
        showOnLogin,
        seconds,
        delay,
      ];

  @override
  String toString() {
    return 'Snack(message: $message, positive: $positive, ' //details: $details,
        'label: $label, link: $link, copy: $copy, arguments: $arguments, '
        'showOnLogin: $showOnLogin, seconds: $seconds, delay: $delay)';
  }
}

enum AppContext { login, wallet, manage, swap }
