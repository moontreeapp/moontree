/// unused currently - may want to use this to send logs to firebase

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:logging/logging.dart' show Level, Logger;
export 'package:logging/logging.dart' show Level;

class Log {
  static Log? defaultLogger;

  static initialize() async {
    await dotenv.load(fileName: '.env');

    var _log = Log('RootLogger');
    defaultLogger = _log;
  }

  late final Logger logger;

  Log(String loggerName) {
    logger = Logger(loggerName /*, bindOnRecord: false */);
  }

  void log(message, {level: Level.INFO, Map<String, dynamic>? attributes}) {
    logger.log(message, level);
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
