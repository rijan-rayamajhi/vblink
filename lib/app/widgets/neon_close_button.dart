import 'package:flutter/material.dart';

/// Round pink ✕ used to close sheets and popups.
class NeonCloseButton extends StatelessWidget {
  const NeonCloseButton({super.key, required this.onTap});

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
