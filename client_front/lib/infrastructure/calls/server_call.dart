import 'package:client_back/server/serverv2_client.dart';

class ServerCall {
  static const String moontreeUrl =
      'http://24.199.68.139:8080'; //'https://api.moontree.com';
  Client client;

  ServerCall() : client = Client('$moontreeUrl/');

  void recreateClient() => client = Client('$moontreeUrl/');
}
