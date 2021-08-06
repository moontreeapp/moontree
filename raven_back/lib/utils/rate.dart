import 'dart:convert';

import 'package:http/http.dart' as http;

Future<double> getRateFromCoinGecko([String fiat = 'usd']) async {
  var response = await http.get(
      Uri.parse('https://api.coingecko.com/api/v3/simple/price?'
          'ids=ravencoin&vs_currencies=$fiat'),
      headers: {'accept': 'application/json'});
  return jsonDecode(response.body)['ravencoin'][fiat];
}

Future<double> getRateFromBittrex([String fiat = 'usd']) async {
  var response = await http.get(
      Uri.parse('https://api.bittrex.com/v3/markets/RVN-USD/ticker'),
      headers: {'accept': 'application/json'});
  return double.parse(jsonDecode(response.body)['lastTradeRate']);
}

Future<double> getRateFromNomi([String fiat = 'usd']) async {
  var response = await http.get(
      Uri.parse(
          'https://api.nomics.com/v1/currencies/ticker?key=1a475af107cf428e9536da16c07b78cef68dfc1d&ids=RVN&interval=1d,30d&convert=EUR&per-page=100&page=1'), // replace with real key
      headers: {'accept': 'application/json'});
  return double.parse(jsonDecode(response.body)[0]['price']);
}
