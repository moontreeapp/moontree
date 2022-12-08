import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

class CipherStreams {
  /// not needed elsewhere yet:
  // final cipherType = latestCipherType$;
  // final cipherUpdate = latestCipherUpdate$;

  final Stream<Cipher> latest = latestCipher$;
}

/// returns ciphertype depending on if a password exists
final Stream<CipherType> latestCipherType$ = streams.password.exists
    .map((bool exists) => exists ? CipherType.aes : CipherType.none);

/// returns lastest cipherUpdate (latest cipherType, highest passwordId)
final CombineLatestStream<dynamic, CipherUpdate> latestCipherUpdate$ =
    CombineLatestStream.combine2(
        latestCipherType$,
        streams.password.latest,
        (CipherType cipherType, Password? password) =>
            CipherUpdate(cipherType, passwordId: password?.id));

/// returns the latest cipher as defined by its inputs
final Stream<Cipher> latestCipher$ = CombineLatestStream.combine2(
        pros.ciphers.changes,
        latestCipherUpdate$,
        (Change<Cipher> change, CipherUpdate cipherUpdate) =>
            pros.ciphers.primaryIndex.getOneByCipherUpdate(cipherUpdate))
    .whereType<Cipher>()
    .distinctUnique();
