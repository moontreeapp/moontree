import 'package:raven_back/services/wallet/import.dart';
import 'package:test/test.dart';

void main() {
  test('Import Private Key', () {
    final service = ImportWalletService();
    var detection = service.detectImportType(
        'Kwu8Z924ch2Mp9t7YEFwj1pvsWUF22VRSDvaZzEcxYHWTkDqNGvD'.trim());
    print(detection);
  });
}
