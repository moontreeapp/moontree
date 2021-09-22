import 'package:collection/collection.dart';
import 'package:raven/records/password_hash.dart';
import 'package:reservoir/reservoir.dart';
import 'package:quiver/iterables.dart';

part 'password.keys.dart';

class PasswordReservoir extends Reservoir<_IdKey, Password> {
  PasswordReservoir() : super(_IdKey());

  int get maxPasswordID =>
      max([for (var password in data) password.passwordId]) ?? -1;
}
