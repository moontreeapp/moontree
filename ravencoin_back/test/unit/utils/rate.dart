// dart test test/unit/utils/rate.dart --concurrency=1
import 'dart:convert';

import 'package:ravencoin_back/utilities/rate.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('rate', () {
    var exchangeRate = RVNtoFiat();

    test('get moontree manually', () async {
      var x = await http.get(
        Uri.parse(() {
          switch ('Moontree') {
            case 'Moontree':
              return 'https://moontree.com/prices';
            default:
              return 'https://moontree.com/prices';
          }
        }()),
        headers: {'accept': 'application/json'},
      );

      Map jsonBody;
      try {
        jsonBody = jsonDecode(x.body);
      } catch (e) {
        print(e);
        jsonBody = {};
      }
      var total = 0.0;
      var cnt = 0;
      for (final key in jsonBody.keys) {
        if ((jsonBody[key]! as Map).containsKey('USD')) {
          total += jsonBody[key]!['USD']!;
          cnt += 1;
        }
      }
      if (cnt < 1) {
        print('no data for usd with interpretMoontree');
      }
      print(total / cnt);
      expect(total / cnt > 0.0, true);
    });
    test('get moontree', () async {
      exchangeRate.serviceName = 'Moontree';
      expect((await exchangeRate.get())! > 0.0, true);
    });
    test('get gecko', () async {
      exchangeRate.serviceName = 'CoinGecko';
      expect((await exchangeRate.get())! > 0.0, true);
    });

    test('get bittrex', () async {
      exchangeRate.serviceName = 'Bittrex';
      expect((await exchangeRate.get())! > 0.0, true);
    });

    test('get nomi', () async {
      exchangeRate.serviceName = 'Nomi';
      expect((await exchangeRate.get())! > 0.0, true);
    });
  });

  //test('getdesk', () async {
  //  //https://openexchangerates.org/signup
  //  //https://openexchangerates.org/api/currencies.json - use to get from usd to any currecny
  //  //var url =
  //  //    Uri.parse('https://api.coindesk.com/v1/bpi/currentprice/rvn.json');
  //  //var response =
  //  //    await http.get(url, headers: {'accept': 'application/json'});
  //  //print('Response status: ${response.statusCode}');
  //  //print('Response body: ${response.body}');
  //  //print(jsonDecode(response.body)['ravencoin']['usd']);
  //});
}
