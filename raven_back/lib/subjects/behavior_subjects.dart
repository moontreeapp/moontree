import 'package:raven/raven.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:rxdart/rxdart.dart';

final ravenClientSubject = BehaviorSubject<RavenElectrumClient?>();
final loginSubject = BehaviorSubject<bool>();
final cipherUpdateSubject = BehaviorSubject<CipherUpdate>();
