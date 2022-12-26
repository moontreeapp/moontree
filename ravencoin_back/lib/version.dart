/// this is the source of truth for versions.
/// version.py script looks at this map.
/// so set the versions but don't alter the code structure.
const Map<String, Map<String, String>> VERSIONS = <String, Map<String, String>>{
  'ios': <String, String>{'alpha': '1.3.10+11~1', 'version': '1.7.0+27~1'},
  'android': <String, String>{'alpha': '1.0.1+2~1', 'version': '1.7.0+5~1'}
};

const String VERSION_TRACK = 'version';
//const RELEASE_VERSION = '1.0.0+0~1';
//final String VERSION = VERSIONS['android']!['beta']!;
