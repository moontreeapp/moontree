// ignore_for_file: avoid_classes_with_only_static_members, camel_case_types

import 'app.dart';
import 'cipher.dart';
import 'client.dart';
import 'password.dart';

class streams {
  static final AppStreams app = AppStreams();
  static final CipherStreams cipher = CipherStreams();
  static final ClientStreams client = ClientStreams();
  static final PasswordStreams password = PasswordStreams();
}
