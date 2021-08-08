import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:raven/utils/exceptions.dart';

class RVNtoFiat {
  final String fiat;
  late String fiatConformed;
  late String serviceName;

  RVNtoFiat([this.fiat = 'usd'])
      : fiatConformed = fiat,
        serviceName = 'CoinGecko';

  Future<double> get() async {
    try {
      serviceName = 'CoinGecko';
      return await getRate();
    } catch (e) {
      print(e);
      try {
        serviceName = 'Bittrex';
        return await getRate();
      } catch (e) {
        print(e);
        serviceName = 'Nomi';
        return await getRate();
      }
    }
  }

  Future<double> getRate() async {
    if (serviceName == 'CoinGecko') {
      // https://api.coingecko.com/api/v3/simple/supported_vs_currencies
      fiatConformed = fiat.toLowerCase();
    } else if (serviceName == 'Bittrex') {
      // https://api.bittrex.com/v3/markets/tickers
      fiatConformed = fiat.toUpperCase(); // USD, USDT
    } else if (serviceName == 'Nomi') {
      // https://nomics.com/docs/#operation/getCurrenciesTicker
      fiatConformed = fiat.toUpperCase(); // USD, EUR, etc
    }
    return interpret(await call());
  }

  Future<http.Response> call() async {
    if (serviceName == 'CoinGecko') {
      return await http.get(
          Uri.parse('https://api.coingecko.com/api/v3/simple/price?'
              'ids=ravencoin&vs_currencies=$fiatConformed'),
          headers: {'accept': 'application/json'});
    }
    if (serviceName == 'Bittrex') {
      return await http.get(
          Uri.parse(
              'https://api.bittrex.com/v3/markets/RVN-$fiatConformed/ticker'),
          headers: {'accept': 'application/json'});
    }
    if (serviceName == 'Nomi') {
      return await http.get(
          // replace with real key
          Uri.parse('https://api.nomics.com/v1/currencies/ticker?'
              'key=1a475af107cf428e9536da16c07b78cef68dfc1d&ids=RVN&'
              'interval=1d&convert=$fiatConformed&per-page=100&page=1'),
          headers: {'accept': 'application/json'});
    }
    return http.Response('', 412);
  }

  double interpret(http.Response response) {
    if (serviceName == 'CoinGecko') {
      Map jsonBody;
      try {
        jsonBody = jsonDecode(response.body);
      } catch (e) {
        print(e);
        throw FetchDataException('unable to get data from interpretCoinGecko');
      }
      if (!jsonBody.keys.contains('ravencoin')) {
        throw BadResponseException('data malformed in interpretCoinGecko');
      }
      if (!jsonBody['ravencoin'].keys.contains(fiat)) {
        throw BadResponseException('data malformed in interpretCoinGecko');
      }
      return jsonBody['ravencoin'][fiat];
    }
    if (serviceName == 'Bittrex') {
      Map jsonBody;
      try {
        jsonBody = jsonDecode(response.body);
      } catch (e) {
        print(e);
        throw FetchDataException('unable to get data from interpretBittrex');
      }
      if (!jsonBody.keys.contains('lastTradeRate')) {
        throw BadResponseException('data malformed in interpretBittrex');
      }
      try {
        return double.parse(jsonBody['lastTradeRate']);
      } catch (e) {
        print(e);
        throw BadResponseException('unable cast to double in interpretBittrex');
      }
    }
    if (serviceName == 'Nomi') {
      List jsonBody;
      try {
        jsonBody = jsonDecode(response.body);
      } catch (e) {
        print(e);
        throw FetchDataException('unable to get data from interpretNomi');
      }
      if (jsonBody.isEmpty) {
        throw BadResponseException('data empty in interpretNomi');
      }
      if (!jsonBody[0].keys.contains('price')) {
        throw BadResponseException('data malformed in interpretNomi');
      }
      try {
        return double.parse(jsonBody[0]['price']);
      } catch (e) {
        print(e);
        throw BadResponseException('unable cast to double in interpretNomi');
      }
    }
    return 0.0;
  }
}
