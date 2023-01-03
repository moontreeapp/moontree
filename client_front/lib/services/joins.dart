import 'package:client_back/client_back.dart';
import 'package:client_front/services/storage.dart';

extension WalletHasASecret on Wallet {
  Future<String?> get secureSecret async => SecureStorage.read(id);
  Future<String?> get enrtopy async => secureSecret;
}
