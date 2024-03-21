import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubits.dart';
import 'package:moontree/presentation/ui/appbar/header.dart';

class AppbarLayer extends StatelessWidget {
  const AppbarLayer({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AppbarCubit, AppbarState>(
          builder: (BuildContext context, AppbarState state) {
        return const Positioned(top: 0, child: AppbarHeader());
      });
}
