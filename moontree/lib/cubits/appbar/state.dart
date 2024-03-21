part of 'cubit.dart';

enum AppbarTitleType {
  wallet,
  custom,
  none,
}

class AppbarState with EquatableMixin {
  final AppbarTitleType titleType;
  final String title;
  final AppbarState? prior;

  const AppbarState({
    this.titleType = AppbarTitleType.none,
    this.title = '',
    this.prior,
  });

  @override
  List<Object?> get props => [
        titleType,
        title,
        prior,
      ];

  @override
  String toString() => 'AppbarState( '
      'titleType=$titleType, '
      'title=$title, '
      'prior=$prior, '
      ')';

  AppbarState get withoutPrior => AppbarState(
        titleType: titleType,
        title: title,
        prior: null,
      );
}
