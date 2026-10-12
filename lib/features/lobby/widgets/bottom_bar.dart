import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../economy/task_reward.dart';

/// Bottom strip with the six reward buttons. Icons pop above the bar's edge.
class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned.fill(child: _BarBackground()),
            Positioned.fill(
              top: -h * 0.32,
              child: Row(
                children: [
                  const _TaskRewardButton(),
                  _ComingSoonButton(
                    icon: 'assets/images/btn_wheel.png',
                    label: 'LUCKY WHEEL',
                    status: '0%',
                  ),
                  _ComingSoonButton(
                    icon: 'assets/images/btn_bonus.png',
                    label: 'BONUS',
                    status: '0.00',
                  ),
                  _ComingSoonButton(
                    icon: 'assets/images/btn_bank.png',
                    label: 'GOLDEN BANK',
                  ),
                  _ComingSoonButton(
                    icon: 'assets/images/btn_levelup.png',
                    label: 'NEWBIE LEVEL UP',
                    status: '0%',
                  ),
                  _ComingSoonButton(
                    icon: 'assets/images/btn_safe.png',
                    label: 'SAFE',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BarBackground extends StatelessWidget {
  const _BarBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF9A2BB8), // magenta sheen along the top
            Color(0xFF5A1580),
            Color(0xFF2A0A55),
          ],
          stops: [0.0, 0.3, 1.0],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppColors.hotPink, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.hotPink.withValues(alpha: 0.55),
            blurRadius: 18,
          ),
        ],
      ),
    );
  }
}

class _TaskRewardButton extends ConsumerWidget {
  const _TaskRewardButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final left = ref.watch(taskRewardProvider);
    final ready = left == Duration.zero;
    String two(int n) => n.toString().padLeft(2, '0');
    final status = ready
        ? 'COLLECT'
        : '${two(left.inHours)}:${two(left.inMinutes % 60)}:${two(left.inSeconds % 60)}';

    return _RewardButton(
      icon: 'assets/images/btn_task.png',
      label: 'TASK REWARD',
      status: status,
      highlight: ready,
      onTap: () {
        final paid = ref.read(taskRewardProvider.notifier).collect();
        _toast(
          context,
          paid ? '+500 coins collected!' : 'Task Reward is not ready yet.',
        );
      },
    );
  }
}

class _ComingSoonButton extends StatelessWidget {
  const _ComingSoonButton({
    required this.icon,
    required this.label,
    this.status,
  });

  final String icon;
  final String label;
  final String? status;

  @override
  Widget build(BuildContext context) {
    return _RewardButton(
      icon: icon,
      label: label,
      status: status,
      onTap: () => _toast(context, '${_titleCase(label)} is coming soon!'),
    );
  }
}

/// Icon with an optional status pill over its base, and a caption below.
class _RewardButton extends StatefulWidget {
  const _RewardButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.status,
    this.highlight = false,
  });

  final String icon;
  final String label;
  final String? status;
  final bool highlight;
  final VoidCallback onTap;

  @override
  State<_RewardButton> createState() => _RewardButtonState();
}

class _RewardButtonState extends State<_RewardButton> {
  bool _pressed = false;

  void _setPressed(bool v) => setState(() => _pressed = v);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          final icon = h * 0.62;
          final pillH = h * 0.14;
          return GestureDetector(
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            onTap: widget.onTap,
            behavior: HitTestBehavior.opaque,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedScale(
                scale: _pressed ? 0.9 : 1,
                duration: const Duration(milliseconds: 90),
                child: SizedBox(
                  width: icon * 1.25,
                  child: Column(
                    children: [
                      SizedBox(
                        height: icon + pillH * 0.5,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            Image.asset(widget.icon, width: icon, height: icon),
                            if (widget.status != null)
                              Positioned(
                                bottom: 0,
                                height: pillH,
                                child: _StatusPill(
                                  text: widget.status!,
                                  height: pillH,
                                  highlight: widget.highlight,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: h * 0.04),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.label,
                          style: AppText.label(h * 0.1).copyWith(
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFFE9D8FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.text,
    required this.height,
    required this.highlight,
  });

  final String text;
  final double height;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: height * 0.5),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFF15A84A) : AppColors.deepPurple,
        borderRadius: BorderRadius.circular(height),
        border: Border.all(
          color: highlight ? Colors.white : AppColors.violet,
          width: 1.2,
        ),
      ),
      child: Text(
        text,
        style: AppText.number(height * 0.68)
            .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
      ),
    );
  }
}

String _titleCase(String s) => s
    .toLowerCase()
    .split(' ')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
}
