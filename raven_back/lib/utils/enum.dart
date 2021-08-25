String describeEnum(Object enumEntry) {
  // ignore: omit_local_variable_types
  final String description = enumEntry.toString();
  // ignore: omit_local_variable_types
  final int indexOfDot = description.indexOf('.');
  assert(
    indexOfDot != -1 && indexOfDot < description.length - 1,
    'The provided object "$enumEntry" is not an enum.',
  );
  return description.substring(indexOfDot + 1);
}
// print(SettingName.Electrum_Url.toString().split('.')[1]);
// //import 'package:flutter/foundation.dart';
// //print(describeEnum(SettingName.Electrum_Url));