import 'package:flutter/material.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/theme/text.dart';
import 'package:magic/services/services.dart';

class ConfirmContentPlaceholder extends StatelessWidget {
  const ConfirmContentPlaceholder({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: screen.pane.midHeight,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 42),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Circular placeholder for CurrencyIdenticon
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.frontItem,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Rounded placeholder for address
                      Expanded(
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.frontItem,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Placeholder for Fee
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _PlaceholderItem(),
            ),
            const Divider(height: 1, indent: 0, endIndent: 0),
            // Placeholder for Amount
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _PlaceholderItem(),
            ),
            const SizedBox(height: 8),
            // Placeholder for Send button
            Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 12, bottom: 24),
                child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                        child: Text(
                      'SEND',
                      style: AppText.button1
                          .copyWith(fontSize: 16, color: Colors.grey),
                    )))),
          ],
        ),
      );
}

class _PlaceholderItem extends StatelessWidget {
  const _PlaceholderItem();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.frontItem,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
