import 'asset.dart';
import 'app.dart';
import 'create.dart';
import 'download.dart';
import 'reissue.dart';
import 'cipher.dart';
import 'client.dart';
import 'import.dart';
import 'metadata.dart';
import 'password.dart';
import 'spend.dart';
import 'wallet.dart';

class streams {
  static final app = AppStreams();
  static final asset = AssetStreams();
  static final cipher = CipherStreams();
  static final client = ClientStreams();
  static final create = CreateStreams();
  static final download = DownloadStreams();
  static final reissue = ReissueStreams();
  static final metadata = MetadataStreams();
  static final password = PasswordStreams();
  static final wallet = WalletStreams();
  static final spend = Spend();
  static final import = Import();
}
