import 'package:raven_back/raven_back.dart';

Map<String, Cipher> get ciphers => {
      '0': Cipher(
          cipherType: CipherType.None, passwordId: 0, cipher: CipherNone())
    };
