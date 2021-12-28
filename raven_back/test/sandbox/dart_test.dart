// dart test test/sandbox/dart_test.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:quiver/iterables.dart';
import 'package:raven_back/security/cipher_aes.dart';
import 'package:test/test.dart';
import 'package:date_format/date_format.dart';

void showFormats() {
  print('0' + formatDate(DateTime(1989, 2, 21), [yyyy, '-', mm, '-', dd]));
  print('1' + formatDate(DateTime(1989, 2, 21), [yy, '-', m, '-', dd]));
  print('2' + formatDate(DateTime(1989, 2, 1), [yy, '-', m, '-', d]));
  print('3' + formatDate(DateTime(1989, 2, 1), [yy, '-', MM, '-', d]));
  print('4' + formatDate(DateTime(1989, 2, 21), [yy, '-', M, '-', d]));
  print('5' + formatDate(DateTime(1989, 2, 1), [yy, '-', M, '-', d]));
  print('6' + formatDate(DateTime(2018, 1, 14), [yy, '-', M, '-', DD]));
  print('7' + formatDate(DateTime(2018, 1, 14), [yy, '-', M, '-', D]));
  print('8' +
      formatDate(DateTime(1989, 02, 1, 15, 40, 10), [HH, ':', nn, ':', ss]));
  print('9' +
      formatDate(
          DateTime(1989, 02, 1, 15, 40, 10), [hh, ':', nn, ':', ss, ' ', am]));
  print('10' +
      formatDate(
          DateTime(1989, 02, 1, 15, 40, 10), [hh, ':', nn, ':', ss, ' ', am]));
  print('11' + formatDate(DateTime(1989, 02, 1, 15, 40, 10), [hh]));
  print('12' + formatDate(DateTime(1989, 02, 1, 15, 40, 10), [h]));
  print('13' + formatDate(DateTime(1989, 02, 1, 5), [am]));
  print('14' + formatDate(DateTime(1989, 02, 1, 15), [am]));
  print('15' +
      formatDate(DateTime(1989, 02, 1, 15, 40, 10), [HH, ':', nn, ':', ss, z]));
  print('16' +
      formatDate(
          DateTime(1989, 02, 1, 15, 40, 10), [HH, ':', nn, ':', ss, ' ', Z]));
  print('17' + formatDate(DateTime(1989, 02, 21), [yy, ' ', w]));
  print('18' + formatDate(DateTime(1989, 02, 21), [yy, ' ', W]));
  print('19' + formatDate(DateTime(1989, 12, 31), [yy, '-W', W]));
  print('20' + formatDate(DateTime(1989, 1, 1), [yy, '-', mm, '-w', W]));
  print('21' +
      formatDate(
          DateTime(1989, 02, 1, 15, 40, 10), [HH, ':', nn, ':', ss, ' ', Z]));
  print('22' + formatDate(DateTime(2020, 04, 18, 21, 14), [H, '\\h', n]));
}

enum SettingName { Electrum_Url, Electrum_Port }
void main() {
  test('forEach is not isolated', () {
    var histories = {
      'a': [1],
      'b': [],
      'c': [1, 2, 3],
      'd': []
    };
    var gap = 0;
    histories.forEach((k, v) {
      gap = gap + (v.isEmpty ? 1 : 0);
      //print('{$k: $v} -- $gap');
    });
    //print(gap);
    expect(gap, 2);
  });

  test('run map function', () {
    var fiat = 'aBc';
    var fiatConformed = {
      'CoinGecko': fiat.toLowerCase(),
      'Bittrex': fiat.toUpperCase(),
      'Nomi': fiat.toUpperCase(),
    }['Nomi']!;
    //print(fiatConformed);
    expect(fiatConformed, 'ABC');
    expect(fiat, 'aBc');
  });
  test('what is an enum?', () {
    //print(SettingName.Electrum_Url);
    //print(SettingName.Electrum_Url.index);
    //print(SettingName.Electrum_Url.hashCode);
    //print(SettingName.Electrum_Url.runtimeType);
    //print(SettingName.Electrum_Url.toString().split('.')[1]);
    ////print(SettingName.Electrum_Url.enumString);
    //print(SettingName.Electrum_Url.index);
    //print(SettingName.Electrum_Url == SettingName.Electrum_Url);
    //print(SettingName.Electrum_Url is Object);
    //print(SettingName is Object);
    /*
    SettingName.Electrum_Url
    0
    434216034
    SettingName
    SettingName.Electrum_Url
    true
    true
    true
    */
  });
  test('merge map?', () {
    final firstMap = {'1': '2', '2': '3'};
    final secondMap = {'2': '4', '3': '4'};

    final thirdMap = {
      ...firstMap,
      ...secondMap,
    };

    print(thirdMap);
  });
  test('list of list to set', () {
    var combos = [
      ['a', 'b'],
      ['a', 'b'],
      ['a', 'c']
    ];
    print(combos.toSet());
    print(combos.toSet().toList());
    var combos2 = [
      {'a', 'b'},
      {'a', 'b'},
      {'a', 'c'}
    ];
    print(combos2.toSet());
    print(combos2.toSet().toList());
    var combos3 = ['a', 'b', 'a', 'b', 'a', 'c'];
    print(combos3.toSet());
    print(combos3.toSet().toList());
  });

  test('DateTime readable', () {
    print(DateTime.now()
        .subtract(Duration(
          days: 3,
          hours: 9,
        ))
        .toString());
    showFormats();

    print(formatDate(DateTime(1989, 2, 1), [MM, ' ', d, ', ', yyyy]));
  });

  test('max on empty', () {
    print(max([1, 3, 2]));
    print(max([]));
    //print([].length == 0 ? null : [].reduce(max));
  });

  test('hashing with empty string', () {
    var password = '';
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    print('Digest as bytes: ${digest.bytes}');
    print('Digest as hex string: $digest');
    var cipher = CipherAES(Uint8List.fromList(password.codeUnits));
    print(Uint8List.fromList('plainText'.codeUnits));
    print(cipher.encrypt(Uint8List.fromList('plainText'.codeUnits)));
  });
}
