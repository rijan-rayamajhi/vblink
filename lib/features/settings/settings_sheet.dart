import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import 'settings.dart';

const appVersion = '1.0.0';

/// Slides the settings panel in from the right edge.
Future<void> showSettingsSheet(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close settings',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, _, _) => const _SettingsPanel(),
    transitionBuilder: (_, animation, _, child) => SlideTransition(
      position: Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}

class _SettingsPanel extends ConsumerWidget {
  const _SettingsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final size = MediaQuery.sizeOf(context);
    final h = size.height;

    return Align(
      alignment: Alignment.centerRight,
      child: SafeArea(
        left: false,
        child: Padding(
          padding: EdgeInsets.all(h * 0.03),
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: (h * 0.95).clamp(280.0, 460.0),
              padding: EdgeInsets.symmetric(
                horizontal: h * 0.05,
                vertical: h * 0.035,
              ),
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
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: (h * 0.95).clamp(280.0, 460.0) - h * 0.1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Text('SETTINGS', style: AppText.gold(26)),
                          const Spacer(),
                          _CloseButton(
                            onTap: () {
                              notifier.tapFeedback();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _ToggleRow(
                        icon: Icons.music_note_rounded,
                        label: 'Music',
                        value: settings.music,
                        onChanged: (v) {
                          notifier.setMusic(v);
                          notifier.tapFeedback();
                        },
                      ),
                      _ToggleRow(
                        icon: Icons.volume_up_rounded,
                        label: 'Sound Effects',
                        value: settings.soundEffects,
                        onChanged: (v) {
                          notifier.setSoundEffects(v);
                          notifier.tapFeedback();
                        },
                      ),
                      _ToggleRow(
                        icon: Icons.vibration_rounded,
                        label: 'Vibration',
                        value: settings.vibration,
                        onChanged: (v) {
                          notifier.setVibration(v);
                          notifier.tapFeedback();
                        },
                      ),
                      const SizedBox(height: 14),
                      const _AboutBox(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.violet.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.gold, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(label, style: AppText.label(17)),
                ),
              ),
              const SizedBox(width: 8),
              _NeonSwitch(value: value),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pill switch: green and glowing when on, dim purple when off.
class _NeonSwitch extends StatelessWidget {
  const _NeonSwitch({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    const w = 58.0, h = 30.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: w,
      height: h,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: value ? const Color(0xFF15A84A) : const Color(0xFF3A2A5A),
        borderRadius: BorderRadius.circular(h),
        border: Border.all(color: value ? Colors.white : Colors.white24),
        boxShadow: value
            ? [
                BoxShadow(
                  color: const Color(0xFF7CFF6B).withValues(alpha: 0.6),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: h - 8,
          height: h - 8,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _AboutBox extends StatelessWidget {
  const _AboutBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text('Version $appVersion', style: AppText.label(13)),
          const SizedBox(height: 6),
          Text(
            'Offline play coins only. No real money, no purchases, '
            'no prizes. Coins have no cash value.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.3,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Close',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6FC8), Color(0xFFB0127A)],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white70, width: 1.5),
          ),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
