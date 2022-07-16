import 'package:collection/collection.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:proclaim/proclaim.dart';

part 'note.keys.dart';

class NoteProclaim extends Proclaim<_NoteIdKey, Note> {
  NoteProclaim() : super(_NoteIdKey());
}
