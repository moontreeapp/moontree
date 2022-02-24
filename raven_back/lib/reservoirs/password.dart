import 'package:collection/collection.dart';
import 'package:raven_back/records/password.dart';
import 'package:reservoir/reservoir.dart';
import 'package:quiver/iterables.dart';

part 'password.keys.dart';

class PasswordReservoir extends Reservoir<_IdKey, Password> {
  PasswordReservoir() : super(_IdKey());

  int? get maxPasswordId => max([for (var password in data) password.id]);

  Password? get current =>
      data.where((password) => password.id == maxPasswordId).firstOrNull;
}
