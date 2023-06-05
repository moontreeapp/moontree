import 'package:rxdart/rxdart.dart';
import 'package:equatable/equatable.dart';
import 'package:moontree_utils/moontree_utils.dart'
    show ReadableIdentifierExtension;

enum NavHeight { tall, short, none }

enum LeadIcon {
  none, // remove
  dismiss, // exit, x (effectively back)
  back, // back arrow
  menu, // hamburger
  pass, // no override logic
}

class AppStreams {
  AppBehaviorStreams behavior = AppBehaviorStreams();
  AppLocStreams loc = AppLocStreams();
  AppAuthStreams auth = AppAuthStreams();
  AppActiveStreams active = AppActiveStreams();
  WalletSideStreams wallet = WalletSideStreams();
  ManageSideStreams manage = ManageSideStreams();
  SwapSideStreams swap = SwapSideStreams();
}

class AppBehaviorStreams {
  final BehaviorSubject<Snack?> snack = BehaviorSubject<Snack?>.seeded(null)
    ..name = 'app.snack';
  // to remove, must at least first convert away from
  // components.message.giveChoices to using the modal cubit instead.
  final BehaviorSubject<bool?> scrim = BehaviorSubject<bool?>.seeded(false)
    ..name = 'app.scrim'; // null = disable
}

class AppLocStreams {
  final BehaviorSubject<String> page = BehaviorSubject<String>.seeded('main')
    ..name = 'app.page';
  final BehaviorSubject<bool> splash = BehaviorSubject<bool>.seeded(true)
    ..name = 'app.splash';
  // if we are minimized because of we are opening browser
  final BehaviorSubject<bool> browsing = BehaviorSubject<bool>.seeded(false)
    ..name = 'app.browsing';
}

class AppAuthStreams {
  // if we are minimized because of local auth do not logout
  final BehaviorSubject<bool> authenticating =
      BehaviorSubject<bool>.seeded(false)..name = 'app.authenticating';
  final BehaviorSubject<bool> logout = BehaviorSubject<bool>.seeded(false)
    ..name = 'app.logout';
  final BehaviorSubject<bool> verify = BehaviorSubject<bool>.seeded(false)
    ..name = 'app.verify';
}

class AppActiveStreams {
  // resumed inactive paused detached
  static final BehaviorSubject<String?> appStatus$ =
      BehaviorSubject<String?>.seeded('resumed');
  final BehaviorSubject<String?> status = appStatus$..name = 'app.status';
  final BehaviorSubject<bool> active = BehaviorSubject<bool>.seeded(true)
    ..addStream(appStatus$.map((String? status) => status == 'resumed'))
    ..name = 'app.active';
  final BehaviorSubject<bool?> tap = BehaviorSubject<bool?>.seeded(null)
    ..name = 'app.tap';
}

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
  final bool positive;
  final String? label; // link, copy, or callback label
  final String? link;
  final Map<String, dynamic>? arguments;
  final String? copy;
  final Function()? callback;
  final bool showOnLogin;
  final int seconds;
  final int delay;

  Snack({
    required this.message,
    this.positive = true,
    this.label,
    this.link,
    this.arguments,
    this.copy,
    this.callback,
    this.showOnLogin = false,
    this.seconds = 5,
    this.delay = 1,
  });

  @override
  List<Object?> get props => [
        message,
        positive,
        label,
        link,
        arguments,
        copy,
        callback,
        showOnLogin,
        seconds,
        delay,
      ];

  @override
  String toString() {
    return 'Snack(message: $message, positive: $positive, callback: $callback,'
        'label: $label, link: $link, copy: $copy, arguments: $arguments, '
        'showOnLogin: $showOnLogin, seconds: $seconds, delay: $delay)';
  }
}

enum AppContext { login, wallet, manage, swap }
