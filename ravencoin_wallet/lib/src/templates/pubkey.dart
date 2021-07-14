import '../utils/script.dart' as bscript;

bool inputCheck(List<dynamic> chunks) {
  return chunks.length == 1 && bscript.isCanonicalScriptSignature(chunks[0]);
}

// TODO
// bool outputCheck(Uint8List script) {
// }
