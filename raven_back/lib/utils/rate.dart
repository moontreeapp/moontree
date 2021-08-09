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
    conformFiat();
    return verifySensible(interpret(await call()));
  }

  void conformFiat() {
    fiatConformed = {
      'CoinGecko': fiat.toLowerCase(),
      'Bittrex': fiat.toUpperCase(),
      'Nomi': fiat.toUpperCase(),
    }[serviceName]!;
  }

  Future<http.Response> call() async {
    return await http.get(
        Uri.parse({
          'CoinGecko': 'https://api.coingecko.com/api/v3/simple/price?'
              'ids=ravencoin&vs_currencies=$fiatConformed',
          'Bittrex':
              'https://api.bittrex.com/v3/markets/RVN-$fiatConformed/ticker',
          'Nomi': 'https://api.nomics.com/v1/currencies/ticker?'
              'key=1a475af107cf428e9536da16c07b78cef68dfc1d&ids=RVN&'
              'interval=1d&convert=$fiatConformed&per-page=100&page=1',
        }[serviceName]!),
        headers: {'accept': 'application/json'});
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
    throw FetchDataException('invalid service name');
  }

  // placeholder for better verification - avg 2 out of 3 or something...
  double verifySensible(double rvnPrice) {
    if (rvnPrice == 0.0) {
      throw BadResponseException('price is zero');
    }
    if (rvnPrice < 0.0) {
      throw BadResponseException('impossible price');
    }
    return rvnPrice;
  }
}
