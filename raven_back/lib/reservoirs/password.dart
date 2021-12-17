import 'package:collection/collection.dart';
import 'package:raven_back/records/password.dart';
import 'package:reservoir/reservoir.dart';
import 'package:quiver/iterables.dart';

part 'password.keys.dart';

class PasswordReservoir extends Reservoir<_IdKey, Password> {
  PasswordReservoir() : super(_IdKey());

  int? get maxPasswordId =>
      max([for (var password in data) password.passwordId]);

  /// todo: allow removal of password, does not require deletion of passwords
  ///       since services.password.required is not keyed off maxPasswordId.
}
