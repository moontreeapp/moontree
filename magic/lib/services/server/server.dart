import 'package:magic/infrastructure/server/serverv2_client.dart';
import 'package:magic/infrastructure/services/subscription.dart';

class ServerCall {
  //static const String moontreeUrl = 'http://24.199.68.139:8080';
  static const String moontreeUrl = 'https://app.moontree.com';
  Client client;

  /// use the client that automatically stays connected.
  ServerCall() : client = subscription.client;

  /// if it fails, then make your own.
  void recreateClient() =>
      client = Client('${/*SubscriptionService.*/ moontreeUrl}/');

  Future<T> runCall<T>(Function f) async {
    try {
      return await f();
    } catch (e) {
      //SocketException: HTTP connection timed out after 0:00:20.000000, host: 24.199.68.139, port: 8080
      print('recreating client');
      //recreateClient();
      //return await f();
      await Future.delayed(Duration(seconds: 11));
      return await runCall(f);

      /// ServerpodClientException (ServerpodClientException: Internal server error. Call log id: 676, statusCode = 500)
    }
  }
}
