export 'records/records.dart';
export 'proclaim/proclaim.dart';
export 'security/security.dart';
export 'services/services.dart';
export 'streams/streams.dart';
export 'waiters/waiters.dart';
export 'extensions/extensions.dart';

export 'hive_initializer.dart';
export 'init.dart';
export 'joins/joins.dart';

export 'utilities/utilities.dart';
export 'lingo/lingo.dart';

export 'package:proclaim/change.dart';

/// this is the source of truth for versions.
/// version.py script looks at this map.
/// so set the versions but don't alter the code structure.
const VERSIONS = {
  'ios': {'alpha': '1.3.10+11~1', 'beta': '1.4.1+13~1'},
  'android': {'alpha': '1.0.1+2~1', 'beta': '1.0.1+2~1'}
};

//const RELEASE_VERSION = '1.0.0+0~1';
//final String VERSION = VERSIONS['android']!['beta']!;
