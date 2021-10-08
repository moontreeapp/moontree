part of 'password.dart';

int maxPasswordId(Iterable<Password> passwords) =>
    max([for (var password in passwords) password.passwordId]) ?? 0;

class _IdKey extends Key<Password> {
  @override
  String getKey(Password password) => password.passwordId.toString();
}

extension ByIdMethodsForPassword on Index<_IdKey, Password> {
  Password? getOne(int passwordId) =>
      getByKeyStr(passwordId.toString()).firstOrNull;
  Password? getMostRecent() => values
      .where((password) => password.passwordId == maxPasswordId(values))
      .firstOrNull;
  Password? getPrevious() => values
      .where((password) => password.passwordId == maxPasswordId(values) - 1)
      .firstOrNull;
}
