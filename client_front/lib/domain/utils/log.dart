/// unused currently - may want to use this to send logs to firebase

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:logging/logging.dart' show Level, Logger;
export 'package:logging/logging.dart' show Level;

class Log {
  Log(String loggerName) {
    logger = Logger(loggerName /*, bindOnRecord: false */);
  }

  late final Logger logger;

  static Log? defaultLogger;

  static Future<void> initialize() async {
    await dotenv.load();
    defaultLogger = Log('RootLogger');
  }

  void log(
    Object? message, {
    Level level = Level.INFO,
    Map<String, dynamic>? attributes,
  }) {
    logger.log(level, message);
  }

  /* Shortcut methods: follows after javacript console error levels */

  void info(Object? message, {Map<String, dynamic>? attributes}) {
    log(message, attributes: attributes);
  }

  void warn(Object? message, {Map<String, dynamic>? attributes}) {
    log(message, level: Level.WARNING, attributes: attributes);
  }

  void error(Object? message, {Map<String, dynamic>? attributes}) {
    log(message, level: Level.SEVERE, attributes: attributes);
  }
}

/// Global default 'log'
void log(
  Object? message, {
  Level level = Level.INFO,
  Map<String, dynamic>? attributes,
}) {
  Log.defaultLogger!.log(message, level: level, attributes: attributes);
}
