import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:raven_back/utils/exceptions.dart';

class Identicon {
  final String base = 'https://avatars.dicebear.com/api/identicon/';
  late String name = 'random_file_name.svg';
  late int size = 40;
  late int radius = 50;
  late String background = '23F57D00';

  Identicon({
    required this.name,
    required this.size,
    required this.radius,
    required this.background,
  });

  Future<String> get() async {
    return interpret(await call());
  }

  Future<http.Response> call() async {
    return await http
        .get(Uri.parse(url), headers: {'accept': 'application/json'});
  }

  String get url =>
      base +
      name +
      '?' +
      'size=' +
      size.toString() +
      '&radius=' +
      radius.toString() +
      '&background=%' +
      background;

  String interpret(http.Response response) {
    try {
      assert(
          response.body.startsWith('<svg') && response.body.endsWith('</svg>'));
    } catch (e) {
      print(e);
      throw FetchDataException('unable to get data from $base');
    }
    return response.body;
  }
}
