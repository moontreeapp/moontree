import 'dart:convert';

import 'package:http/http.dart' as http;

Future<double> conversionRate([String fiat = 'usd']) async {
  try {
    return await getRateFromCoinGecko(fiat);
  } catch (e) {
    try {
      return await getRateFromBittrex(fiat);
    } catch (e) {
      return await getRateFromNomi(fiat);
    }
  }
}

//TODO: add errors if we don't get what we expect.

Future<double> getRateFromCoinGecko([String fiat = 'usd']) async {
  // https://api.coingecko.com/api/v3/simple/supported_vs_currencies
  fiat = fiat.toLowerCase();
  var response = await http.get(
      Uri.parse('https://api.coingecko.com/api/v3/simple/price?'
          'ids=ravencoin&vs_currencies=$fiat'),
      headers: {'accept': 'application/json'});
  return jsonDecode(response.body)['ravencoin'][fiat];
}

Future<double> getRateFromBittrex([String fiat = 'usd']) async {
  // https://api.bittrex.com/v3/markets/tickers
  fiat = fiat.toUpperCase(); // USD, USDT
  var response = await http.get(
      Uri.parse('https://api.bittrex.com/v3/markets/RVN-$fiat/ticker'),
      headers: {'accept': 'application/json'});
  return double.parse(jsonDecode(response.body)['lastTradeRate']);
}

Future<double> getRateFromNomi([String fiat = 'usd']) async {
  // https://nomics.com/docs/#operation/getCurrenciesTicker
  fiat = fiat.toUpperCase(); // USD, EUR, etc
  var response = await http.get(
      Uri.parse(
          'https://api.nomics.com/v1/currencies/ticker?key=1a475af107cf428e9536da16c07b78cef68dfc1d&ids=RVN&interval=1d&convert=${fiat.toUpperCase()}&per-page=100&page=1'), // replace with real key
      headers: {'accept': 'application/json'});
  return double.parse(jsonDecode(response.body)[0]['price']);
}
