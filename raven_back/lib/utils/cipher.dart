import 'dart:typed_data';
import 'package:pointycastle/export.dart';

const int DEFAULT_ITERATIONS = 2;
const int DEFAULT_MEMORY = 16;
final Uint8List DEFAULT_SALT = getBytes('aeree5Zaeveexooj');

Uint8List getBytes(String key) => Uint8List.fromList(key.codeUnits);

abstract class Cipher {
  Cipher();

  Uint8List encrypt(Uint8List plainText);
  Uint8List decrypt(Uint8List cipherText);
}

class NoCipher implements Cipher {
  const NoCipher();

  @override
  Uint8List encrypt(Uint8List plainText) => plainText;

  @override
  Uint8List decrypt(Uint8List cipherText) => cipherText;
}

class AESCipher implements Cipher {
  late Uint8List _key; // 32 bytes
  late Uint8List _iv; // 16 bytes

  AESCipher(Uint8List password, {Uint8List? salt}) {
    var generator = makeKeyGenerator(48, salt);
    var result = generator.process(password);
    assert(result.length == 48);
    _key = result.sublist(0, 32);
    _iv = result.sublist(32, 48);
  }

  /// While passwords can be any length, AES block ciphers require a specific
  /// key length. Using the Argon2 algorithm, we produce a generator that can
  /// convert a variable-length password into a byte array of specific length.
  Argon2BytesGenerator makeKeyGenerator(int length, [Uint8List? salt]) =>
      Argon2BytesGenerator()
        // Note: we may need to tweak these params to work best on mobile devices
        //       https://www.twelve21.io/how-to-choose-the-right-parameters-for-argon2/
        ..init(Argon2Parameters(
          Argon2Parameters.ARGON2_id,
          salt ?? DEFAULT_SALT,
          desiredKeyLength: length,
          version: Argon2Parameters.ARGON2_VERSION_13,
          iterations: DEFAULT_ITERATIONS,
          memoryPowerOf2: DEFAULT_MEMORY,
        ));

  PaddedBlockCipherImpl cipher(encrypt) {
    var blockCipher = CBCBlockCipher(AESFastEngine());
    var params = ParametersWithIV<KeyParameter>(KeyParameter(_key), _iv);
    var paddingParams =
        PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
            params, null);
    return PaddedBlockCipherImpl(PKCS7Padding(), blockCipher)
      ..init(encrypt, paddingParams);
  }

  @override
  Uint8List encrypt(Uint8List plainText) {
    return cipher(true).process(plainText);
  }

  @override
  Uint8List decrypt(Uint8List cipherText) {
    return cipher(false).process(cipherText);
  }
}
