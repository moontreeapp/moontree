part of 'status.dart';

// primary key

class _StatusKey extends Key<Status> {
  @override
  String getKey(Status status) => status.id;
}

extension ByIdMethodsForStatus on Index<_StatusKey, Status> {
  Status? getOne(String hash) => getByKeyStr(hash).firstOrNull;
}

// byStatusType

class _StatusTypeKey extends Key<Status> {
  @override
  String getKey(Status status) => status.statusType.name;
}

extension ByStatusTypeMethodsForStatus on Index<_StatusTypeKey, Status> {
  List<Status> getAll(StatusType statusType) => getByKeyStr(statusType.name);
}

// byAddress

class _AddressKey extends Key<Status> {
  @override
  String getKey(Status status) => status.id;
}

extension ByAddressMethodsForStatus on Index<_AddressKey, Status> {
  Status? getOne(Address address) =>
      getByKeyStr(Status.statusId(address.id, StatusType.address)).firstOrNull;
}

// byAsset

class _AssetKey extends Key<Status> {
  @override
  String getKey(Status status) => status.id;
}

extension ByAssetMethodsForStatus on Index<_AssetKey, Status> {
  Status? getOne(Asset asset) =>
      getByKeyStr(Status.statusId(asset.id, StatusType.asset)).firstOrNull;
}

// byBlockHeight

class _BlockHeightKey extends Key<Status> {
  @override
  String getKey(Status status) => status.id;
}

extension ByBlockHeightMethodsForStatus on Index<_BlockHeightKey, Status> {
  Status? getOne(String header) =>
      getByKeyStr(Status.statusId(header, StatusType.header)).firstOrNull;
}
