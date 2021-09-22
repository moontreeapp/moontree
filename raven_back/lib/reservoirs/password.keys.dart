part of 'password.dart';

int maxPasswordID(Iterable<Password> passwordHashes) =>
    max([for (var passwordHash in passwordHashes) passwordHash.passwordId]) ??
    0;

class _IdKey extends Key<Password> {
  @override
  String getKey(Password passwordHash) => passwordHash.passwordId.toString();
}

extension ByIdMethodsForPassword on Index<_IdKey, Password> {
  Password? getOne(int passwordId) =>
      getByKeyStr(passwordId.toString()).firstOrNull;
  Password? getMostRecent() => values
      .where((passwordHash) => passwordHash.passwordId == maxPasswordID(values))
      .firstOrNull;
  Password? getPrevious() => values
      .where((passwordHash) =>
          passwordHash.passwordId == maxPasswordID(values) - 1)
      .firstOrNull;
}
