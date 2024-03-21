import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubits.dart';
import 'package:moontree/presentation/ui/navbar/sections.dart';

class NavbarLayer extends StatelessWidget {
  const NavbarLayer({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<NavbarCubit, NavbarState>(
          builder: (BuildContext context, NavbarState state) {
        return NavbarSections(section: state.section);
      });
}
