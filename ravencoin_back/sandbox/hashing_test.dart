// dart --no-sound-null-safety test test/unit/hashing_test.dart

import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:bip39/bip39.dart' as bip39;
import 'package:test/test.dart'; // for the utf8.encode method

void main() {
  test('how to hash', () {
    var bytes = utf8.encode('foobar'); // data being hashed
    var digest = sha1.convert(bytes);
    //print('Digest as bytes: ${digest.bytes}');
    //print('Digest as hex string: $digest');
    expect(digest, bytes);
  });
  test('how to seed to string', () {
    var phrase =
        'smile build brain topple moon scrap area aim budget enjoy polar erosion';
    var seed = bip39.mnemonicToSeed(phrase);
    var digest = sha256.convert(seed);
    //print('Digest as bytes: $seed');
    //print('Digest as hex string: $digest');
    //print(digest.toString());
    var bytes = utf8.encode(phrase); // data being hashed
    digest = sha256.convert(bytes);
    //print('Digest as bytes: ${digest.bytes}');
    //print('Digest as hex string: $digest');
    expect(digest, bytes);
  });
}
