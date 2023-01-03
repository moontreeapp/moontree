import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:client_back/client_back.dart';
import 'package:moontree_utils/moontree_utils.dart'
    show ReadableIdentifierExtension;

class CipherStreams {
  /// returns ciphertype depending on if a password exists
  static final Stream<CipherType> latestCipherType$ = streams.password.exists
      .map((bool exists) => exists ? CipherType.aes : CipherType.none);

  /// returns lastest cipherUpdate (latest cipherType, highest passwordId)
  static final CombineLatestStream<dynamic, CipherUpdate> latestCipherUpdate$ =
      CombineLatestStream.combine2(
          latestCipherType$,
          streams.password.latest,
          (CipherType cipherType, Password? password) =>
              CipherUpdate(cipherType, passwordId: password?.id));

  /// returns the latest cipher as defined by its inputs
  static final Stream<Cipher> latest = CombineLatestStream.combine2(
          pros.ciphers.changes,
          latestCipherUpdate$,
          (Change<Cipher> change, CipherUpdate cipherUpdate) =>
              pros.ciphers.primaryIndex.getOneByCipherUpdate(cipherUpdate))
      .whereType<Cipher>()
      .distinctUnique()
    ..name = 'cipher.latestCipher';
}
