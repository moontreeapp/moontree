import 'package:collection/collection.dart';
import 'package:raven_back/raven_back.dart';
import 'package:reservoir/reservoir.dart';

part 'note.keys.dart';

class NoteReservoir extends Reservoir<_NoteIdKey, Note> {
  NoteReservoir() : super(_NoteIdKey());
}
