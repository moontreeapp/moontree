import '../../raven_electrum.dart';

extension GetFeeEstimateMethod on RavenElectrumClient {
  Future<double> getRelayFee() async => ((await request(
        'blockchain.relayfee', // 0.01 rvn per vkb
      ) as double));

  Future<double> getFeeEstimate(int numberOfBlocks) async => ((await request(
        'blockchain.estimatefee',
        [numberOfBlocks],
      ) as double));
}
