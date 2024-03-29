import 'package:client_back/client_back.dart';
import 'package:client_back/services/wallet/export.dart';
import 'package:test/test.dart';

void main() {
  test('Export', () {
    final service = ExportWalletService();
    final encryptedWIF = EncryptedWIF.fromWIF(
        'cRYoTPs4ahBbp4edtykCg7b33iDhoQfJZfCD5iZS6Jkn3vNw5DQ9',
        const CipherNone());

    final wallet = SingleWallet(
        id: encryptedWIF.walletId,
        encryptedWIF: encryptedWIF.encryptedSecret,
        name: 'name');

    print('${service.walletsToExportFormat({wallet})}');
  });
}
