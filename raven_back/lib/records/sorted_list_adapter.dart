/// should this be generated?

import 'package:hive/hive.dart';
import 'package:sorted_list/sorted_list.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

class SortedListAdapter extends TypeAdapter<SortedList> {
  @override
  final typeId = 8;

  @override
  SortedList read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    var sortedList = SortedList<ScripthashUnspent>(
        (ScripthashUnspent a, ScripthashUnspent b) =>
            a.value.compareTo(b.value));
    sortedList.addAll(fields[0] as Iterable<ScripthashUnspent>);
    return sortedList;
  }

  @override
  void write(BinaryWriter writer, SortedList obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj);
  }
}
