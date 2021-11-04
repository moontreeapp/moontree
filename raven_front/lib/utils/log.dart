import 'package:datadog_flutter/datadog_flutter.dart';
import 'package:datadog_flutter/datadog_logger.dart';
import 'package:datadog_flutter/datadog_rum.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:logging/logging.dart' show Level, Logger;
export 'package:logging/logging.dart' show Level;

class Log {
  static Log? defaultLogger;

  static initialize() async {
    await dotenv.load(fileName: '.env');
    print('Initializing datadog for Raven Mobile...');
    await DatadogFlutter.initialize(
      clientToken: dotenv.env['DATADOG_CLIENT_TOKEN']!,
      serviceName: 'Raven Mobile',
      environment: 'production',
      trackingConsent: TrackingConsent.granted,
      iosRumApplicationId: dotenv.env['DATADOG_IOS_APP_ID']!,
      androidRumApplicationId: dotenv.env['DATADOG_ANDROID_APP_ID']!,
    );
    print('Initialized datadog.');

    var _log = Log('RootLogger');
    defaultLogger = _log;
    Logger.root.onRecord.listen(_log.logger.onRecordCallback);

    const userId = 'test-user-1';
    await DatadogFlutter.setUserInfo(id: userId);
    _log.logger.addAttribute('hostname', userId);
    await DatadogRum.instance.addAttribute('hostname', userId);
  }

  late final DatadogLogger logger;

  Log(String loggerName) {
    logger = DatadogLogger(loggerName: loggerName /*, bindOnRecord: false */);
  }

  void log(message, {level: Level.INFO, Map<String, dynamic>? attributes}) {
    logger.log(message, level, attributes: attributes);
  }

  /* Shortcut methods: follows after javacript console error levels */

  void info(message, {Map<String, dynamic>? attributes}) {
    log(message, level: Level.INFO, attributes: attributes);
  }

  void warn(message, {Map<String, dynamic>? attributes}) {
    log(message, level: Level.WARNING, attributes: attributes);
  }

  void error(message, {Map<String, dynamic>? attributes}) {
    log(message, level: Level.SEVERE, attributes: attributes);
  }
}

/// Global default 'log'
void log(message, {level: Level.INFO, Map<String, dynamic>? attributes}) {
  Log.defaultLogger!.log(message, level: level, attributes: attributes);
}
