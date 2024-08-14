import 'package:magic/domain/server/serverv2_client.dart';
import 'package:magic/services/services.dart';

class ServerCall {
  //static const String moontreeUrl = 'http://24.199.68.139:8080';
  static const String moontreeUrl = 'https://app.moontree.com';
  final Client client;

  ServerCall() : client = subscription.client;

  Future<T> runCall<T>(Future<T> Function() call) async {
    try {
      await subscription.ensureConnected();
      return await call();
    } catch (e) {
      print('Error during server call: $e');
      // You might want to add more specific error handling here
      rethrow; // Rethrow the error to let the caller handle it
    }
  }
}
