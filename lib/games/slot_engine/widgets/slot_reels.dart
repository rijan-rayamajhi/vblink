import 'package:flutter/material.dart';

import '../slot_config.dart';
import '../slot_math.dart';
import 'symbol_tile.dart';

/// Five scrolling reels. When [spinId] changes the reels spin and stop
/// left to right on [result], then [onStopped] fires once.
class SlotReels extends StatefulWidget {
  const SlotReels({
    super.key,
    required this.config,
    required this.result,
    required this.spinId,
    required this.onStopped,
    this.onReelStop,
  });

  final SlotConfig config;
  final SpinResult? result;
  final int spinId;
  final VoidCallback onStopped;
  final VoidCallback? onReelStop;

  @override
  State<SlotReels> createState() => _SlotReelsState();
}

class _SlotReelsState extends State<SlotReels> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers = [
    for (var r = 0; r < widget.config.reels; r++)
      AnimationController(vsync: this),
  ];

  /// Top-row strip position per reel; fractional while spinning.
  late final List<double> _from = [
    for (final s in widget.result?.stops ?? List.filled(widget.config.reels, 0))
      s.toDouble(),
  ];
  late final List<double> _to = List.of(_from);
  bool _showWins = false;

  @override
  void didUpdateWidget(SlotReels old) {
    super.didUpdateWidget(old);
    if (widget.spinId != old.spinId && widget.result != null) _start();
  }

  Future<void> _start() async {
    setState(() => _showWins = false);
    final stops = widget.result!.stops;
    final futures = <Future<void>>[];
    for (var r = 0; r < widget.config.reels; r++) {
      final len = widget.config.strips[r].length;
      _from[r] = _position(r) % len;
      // Spin downward: several full loops, then land on the stop.
      var target = stops[r].toDouble() - len * (2 + r);
      while (target > _from[r] - len * (2 + r)) {
        target -= len;
      }
      _to[r] = target;
      final c = _controllers[r]
        ..duration = Duration(milliseconds: 700 + 220 * r)
        ..value = 0;
      futures.add(
        c.animateTo(1, curve: Curves.easeOutBack).then((_) {
          widget.onReelStop?.call();
        }),
      );
    }
    await Future.wait(futures);
    if (!mounted) return;
    for (var r = 0; r < widget.config.reels; r++) {
      _from[r] = _to[r] = stops[r].toDouble();
      _controllers[r].value = 0;
    }
    setState(() => _showWins = true);
    widget.onStopped();
  }

  double _position(int r) =>
      _from[r] + (_to[r] - _from[r]) * _controllers[r].value;

  Set<(int, int)> _winningCells() {
    final result = widget.result;
    if (result == null || !_showWins) return const {};
    final cells = <(int, int)>{};
    for (final w in result.lineWins) {
      final line = widget.config.lines[w.line];
      for (var r = 0; r < w.count; r++) {
        cells.add((r, line[r]));
      }
    }
    if (result.scatterCount >= 3) {
      for (var r = 0; r < result.grid.length; r++) {
        for (var row = 0; row < SlotConfig.rows; row++) {
          if (widget.config.symbol(result.grid[r][row]).isScatter) {
            cells.add((r, row));
          }
        }
      }
    }
    return cells;
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wins = _winningCells();
    return Row(
      children: [
        for (var r = 0; r < widget.config.reels; r++)
          Expanded(
            child: AnimatedBuilder(
              animation: _controllers[r],
              builder: (context, _) => _Reel(
                strip: widget.config.strips[r],
                config: widget.config,
                position: _position(r),
                highlightRows: {
                  for (final (reel, row) in wins)
                    if (reel == r) row,
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _Reel extends StatelessWidget {
  const _Reel({
    required this.strip,
    required this.config,
    required this.position,
    required this.highlightRows,
  });

  final List<String> strip;
  final SlotConfig config;
  final double position;
  final Set<int> highlightRows;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellH = constraints.maxHeight / SlotConfig.rows;
          final len = strip.length;
          final first = position.floor();
          final settled = position == position.roundToDouble();
          return Stack(
            children: [
              for (var i = first - 1; i <= first + SlotConfig.rows; i++)
                Positioned(
                  left: 0,
                  right: 0,
                  top: (i - position) * cellH,
                  height: cellH,
                  child: SymbolTile(
                    symbol: config.symbol(strip[i % len]),
                    highlight: settled && highlightRows.contains(i - first),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
