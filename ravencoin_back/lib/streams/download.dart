import 'package:rxdart/rxdart.dart';
import 'package:ravencoin_back/records/address.dart';

class DownloadStreams {
  final address = PublishSubject<Address>();
}
