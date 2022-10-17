import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ravencoin_back/utilities/exceptions.dart';
import 'package:tuple/tuple.dart';

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

  /// parces structure to get value, also gets avg time of observations
  /// also, tries to get recent, if unable to get recent data, accepts whatever
  /// is available, otherwise, fails.
  Tuple2<double, double> _interpretMoontreeStructure(
    Map<String, dynamic> jsonBody, {
    int recentHours = 12,
    bool anytime = false,
  }) {
    /*
        look in every nested thing and make sure the last successful scrape
        isn't too old... subtract utcnow from "last_successful_scrape"
        and get time, if too old look at other nested data...  
        {
          "coingecko": {
            "last_successful_scrape": 1657905691,
            "values": {
              "BTC": 1.08e-06,}},
          "bitrex": {
            "last_successful_scrape": 1657905689,
            "values": {
              "USDT": 0.02257418}},
          "nomi": {
            "last_successful_scrape": 1657905690,
            "values": {
              "USD": 0.022523955}}}
      */
    var total = 0.0;
    var cnt = 0;
    var time = 0;
    final now = DateTime.now();
    for (final key in jsonBody.keys) {
      var value = (jsonBody[key]!['values']! as Map);
      var timestamp = jsonBody[key]!['last_successful_scrape']! as int;
      final ts = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      if (anytime || now.difference(ts).inHours < recentHours) {
        if (value.containsKey(fiatConformed)) {
          total += value[fiatConformed]!;
          cnt += 1;
          time += jsonBody[key]!['last_successful_scrape']! as int;
        }
      }
    }
    if (cnt < 1) {
      if (anytime) {
        // TODO instead of throwing tell the front end unreachable
        throw FetchDataException('no data for $fiat with interpretMoontree');
      }
      return _interpretMoontreeStructure(jsonBody, anytime: true);
    }
    return Tuple2(total / cnt, time / cnt);
  }

  double _interpret(http.Response response) {
    if (serviceName == 'Moontree') {
      //Map<String, Map<String, dynamic>> jsonBody;
      Map<String, dynamic> jsonBody;
      try {
        jsonBody = jsonDecode(response.body);
      } catch (e) {
        print(e);
        throw FetchDataException('unable to get data from interpretMoontree');
      }
      return _interpretMoontreeStructure(jsonBody).item1; // item2 is avgtime
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
