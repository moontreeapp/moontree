import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/mixins.dart';

part 'state.dart';

class ManageCubit extends Cubit<ManageState> with UpdateHideMixin<ManageState> {
  ManageCubit() : super(const ManageState());
  double height = 0;
  @override
  String get key => 'manage';
  @override
  void reset() => emit(const ManageState());
  @override
  void setState(ManageState state) => emit(state);
  @override
  void hide() => update(active: false);

  @override
  void update({
    bool? active,
    String? asset,
    String? chain,
    String? address,
    bool? isSubmitting,
    ManageState? prior,
  }) {
    emit(ManageState(
      active: active ?? state.active,
      asset: asset ?? state.asset,
      chain: chain ?? state.chain,
      address: address ?? state.address,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: prior ?? state.withoutPrior,
    ));
  }
}
