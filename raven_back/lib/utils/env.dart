import 'dart:io';
import 'dart:async';

Future<String> getMnemonic() async {
  try {
    final file = File('.env');
    return await file.readAsString();
  } catch (e) {
    return 'smile build brain topple moon scrap area aim budget enjoy polar erosion';
  }
}
