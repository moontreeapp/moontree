import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:raven/raven.dart';

class CipherStreams {
  final type = latestCipherType$;
  final update = latestCipherUpdate$;
  final latest = latestCipher$;
}

final Stream<CipherType> latestCipherType$ = streams.password.exists
    .map((bool exists) => exists ? CipherType.AES : CipherType.None);

final latestCipherUpdate$ = CombineLatestStream.combine2(
    latestCipherType$,
    streams.password.latest,
    (CipherType cipherType, Password? password) =>
        CipherUpdate(cipherType, passwordId: password?.passwordId));

final Stream<Cipher> latestCipher$ = CombineLatestStream.combine2(
        ciphers.changes,
        latestCipherUpdate$,
        (Change<Cipher> change, CipherUpdate cipherUpdate) =>
            ciphers.primaryIndex.getOne(cipherUpdate))
    .whereType<Cipher>()
    .distinctUnique();
