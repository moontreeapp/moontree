import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../raven.dart';

/// to validate a password
/// salted hash saved in settings?
/// compare salted hashed password to it.
bool verifyPassword(
  password,
) =>
    hashThis(saltPassword(password)) == settings.hashedSaltedPassword;

/// how is the salt chosen? TODO
String getSalt() => 'salt';

String saltPassword(String password) => '${getSalt()}$password';

String hashThis(String saltedPassword) {
  var bytes = utf8.encode(saltedPassword);
  var digest = sha256.convert(bytes);
  print('Digest as bytes: ${digest.bytes}');
  print('Digest as hex string: $digest');
  return digest.toString();
}
