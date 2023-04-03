import 'package:collection/collection.dart';
import 'package:quiver/iterables.dart';
import 'package:proclaim/proclaim.dart';
import 'package:client_back/records/password.dart';

part 'password.keys.dart';

class PasswordProclaim extends Proclaim<_IdKey, Password> {
  PasswordProclaim() : super(_IdKey());

  int? get maxPasswordId =>
      max(<int>[for (Password password in records) password.id]);

  Password? get current => records
      .where((Password password) => password.id == maxPasswordId)
      .firstOrNull;
}
