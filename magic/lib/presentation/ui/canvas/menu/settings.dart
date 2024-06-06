import 'package:flutter/material.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/presentation/theme/text.dart';
import 'package:magic/presentation/ui/welcome/backup.dart';
import 'package:magic/presentation/ui/welcome/import.dart';
import 'package:magic/presentation/ui/welcome/wallets.dart';
import 'package:magic/services/services.dart';

class DifficultyItem extends StatelessWidget {
  final DifficultyMode mode;
  const DifficultyItem({super.key, required this.mode});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: cubits.menu.toggleDifficulty,
        child: Container(
            height: screen.menu.itemHeight,
            width: screen.width,
            color: Colors.transparent,
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Icon(mode.icon, color: Colors.white),
              const SizedBox(width: 16),
              Text('Mode: ${mode.name}',
                  style: AppText.h2.copyWith(color: Colors.white)),
            ])),
      );
}

class NotificationItem extends StatelessWidget {
  final MenuState state;
  const NotificationItem({super.key, required this.state});

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: cubits.menu.toggleSetting,
      child: Container(
          height: screen.menu.itemHeight,
          width: screen.width,
          color: Colors.transparent,
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Icon(
                state.setting
                    ? Icons.notifications_on_rounded
                    : Icons.notifications_off_rounded,
                color: Colors.white),
            const SizedBox(width: 16),
            Text('Notification: ${state.setting ? 'On' : 'Off'}',
                style: AppText.h2.copyWith(color: Colors.white)),
          ])));
}

class BackupItem extends StatelessWidget {
  const BackupItem({super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () =>
            cubits.welcome.update(active: true, child: const BackupPage()),
        child: Container(
            height: screen.menu.itemHeight,
            width: screen.width,
            color: Colors.transparent,
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              const Icon(Icons.key_sharp, color: Colors.white),
              const SizedBox(width: 16),
              Text('Backup', style: AppText.h2.copyWith(color: Colors.white)),
            ])),
      );
}

class ImportItem extends StatelessWidget {
  const ImportItem({super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () =>
            cubits.welcome.update(active: true, child: const ImportPage()),
        child: Container(
            height: screen.menu.itemHeight,
            width: screen.width,
            color: Colors.transparent,
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              const Icon(Icons.add_circle_rounded, color: Colors.white),
              const SizedBox(width: 16),
              Text('Import', style: AppText.h2.copyWith(color: Colors.white)),
            ])),
      );
}

class WalletsItem extends StatelessWidget {
  const WalletsItem({super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () =>
            cubits.welcome.update(active: true, child: const WalletsPage()),
        child: Container(
            height: screen.menu.itemHeight,
            width: screen.width,
            color: Colors.transparent,
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              const Icon(Icons.wallet_rounded, color: Colors.white),
              const SizedBox(width: 16),
              Text('Wallets', style: AppText.h2.copyWith(color: Colors.white)),
            ])),
      );
}
