import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:raven_back/utilities/exceptions.dart';

abstract class RVNRateInterface {
  Future<double?> get();
}

class RVNtoFiat implements RVNRateInterface {
  final String fiat;
  late String fiatConformed;
  late String serviceName;

  RVNtoFiat([this.fiat = 'usd'])
      : fiatConformed = fiat,
        serviceName = 'Moontree';

  @override
  Future<double?> get() async {
    try {
      serviceName = 'Moontree';
      return await _getRate();
    } catch (e) {
      try {
        serviceName = 'CoinGecko';
        return await _getRate();
      } catch (e) {
        //print(e);
        try {
          serviceName = 'Bittrex';
          return await _getRate();
        } catch (e) {
          try {
            print(e);
            serviceName = 'Nomi';
            return await _getRate();
          } catch (e) {
            return null;
          }
        }
      }
    }
  }

  Future<double> _getRate() async {
    _conformFiat();
    return _verifySensible(_interpret(await _call()));
  }

  void _conformFiat() {
    fiatConformed = {
      'Moontree': fiat.toUpperCase(),
      'CoinGecko': fiat.toLowerCase(),
      'Bittrex': fiat.toUpperCase(),
      'Nomi': fiat.toUpperCase(),
    }[serviceName]!;
  }

  Future<http.Response> _call() async => await http.get(
        Uri.parse(() {
          switch (serviceName) {
            case 'Moontree':
              return 'https://moontree.com/prices';
            case 'CoinGecko':
              return 'https://api.coingecko.com/api/v3/simple/price?'
                  'ids=ravencoin&vs_currencies=$fiatConformed';
            case 'Bittrex':
              return 'https://api.bittrex.com/v3/markets/RVN-$fiatConformed/ticker';
            case 'Nomi':
              return 'https://api.nomics.com/v1/currencies/ticker?'
                  'key=1a475af107cf428e9536da16c07b78cef68dfc1d&ids=RVN&'
                  'interval=1d&convert=$fiatConformed&per-page=100&page=1';
            default:
              return 'https://moontree.com/prices';
          }
        }()),
        headers: {'accept': 'application/json'},
      );

  double _interpret(http.Response response) {
    if (serviceName == 'Moontree') {
      Map jsonBody;
      try {
        jsonBody = jsonDecode(response.body);
      } catch (e) {
        print(e);
        throw FetchDataException('unable to get data from interpretMoontree');
      }
      var total = 0.0;
      var cnt = 0;
      for (final key in jsonBody.keys) {
        if ((jsonBody[key]! as Map).containsKey(fiatConformed)) {
          total += jsonBody[key]![fiatConformed]!;
          cnt += 1;
        }
      }
      if (cnt < 1) {
        throw FetchDataException('no data for $fiat with interpretMoontree');
      }
      // Return avg of our aggregations
      return total / cnt;
    }
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
  double _verifySensible(double rvnPrice) {
    if (rvnPrice == 0.0) {
      throw BadResponseException('price is zero');
    }
    if (rvnPrice < 0.0) {
      throw BadResponseException('impossible price');
    }
    return rvnPrice;
  }
}
