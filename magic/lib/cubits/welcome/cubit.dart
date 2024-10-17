import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/concepts/side.dart';

import 'package:magic/services/security.dart';

part 'state.dart';

class WelcomeCubit extends UpdatableCubit<WelcomeState> {
  WelcomeCubit() : super(const WelcomeState());

  @override
  String get key => 'welcome';

  @override
  void reset() => emit(const WelcomeState());

  @override
  void setState(WelcomeState state) => emit(state);

  @override
  void refresh() => update(isSubmitting: true);

  @override
  void hide() => update(active: false);

  @override
  void activate() => update(active: true);

  @override
  void deactivate() {
    update(
      active: false,
      allowScreenshot: true,
    );
  }

  @override
  void update({
    bool? active,
    Widget? child,
    Side? transition,
    bool? isSubmitting,
    bool allowScreenshot = true,
  }) {
    emit(WelcomeState(
      active: active ?? state.active,
      child: child ?? state.child,
      transition: transition ?? state.transition,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: state.withoutPrior,
    ));

    if (allowScreenshot) {
      securityService.enableScreenshot();
    } else {
      securityService.disableScreenshot();
    }
  }
}
