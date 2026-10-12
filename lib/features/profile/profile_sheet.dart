import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../app/widgets/neon_close_button.dart';
import '../../core/format.dart';
import '../../economy/wallet.dart';
import '../settings/settings.dart';
import 'player.dart';

/// Centered profile popup: big avatar + name, avatar picker, stats.
Future<void> showProfileSheet(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close profile',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, _, _) => const _ProfilePanel(),
    transitionBuilder: (_, animation, _, child) => ScaleTransition(
      scale: Tween(
        begin: 0.85,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
      child: FadeTransition(opacity: animation, child: child),
    ),
  );
}

class _ProfilePanel extends ConsumerWidget {
  const _ProfilePanel();

  static const _w = 620.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final coins = ref.watch(walletProvider);
    final notifier = ref.read(playerProvider.notifier);
    final feedback = ref.read(settingsProvider.notifier).tapFeedback;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width: _w,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF4A148C), AppColors.deepPurple],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.hotPink, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.hotPink.withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text('PROFILE', style: AppText.gold(26)),
                        const Spacer(),
                        NeonCloseButton(
                          onTap: () {
                            feedback();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: current avatar and name.
                        SizedBox(
                          width: 180,
                          child: Column(
                            children: [
                              Image.asset(
                                player.avatarAsset,
                                width: 150,
                                height: 150,
                              ),
                              const SizedBox(height: 10),
                              _NameButton(
                                name: player.name,
                                onTap: () async {
                                  feedback();
                                  final name = await _askName(
                                    context,
                                    player.name,
                                  );
                                  if (name != null) notifier.setName(name);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 22),
                        // Right: picker and stats.
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CHOOSE AVATAR', style: AppText.label(14)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  for (final MapEntry(key: id, value: asset)
                                      in avatars.entries)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: _AvatarChoice(
                                        asset: asset,
                                        selected: id == player.avatarId,
                                        onTap: () {
                                          feedback();
                                          notifier.setAvatar(id);
                                        },
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  _Stat('LEVEL', '${player.level}'),
                                  _Stat('COINS', formatCents(coins)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _Stat(
                                    'TOTAL WON',
                                    formatCents(player.totalWonCents),
                                  ),
                                  _Stat('SPINS', '${player.totalSpins}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small rename dialog. Returns null if cancelled.
Future<String?> _askName(BuildContext context, String current) {
  final controller = TextEditingController(text: current);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.royalPurple,
      title: Text('Your name', style: AppText.label(18)),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: PlayerNotifier.maxNameLength,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: const Text('Save'),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}

class _NameButton extends StatelessWidget {
  const _NameButton({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Edit name',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.violet),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.label(16),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.edit_rounded, color: AppColors.gold, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarChoice extends StatelessWidget {
  const _AvatarChoice({
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  final String asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? const Color(0xFF7CFF6B) : Colors.transparent,
            width: 3,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF7CFF6B).withValues(alpha: 0.6),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Opacity(
          opacity: selected ? 1 : 0.7,
          child: Image.asset(asset, width: 64, height: 64),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.violet.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppText.label(11).copyWith(color: const Color(0xFFCDB8F5)),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: AppText.gold(18)),
            ),
          ],
        ),
      ),
    );
  }
}
