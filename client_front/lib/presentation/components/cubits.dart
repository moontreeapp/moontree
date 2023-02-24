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
  final TransactionsViewCubit transactionsView = TransactionsViewCubit();
  final SimpleSendFormCubit simpleSendForm = SimpleSendFormCubit();
  final TransactionViewCubit transactionView = TransactionViewCubit();
  final HoldingsViewCubit holdingsView = HoldingsViewCubit();
  //final LoadingViewCubit loadingView = LoadingViewCubit();
  final ReceiveViewCubit receiveView = ReceiveViewCubit();

  // uiv2
  final TitleCubit title = TitleCubit();
  final LoginCubit login = LoginCubit();
  final BackContainerCubit backContainer = BackContainerCubit();
  final FrontContainerCubit frontContainer = FrontContainerCubit();
  final ExtraContainerCubit extraContainer = ExtraContainerCubit();
  final NavbarHeightCubit navbarHeight = NavbarHeightCubit();
  final NavbarSectionCubit navbarSection = NavbarSectionCubit();
  final BottomModalSheetCubit bottomModalSheet = BottomModalSheetCubit();
  final LoadingViewCubit loadingView = LoadingViewCubit();

  GlobalCubits();
}
