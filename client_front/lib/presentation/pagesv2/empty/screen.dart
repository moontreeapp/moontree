import 'package:client_front/presentation/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:client_front/presentation/services/services.dart' as services;

class EmptyScreen extends StatelessWidget {
  const EmptyScreen({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('backEmpty');

  @override
  Widget build(BuildContext context) {
    return Container(
      height: services.screen.app.height,
      color: AppColors.primary,
    );
  }
}
