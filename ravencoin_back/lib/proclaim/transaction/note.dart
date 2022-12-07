import 'package:collection/collection.dart';
import 'package:proclaim/proclaim.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

part 'note.keys.dart';

class NoteProclaim extends Proclaim<_IdKey, Note> {
  NoteProclaim() : super(_IdKey());
}
