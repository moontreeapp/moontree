import 'package:raven/raven.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:rxdart/rxdart.dart';

/// client object
final ravenClientSubject = BehaviorSubject<RavenElectrumClient?>();

/// resumed inactive paused detached
final appStatusSubject = BehaviorSubject<String?>();

final loginSubject = BehaviorSubject<bool>();

final cipherUpdateSubject = BehaviorSubject<CipherUpdate>();
