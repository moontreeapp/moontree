part of 'status.dart';

// primary key

class _IdKey extends Key<Status> {
  @override
  String getKey(Status status) => status.id;
}

extension ByIdMethodsForStatus on Index<_IdKey, Status> {
  Status? getOneByAddress(Address address) =>
      getByKeyStr(Status.key(address.id, StatusType.address)).firstOrNull;
  Status? getOneByAsset(Asset asset) =>
      getByKeyStr(Status.key(asset.id, StatusType.asset)).firstOrNull;
  Status? getOneByHeight(String header) =>
      getByKeyStr(Status.key(header, StatusType.header)).firstOrNull;
}

// byStatusType

class _StatusTypeKey extends Key<Status> {
  @override
  String getKey(Status status) => status.statusType.name;
}

extension ByStatusTypeMethodsForStatus on Index<_StatusTypeKey, Status> {
  List<Status> getAll(StatusType statusType) => getByKeyStr(statusType.name);
}
