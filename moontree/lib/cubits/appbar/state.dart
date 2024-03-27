part of 'cubit.dart';

enum AppbarLeading {
  connection,
  back,
  close,
  none,
}

class AppbarState with EquatableMixin {
  final AppbarLeading leading;
  final String title;
  final AppbarState? prior;

  const AppbarState({
    this.leading = AppbarLeading.none,
    this.title = '',
    this.prior,
  });

  @override
  List<Object?> get props => [
        leading,
        title,
        prior,
      ];

  @override
  String toString() => 'AppbarState( '
      'leading=$leading, '
      'title=$title, '
      'prior=$prior, '
      ')';

  AppbarState get withoutPrior => AppbarState(
        leading: leading,
        title: title,
        prior: null,
      );
}
