import 'package:client_back/client_back.dart';
import 'package:client_front/infrastructure/calls/mock_flag.dart';
import 'package:client_front/infrastructure/services/subscription.dart';

/// only here because all the other client connections are also in this folder.
Future<void> setupSubscription({
  Wallet? wallet,
  Chain? chain,
  Net? net,
}) async =>
    mockFlag
        ? () {}
        : subscription.setupSubscription(
            wallet: wallet,
            chain: chain,
            net: net,
          );
