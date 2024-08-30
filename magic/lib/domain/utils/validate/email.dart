/// ported from https://github.com/validatorjs/validator.js/blob/master/src/lib/isEmail.js
/*
import 'package:string_validator/string_validator.dart';
import 'package:collection/collection.dart';

Map<String, dynamic> default_email_options = {
  'allow_display_name': false,
  'require_display_name': false,
  'allow_utf8_local_part': true,
  'require_tld': true,
  'blacklisted_chars': '',
  'ignore_max_length': false,
  'host_blacklist': [],
  'host_whitelist': [],
};

final splitNameAddress = RegExp(r'^([^\x00-\x1F\x7F-\x9F\cX]+)<', caseSensitive: false);
final emailUserPart = RegExp(r"^[a-z\d!#\$%&\'\*\+\-\/=\?\^_`{\|}~]+$", caseSensitive: false);
final gmailUserPart = RegExp(r'^[a-z\d]+$', caseSensitive: false);
final quotedEmailUser = RegExp(r'^([\s\x01-\x08\x0b\x0c\x0e-\x1f\x7f\x21\x23-\x5b\x5d-\x7e]|(\\[\x01-\x09\x0b\x0c\x0d-\x7f]))*$', caseSensitive: false);
final emailUserUtf8Part = RegExp(r"^[a-z\d!#\$%&\'\*\+\-\/=\?\^_`{\|}~\u00A1-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+$", caseSensitive: false);
final quotedEmailUserUtf8 = RegExp(r'^([\s\x01-\x08\x0b\x0c\x0e-\x1f\x7f\x21\x23-\x5b\x5d-\x7e\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]|(\\[\x01-\x09\x0b\x0c\x0d-\x7f\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))*$', caseSensitive: false);
final defaultMaxEmailLength = 254;

bool validateDisplayName(String displayName) {
  final displayNameWithoutQuotes = displayName.replaceAll(RegExp(r'^"(.+)"$'), r'$1');
  if (displayNameWithoutQuotes.trim().isEmpty) {
    return false;
  }

  final containsIllegal = RegExp(r'[\.";<>]').hasMatch(displayNameWithoutQuotes);
  if (containsIllegal) {
    if (displayNameWithoutQuotes == displayName) {
      return false;
    }

    final allStartWithBackSlash =
        displayNameWithoutQuotes.split('"').length == displayNameWithoutQuotes.split(r'\"').length;
    if (!allStartWithBackSlash) {
      return false;
    }
  }

  return true;
}

bool isEmail(String str, [Map<String, dynamic>? options]) {
  assertString(str);
  options = Map.from(default_email_options)..addAll(options ?? {});

  if (options['require_display_name'] || options['allow_display_name']) {
    final displayEmail = splitNameAddress.firstMatch(str);
    if (displayEmail != null) {
      var displayName = displayEmail.group(1)!;

      str = str.replaceAll(displayName, '').replaceAll(RegExp(r'(^<|>$)'), '');

      if (displayName.endsWith(' ')) {
        displayName = displayName.substring(0, displayName.length - 1);
      }

      if (!validateDisplayName(displayName)) {
        return false;
      }
    } else if (options['require_display_name'] == true) {
      return false;
    }
  }

  if (!(options['ignore_max_length'] == true || str.length <= defaultMaxEmailLength)) {
    return false;
  }

  final parts = str.split('@');
  final domain = parts.removeLast();
  final lowerDomain = domain.toLowerCase();

  if (options['host_blacklist'].contains(lowerDomain)) {
    return false;
  }

  if (options['host_whitelist'].isNotEmpty && !options['host_whitelist'].contains(lowerDomain)) {
    return false;
  }

  var user = parts.join('@');

  if (options['domain_specific_validation'] == true &&
      (lowerDomain == 'gmail.com' || lowerDomain == 'googlemail.com')) {
    user = user.toLowerCase();

    final username = user.split('+')[0];

    if (!isByteLength(username.replaceAll('.', ''), min: 6, max: 30)) {
      return false;
    }

    final userParts = username.split('.');
    for (final userPart in userParts) {
      if (!gmailUserPart.hasMatch(userPart)) {
        return false;
      }
    }
  }

  if (options['ignore_max_length'] == false &&
      (!isByteLength(user, max: 64) || !isByteLength(domain, max: 254))) {
    return false;
  }

  if (!isFQDN(domain, requireTld: options['require_tld'], ignoreMaxLength: options['ignore_max_length'])) {
    if (options['allow_ip_domain'] == true) {
      if (!isIP(domain)) {
        if (!domain.startsWith('[') || !domain.endsWith(']')) {
          return false;
        }

        final noBracketdomain = domain.substring(1, domain.length - 1);
        if (noBracketdomain.isEmpty || !isIP(noBracketdomain)) {
          return false;
        }
      }
    } else {
      return false;
    }
  }

  if (user[0] == '"') {
    user = user.substring(1, user.length - 1);
    return options['allow_utf8_local_part'] == true
        ? quotedEmailUserUtf8.hasMatch(user)
        : quotedEmailUser.hasMatch(user);
  }

  final pattern = options['allow_utf8_local_part'] == true ? emailUserUtf8Part : emailUserPart;
  final userParts = user.split('.');
  for (final userPart in userParts) {
    if (!pattern.hasMatch(userPart)) {
      return false;
    }
  }

  if (options['blacklisted_chars'].isNotEmpty) {
    if (RegExp('[' + options['blacklisted_chars'] + ']+').hasMatch(user)) {
      return false;
    }
  }

  return true;
}
*/
