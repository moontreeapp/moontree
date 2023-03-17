import 'package:client_back/server/serverv2_client.dart';

class ServerCall {
  static const String moontreeUrl =
      'http://24.199.68.139:8080'; //'https://api.moontree.com';
  Client client;

  ServerCall() : client = Client('$moontreeUrl/');

  void recreateClient() => client = Client('$moontreeUrl/');

  Future<T> runCall<T>(Function f) async {
    try {
      return await f();
    } catch (e) {
      //SocketException: HTTP connection timed out after 0:00:20.000000, host: 24.199.68.139, port: 8080
      recreateClient();
      return await f();
    }
  }
}
