import 'package:collection/collection.dart';
import 'package:proclaim/proclaim.dart';
import 'package:client_back/client_back.dart';

part 'note.keys.dart';

class NoteProclaim extends Proclaim<_IdKey, Note> {
  NoteProclaim() : super(_IdKey());
}
