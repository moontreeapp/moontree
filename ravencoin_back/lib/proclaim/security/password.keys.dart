part of 'password.dart';

int maxPasswordId(Iterable<Password> passwords) =>
    max(<int>[for (Password password in passwords) password.id]) ?? 0;

class _IdKey extends Key<Password> {
  @override
  String getKey(Password password) => Password.key(password.id);
}

extension ByIdMethodsForPassword on Index<_IdKey, Password> {
  Password? getOne(int passwordId) =>
      getByKeyStr(Password.key(passwordId)).firstOrNull;

  Password? getMostRecent() => values
      .where((Password password) => password.id == maxPasswordId(values))
      .firstOrNull;

  Password? getPrevious() => values
      .where((Password password) => password.id == maxPasswordId(values) - 1)
      .firstOrNull;
}
