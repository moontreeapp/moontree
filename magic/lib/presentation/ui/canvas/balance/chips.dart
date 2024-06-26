import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/pane/wallet/cubit.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/services/services.dart';

enum Chips {
  all,
  evrmore,
  ravencoin,
  nonzero,
  currencies,
  nfts,
  admintokens;

  String get label {
    switch (this) {
      case Chips.all:
        return 'All';
      case Chips.evrmore:
        return 'Evrmore';
      case Chips.ravencoin:
        return 'Ravencoin';
      case Chips.nonzero:
        return 'Nonzero';
      case Chips.currencies:
        return 'Currencies';
      case Chips.nfts:
        return 'NFTs';
      case Chips.admintokens:
        return 'Admin Tokens';
    }
  }

  bool Function(Holding) get filter {
    switch (this) {
      case Chips.all:
        return (Holding holding) => true;
      case Chips.evrmore:
        return (Holding holding) => holding.isOnEvrmore;
      case Chips.ravencoin:
        return (Holding holding) => holding.isOnRavencoin;
      case Chips.nonzero:
        return (Holding holding) => holding.sats.value > 0;
      case Chips.currencies:
        return (Holding holding) => holding.isCurrency;
      case Chips.nfts:
        return (Holding holding) => holding.isNft;
      case Chips.admintokens:
        return (Holding holding) => holding.weHaveAdminOrMain;
    }
  }

  static bool Function(Holding) combinedFilter(List<Chips> chips) {
    if (chips.length == 1) {
      return chips.first.filter;
    }
    // order by index
    chips.sort((a, b) => a.index.compareTo(b.index));
    if (chips.length == 2) {
      if (chips.first == Chips.evrmore ||
          chips.first == Chips.ravencoin ||
          chips.first == Chips.nonzero) {
        return (Holding holding) =>
            chips.first.filter(holding) && chips.last.filter(holding);
      }
      return (Holding holding) =>
          chips.first.filter(holding) || chips.last.filter(holding);
    }
    if (chips.length == 3) {
      if ((chips.first == Chips.evrmore || chips.first == Chips.ravencoin) &&
          chips[1] == Chips.nonzero) {
        return (Holding holding) =>
            chips.first.filter(holding) &&
            chips[1].filter(holding) &&
            chips.last.filter(holding);
      }
      if ((chips.first == Chips.evrmore || chips.first == Chips.ravencoin) &&
          chips[1] != Chips.nonzero) {
        return (Holding holding) =>
            chips.first.filter(holding) &&
            (chips[1].filter(holding) || chips.last.filter(holding));
      }
      return (Holding holding) =>
          chips.first.filter(holding) ||
          chips[1].filter(holding) ||
          chips.last.filter(holding);
    }
    if (chips.length == 4) {
      if ((chips.first == Chips.evrmore || chips.first == Chips.ravencoin) &&
          chips[1] == Chips.nonzero) {
        return (Holding holding) =>
            chips.first.filter(holding) &&
            chips[1].filter(holding) &&
            (chips[2].filter(holding) || chips.last.filter(holding));
      }
      if ((chips.first == Chips.evrmore || chips.first == Chips.ravencoin) &&
          chips[1] != Chips.nonzero) {
        return (Holding holding) =>
            chips.first.filter(holding) &&
            (chips[1].filter(holding) ||
                chips[2].filter(holding) ||
                chips.last.filter(holding));
      }
      return (Holding holding) =>
          chips.first.filter(holding) ||
          chips[1].filter(holding) ||
          chips[2].filter(holding) ||
          chips.last.filter(holding);
    }
    if (chips.length == 5) {
      if ((chips.first == Chips.evrmore || chips.first == Chips.ravencoin) &&
          chips[1] == Chips.nonzero) {
        return (Holding holding) =>
            chips.first.filter(holding) &&
            chips[1].filter(holding) &&
            (chips[2].filter(holding) ||
                chips[3].filter(holding) ||
                chips.last.filter(holding));
      }
      if ((chips.first == Chips.evrmore || chips.first == Chips.ravencoin) &&
          chips[1] != Chips.nonzero) {
        return (Holding holding) =>
            chips.first.filter(holding) &&
            (chips[1].filter(holding) ||
                chips[2].filter(holding) ||
                chips[3].filter(holding) ||
                chips.last.filter(holding));
      }
      return (Holding holding) =>
          chips.first.filter(holding) ||
          chips[1].filter(holding) ||
          chips[2].filter(holding) ||
          chips[3].filter(holding) ||
          chips.last.filter(holding);
    }
    return (Holding holding) =>
        [for (final chip in chips) chip.filter(holding)].any((e) => e);
  }

  //bool Function(Holding) withYourPwersCombined(Chips chip) {
  //  if (this == chip) return true;
  //  final first = index < chip.index ? this: chip;
  //  final last = index > chip.index ? this: chip;
  //  if (first == Chips.currencies && last == Chips.evrmore) {
//
  //  }
  //
//
  //  Chips.evrmore + Chips.ravencoin == 'additive'
  //  Chips.evrmore + Chips.currencies == 'additive'
  //  Chips.evrmore + Chips.nonzero == 'sub'
  //  Chips.evrmore + Chips.nfts == 'sub'
  //
  //  return resultsMatrix[index][chip.index];
  //}
}

class ChipsView extends StatelessWidget {
  const ChipsView({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<MenuCubit, MenuState>(
      buildWhen: (MenuState previous, MenuState current) =>
          previous.mode != current.mode,
      builder: (BuildContext context, MenuState state) => state.mode ==
              DifficultyMode.easy
          ? const SizedBox(height: 58)
          : BlocBuilder<WalletCubit, WalletState>(
              buildWhen: (WalletState previous, WalletState current) =>
                  previous.chips != current.chips,
              builder: (BuildContext context, WalletState state) => Container(
                  padding: const EdgeInsets.all(16),
                  width: screen.width,
                  height: 26 + 16 + 16,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: cubits.wallet.defaultChips.length,
                      itemBuilder: (context, index) => ChipItem(
                            chip: cubits.wallet.defaultChips[index],
                            selected: state.chips
                                .contains(cubits.wallet.defaultChips[index]),
                          )))));
}

class ChipItem extends StatelessWidget {
  final Chips chip;
  final bool selected;
  const ChipItem({super.key, required this.chip, this.selected = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () => cubits.wallet.toggleChip(chip),
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: chip == Chips.nonzero
              ? const BoxDecoration(
                  border: Border(
                      left: BorderSide(
                        color: AppColors.white12,
                        width: 1.0,
                      ),
                      right: BorderSide(
                        color: AppColors.white12,
                        width: 1.0,
                      )))
              : null,
          child: Container(
              padding:
                  const EdgeInsets.only(left: 6, right: 6, top: 3, bottom: 1),
              height: 26,
              decoration: BoxDecoration(
                  color: selected ? AppColors.white60 : null,
                  border: Border.all(color: AppColors.white38, width: 1),
                  borderRadius: BorderRadius.circular(100)),
              child: Text(chip.label,
                  style: TextStyle(
                      color:
                          selected ? AppColors.background : AppColors.white87,
                      height: 0)))));
}
