part of 'cubit.dart';

enum AppbarLeading {
  menu,
  back,
  close,
  none,
}

class AppbarState with EquatableMixin {
  final AppbarLeading leading;
  final String title;
  final Widget? titleChild;
  final VoidCallback? onLead;
  final VoidCallback? onTitle;
  final AppbarState? prior;

  const AppbarState({
    this.leading = AppbarLeading.none,
    this.title = '',
    this.titleChild,
    this.onLead,
    this.onTitle,
    this.prior,
  });

  @override
  List<Object?> get props => [
        leading,
        title,
        titleChild,
        onLead,
        onTitle,
        prior,
      ];

  @override
  String toString() => 'AppbarState( '
      'leading=$leading, '
      'title=$title, '
      'titleChild=$titleChild, '
      'onLead=$onLead, '
      'onTitle=$onTitle, '
      'prior=$prior, '
      ')';

  AppbarState get withoutPrior => AppbarState(
        leading: leading,
        title: title,
        titleChild: titleChild,
        onLead: onLead,
        onTitle: onTitle,
        prior: null,
      );
}
