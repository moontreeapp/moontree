part of 'password_hash.dart';

int maxPasswordID(Iterable<PasswordHash> passwordHashes) =>
    max([for (var passwordHash in passwordHashes) passwordHash.passwordId]) ??
    0;

class _IdKey extends Key<PasswordHash> {
  @override
  String getKey(PasswordHash passwordHash) =>
      passwordHash.passwordId.toString();
}

extension ByIdMethodsForPasswordHash on Index<_IdKey, PasswordHash> {
  PasswordHash? getOne(int passwordId) =>
      getByKeyStr(passwordId.toString()).firstOrNull;
  PasswordHash? getMostRecent() => values
      .where((passwordHash) => passwordHash.passwordId == maxPasswordID(values))
      .firstOrNull;
  PasswordHash? getPrevious() => values
      .where((passwordHash) =>
          passwordHash.passwordId == maxPasswordID(values) - 1)
      .firstOrNull;
}
