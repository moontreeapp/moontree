import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';

BehaviorSubject<Map> createMapSubject(String hiveBoxName, {Map? defaults}) {
  var box = Hive.box<dynamic>(hiveBoxName);

  //inject defaults
  if (box.isEmpty && defaults != null) {
    box.addAll(defaults.entries);
  }

  // Get all existing map values
  var valuesMap = box.toMap();

  // Create the 'store' that will be returned
  var subject = BehaviorSubject<Map>();

  // Populate first value
  subject.add(valuesMap);

  // Watch for new values
  box.watch().listen((BoxEvent e) {
    if (e.deleted) {
      valuesMap.remove(e.key);
    } else {
      if (valuesMap[e.key] != e.value) valuesMap[e.key] = e.value;
    }
    subject.add(valuesMap);
  });

  return subject;
}
