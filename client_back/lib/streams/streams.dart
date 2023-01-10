// ignore_for_file: avoid_classes_with_only_static_members, camel_case_types

import 'asset.dart';
import 'app.dart';
import 'create.dart';
import 'reissue.dart';
import 'cipher.dart';
import 'client.dart';
import 'import.dart';
import 'metadata.dart';
import 'password.dart';
import 'spend.dart';
import 'wallet.dart';

class streams {
  static final AppStreams app = AppStreams();
  static final AssetStreams asset = AssetStreams();
  static final CipherStreams cipher = CipherStreams();
  static final ClientStreams client = ClientStreams();
  static final CreateStreams create = CreateStreams();
  static final ReissueStreams reissue = ReissueStreams();
  static final MetadataStreams metadata = MetadataStreams();
  static final PasswordStreams password = PasswordStreams();
  static final WalletStreams wallet = WalletStreams();
  static final Spend spend = Spend();
  static final Import import = Import();
}
