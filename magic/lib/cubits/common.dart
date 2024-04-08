import 'package:equatable/equatable.dart';

abstract class CubitState extends Equatable {
  final bool isSubmitting;
  final CubitState? prior;

  const CubitState({this.isSubmitting = false, this.prior});

  @override
  List<Object?> get props => [isSubmitting, prior];

  @override
  String toString() => 'CubitState(isSubmitting:$isSubmitting, prior=$prior)';

  CubitState get withoutPrior => QbitState(isSubmitting: isSubmitting);
}

class QbitState extends CubitState {
  const QbitState({required super.isSubmitting, super.prior});
}
