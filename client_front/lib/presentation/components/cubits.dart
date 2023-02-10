/// this pattern - global cubits - is due to the fact that our app bar is not
/// part of each page that we navigate to. when going back to the home page
/// from transactions list, for example, we must clear the transactionsViewCubit
/// or just make a new one each time we open the page, which is what
/// BlockProvider is for, but that context, (the app bar back button) isn't
/// built with the cubit providers in it, so it doesn't have access to the
/// instance to trigger the clear. so we save it here, and can access any cubit
/// from anywhere. easy.

import 'package:client_front/application/cubits.dart';

class GlobalCubits {
  final TransactionsViewCubit transactionsViewCubit = TransactionsViewCubit();
  final SimpleSendFormCubit simpleSendFormCubit = SimpleSendFormCubit();
  final TransactionViewCubit transactionViewCubit = TransactionViewCubit();
  final HoldingsViewCubit holdingsViewCubit = HoldingsViewCubit();
  final LoadingViewCubit loadingViewCubit = LoadingViewCubit();
  final ReceiveViewCubit receiveViewCubit = ReceiveViewCubit();
  GlobalCubits();
}
