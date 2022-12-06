import 'package:equatable/equatable.dart';

void main() {
  var lws = LeaderWalletService();
  print(lws.indexRegistry);
  lws.getIndexOf('a', 'b');
  print(lws.indexRegistry);
  lws.getIndexOf('x', 'y');
  print(lws.indexRegistry);
  lws.updateIndexOf('x', 'y', used: 21);
  print(lws.indexRegistry);
  lws.updateIndexOf('x', 'y', usedPlus: 39);
  print(lws.indexRegistry);
  lws.updateIndexOf('a', 'b', saved: 20);
  print(lws.indexRegistry);
  lws.updateIndexOf('a', 'c', saved: 24);
  print(lws.indexRegistry);
  lws.updateIndexOf('a', 'c', savedPlus: 24);
  print(lws.indexRegistry);
}

class LeaderWalletService {
  Map<LeaderExposureKey, LeaderExposureIndex> indexRegistry = {};

  /// caching optimization
  LeaderExposureIndex getIndexOf(String leader, String exposure) {
    var key = LeaderExposureKey(leader, exposure);
    if (!indexRegistry.keys.contains(key)) {
      indexRegistry[key] = LeaderExposureIndex();
    }
    return indexRegistry[key]!;
  }

  void updateIndexOf(String leader, String exposure,
      {int? saved, int? used, int? savedPlus, int? usedPlus}) {
    var key = LeaderExposureKey(leader, exposure);
    if (!indexRegistry.keys.contains(key)) {
      indexRegistry[key] = LeaderExposureIndex();
    }
    if (saved != null) {
      indexRegistry[key]!.updateSaved(saved);
    }
    if (used != null) {
      indexRegistry[key]!.updateUsed(used);
    }
    if (savedPlus != null) {
      indexRegistry[key]!.updateSavedPlus(savedPlus);
    }
    if (usedPlus != null) {
      indexRegistry[key]!.updateUsedPlus(usedPlus);
    }
  }
}

class LeaderExposureKey with EquatableMixin {
  String leader;
  String exposure;

  LeaderExposureKey(this.leader, this.exposure);

  String get key => produceKey(leader, exposure);
  static String produceKey(String walletId, String exposure) =>
      walletId + exposure;

  @override
  List<Object> get props => <Object>[leader, exposure];

  @override
  String toString() => '$leader, $exposure';
}

class LeaderExposureIndex {
  int saved = 0;
  int used = 0;

  LeaderExposureIndex({this.saved = -1, this.used = -1});

  int get currentGap => saved - used;

  void updateSaved(int value) => saved = value > saved ? value : saved;
  void updateUsed(int value) => used = value > used ? value : used;
  void updateSavedPlus(int value) => saved = saved + value;
  void updateUsedPlus(int value) => used = used + value;

  @override
  String toString() => '$saved, $used';
}
