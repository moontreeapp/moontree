// dart test test/unit/rate.dart --concurrency=1
import 'package:raven/utils/rate.dart';
import 'package:test/test.dart';

void main() {
  group('rate', () {
    var exchangeRate = RVNtoFiat();

    test('get gecko', () async {
      exchangeRate.serviceName = 'CoinGecko';
      expect(await exchangeRate.getRate() > 0.0, true);
    });

    test('get bittrex', () async {
      exchangeRate.serviceName = 'Bittrex';
      expect(await exchangeRate.getRate() > 0.0, true);
    });

    test('get nomi', () async {
      exchangeRate.serviceName = 'Nomi';
      expect(await exchangeRate.getRate() > 0.0, true);
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
