// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';
import 'package:moontree_utils/moontree_utils.dart';

abstract class Grabber {
  Future<double?> get();
}

class RateGrabber implements Grabber {
  final String symbol;
  final String fiat;
  Map<String, dynamic> pull = {};

  RateGrabber({required this.symbol, this.fiat = 'USD'});

  @override
  Future<double?> get() async =>
      (await _getRate()) ??
      _verifySensible(_interpretMoontreeStructure(pull)?.item1);

  Future<double?> _getRate() async =>
      _verifySensible(_interpret(await _call()));

  Future<http.Response> _call() async =>
      http.get(Uri.parse('https://moontree.com/prices/$symbol'),
          headers: <String, String>{'accept': 'application/json'});

  /// parces structure to get value, also gets avg time of observations
  /// also, tries to get recent, if unable to get recent data, accepts whatever
  /// is available, otherwise, fails.
  Tuple2<double, double>? _interpretMoontreeStructure(
    Map<String, dynamic> jsonBody, {
    int recentHours = 12,
    bool anytime = false,
  }) {
    /** look in every nested thing and make sure the last successful scrape
      * isn't too old... subtract utcnow from "last_successful_scrape"
      * and get time, if too old look at other nested data...  
      {
        "coingecko": {
          "last_successful_scrape": 1657905691,
          "values": {
            "USD": 0.00039307,
            "BTC": 1.08e-06,}}}
    */

    double total = 0.0;
    int cnt = 0;
    int time = 0;
    final DateTime now = DateTime.now();
    for (final String key in jsonBody.keys) {
      final Map<String, dynamic> value =
          jsonBody[key]!['values']! as Map<String, dynamic>;
      final int timestamp = jsonBody[key]!['last_successful_scrape']! as int;
      final DateTime ts = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      if (anytime || now.difference(ts).inHours < recentHours) {
        if (value.containsKey(fiat)) {
          total += value[fiat]! as num;
          cnt += 1;
          time += jsonBody[key]!['last_successful_scrape']! as int;
        }
      }
    }
    if (cnt < 1) {
      if (anytime) {
        // TODO instead of throwing tell the front end unreachable
        //throw FetchDataException('no data for $fiat with interpretMoontree');
        return null;
      }
      return _interpretMoontreeStructure(jsonBody, anytime: true);
    }
    pull = jsonBody;
    return Tuple2<double, double>(total / cnt, time / cnt);
  }

  double? _interpret(http.Response response) {
    //Map<String, Map<String, dynamic>> jsonBody;
    Map<String, dynamic> jsonBody;
    try {
      jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      print(e);
      throw FetchDataException('unable to get data from interpretMoontree');
    }
    return _interpretMoontreeStructure(jsonBody)?.item1; // item2 is avgtime
  }

  // placeholder for better verification - avg 2 out of 3 or something...
  double? _verifySensible(double? price) {
    if (price is double) {
      if (price == 0.0) {
        throw BadResponseException('price is zero');
      }
      if (price < 0.0) {
        throw BadResponseException('impossible price');
      }
    }
    return price;
  }
}
