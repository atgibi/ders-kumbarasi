import 'package:flutter/material.dart';

import '../theme.dart';

/// Altında gölge bandı olan, basılınca çöken kalın düğme.
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = Kumbara.primary,
    this.shadow = Kumbara.primaryDark,
    this.textColor = Colors.white,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color shadow;
  final Color textColor;
  final double height;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final c = enabled ? widget.color : Kumbara.locked;
    final sh = enabled ? widget.shadow : const Color(0xFFBDB7AE);
    const depth = 5.0;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTap: widget.onPressed,
        child: SizedBox(
          height: widget.height + depth,
          child: Stack(
            children: [
              Positioned.fill(
                top: depth,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: sh, borderRadius: BorderRadius.circular(16)),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 60),
                left: 0,
                right: 0,
                top: _down ? depth : 0,
                height: widget.height,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    trUpper(widget.label),
                    style: TextStyle(
                      color: enabled ? widget.textColor : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
