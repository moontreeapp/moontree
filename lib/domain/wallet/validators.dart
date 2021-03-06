import 'package:dartz/dartz.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' show Validation;
import 'package:moontree/domain/core/value_failures.dart';

Either<ValueFailure<String>, String> validateWalletName(String walletName) {
  if (walletName.isEmpty /* TODO && doesn't already exist in wallets... */) {
    return left(ValueFailure.invalidWalletName(walletName));
  } else {
    return right(walletName);
  }
}

Either<ValueFailure<String>, String> validateHashedEntropy(String entropy) {
  if (entropy.length != 64 /* TODO a guess */) {
    return left(ValueFailure.invalidHashedEntropy(entropy));
  } else {
    return right(entropy);
  }
}

Either<ValueFailure<String>, String> validatePrivKey(String key) {
  if (!Validation.isPrivateKey(key)) {
    return left(ValueFailure.invalidPrivKey(key));
  } else {
    return right(key);
  }
}

Either<ValueFailure<String>, String> validatePubKey(String key) {
  if (!Validation.isPublicKey(key)) {
    return left(ValueFailure.invalidPubKey(key));
  } else {
    return right(key);
  }
}

Either<ValueFailure<String>, String> validatePubKeyAddress(String key) {
  if (!Validation.isPublicKeyAddress(key)) {
    return left(ValueFailure.invalidPubKeyAddress(key));
  } else {
    return right(key);
  }
}
