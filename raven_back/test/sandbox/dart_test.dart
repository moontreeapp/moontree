// dart test test/sandbox/dart_test.dart
import 'package:test/test.dart';

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
    print(SettingName.Electrum_Url);
    print(SettingName.Electrum_Url.index);
    print(SettingName.Electrum_Url.hashCode);
    print(SettingName.Electrum_Url.runtimeType);
    print(SettingName.Electrum_Url.toString().split('.')[1]);
    //print(describeEnum(SettingName.Electrum_Url));
    print(SettingName.Electrum_Url.index);
    print(SettingName.Electrum_Url == SettingName.Electrum_Url);
    print(SettingName.Electrum_Url is Object);
    print(SettingName is Object);
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
}
