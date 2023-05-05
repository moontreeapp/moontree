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
  /// location cubit must be made first since cubits register callbacks on it.
  final LocationCubit location = LocationCubit();
  final TransactionsViewCubit transactionsView = TransactionsViewCubit();
  final SimpleSendFormCubit simpleSendForm = SimpleSendFormCubit();
  final TransactionViewCubit transactionView = TransactionViewCubit();
  final WalletHoldingsViewCubit holdingsView = WalletHoldingsViewCubit();
  //final LoadingViewCubit loadingView = LoadingViewCubit();
  final ReceiveViewCubit receiveView = ReceiveViewCubit();
  final TitleCubit title = TitleCubit();
  final LoginCubit login = LoginCubit();
  final BackContainerCubit backContainer = BackContainerCubit();
  final FrontContainerCubit frontContainer = FrontContainerCubit();
  final ExtraContainerCubit extraContainer = ExtraContainerCubit();
  final SnackbarCubit snackbar = SnackbarCubit();
  final NavbarCubit navbar = NavbarCubit();
  final BottomModalSheetCubit bottomModalSheet = BottomModalSheetCubit();
  final MessageModalCubit messageModal = MessageModalCubit();
  final LoadingViewCubit loadingView = LoadingViewCubit();
  final ImportFormCubit import = ImportFormCubit();
  final ConnectionStatusCubit connection = ConnectionStatusCubit();
  final TutorialCubit tutorial = TutorialCubit();
  GlobalCubits();
}
