import 'package:ravencoin_back/records/types/node_exposure.dart';

String getDerivationPath(int index,
        {exposure = NodeExposure.External, bool mainnet = true}) =>
    "m/44'/${mainnet ? '175' : '1'}'/0'/"
    '${{
      NodeExposure.External: '0',
      NodeExposure.Internal: '1',
    }[exposure]!}/$index';
