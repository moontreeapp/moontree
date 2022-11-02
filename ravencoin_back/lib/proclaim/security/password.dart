import 'package:collection/collection.dart';
import 'package:ravencoin_back/records/password.dart';
import 'package:proclaim/proclaim.dart';
import 'package:quiver/iterables.dart';

part 'password.keys.dart';

class PasswordProclaim extends Proclaim<_IdKey, Password> {
  PasswordProclaim() : super(_IdKey());

  int? get maxPasswordId => max([for (var password in records) password.id]);

  Password? get current =>
      records.where((password) => password.id == maxPasswordId).firstOrNull;
}
