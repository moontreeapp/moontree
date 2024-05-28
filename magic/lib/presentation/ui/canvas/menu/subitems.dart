import 'package:flutter/material.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/presentation/theme/text.dart';
import 'package:magic/presentation/ui/welcome/welcome.dart';
import 'package:magic/services/services.dart';

class BackupItem extends StatelessWidget {
  const BackupItem({super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => cubits.welcome.update(active: true, child: const Backup()),
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

class NotificationItem extends StatelessWidget {
  final MenuState state;
  const NotificationItem({super.key, required this.state});

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: cubits.menu.toggleSetting,
      child: Container(
          height: screen.menu.itemHeight,
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
