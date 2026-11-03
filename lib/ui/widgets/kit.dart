/// Tasarım sisteminin ortak bileşenleri (Tasarım Sistemi: 05 Bileşenler).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import 'dk_icon.dart';

/// Basılınca çöken, klavyeyle de çalışan dokunma yüzeyi.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.onTap,
    required this.builder,
    this.label,
    this.selected,
    this.toggled,
    this.focusRadius = 22,
    this.excludeChildSemantics = false,
  });

  final VoidCallback? onTap;
  final Widget Function(BuildContext context, bool pressed) builder;

  /// Ekran okuyucu etiketi (yoksa içerikteki metinler okunur).
  final String? label;
  final bool? selected;
  final bool? toggled;
  final double focusRadius;
  final bool excludeChildSemantics;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  bool _focus = false;

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    Widget child = widget.builder(context, _down && enabled);
    if (_focus) {
      child = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.focusRadius + 3),
          border: Border.all(color: K.ink, width: 3),
        ),
        child: child,
      );
    }
    return Semantics(
      button: widget.toggled == null,
      toggled: widget.toggled,
      selected: widget.selected,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: widget.excludeChildSemantics,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor:
            enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onShowFocusHighlight: (v) => setState(() => _focus = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            widget.onTap?.call();
            return null;
          }),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTapDown: enabled ? (_) => _set(true) : null,
          onTapCancel: enabled ? () => _set(false) : null,
          onTapUp: enabled ? (_) => _set(false) : null,
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  widget.onTap!();
                }
              : null,
          child: child,
        ),
      ),
    );
  }
}

enum BtnKind { primary, good, again, secondary }

/// Tıknaz düğme: 56 yükseklik, 22 yuvarlama, 5 px blok gölge.
class ChunkyButton extends StatelessWidget {
  const ChunkyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = BtnKind.primary,
    this.icon,
    this.iconColor,
    this.height = 56,
    this.semanticsLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final BtnKind kind;
  final DkIcons? icon;
  final Color? iconColor;
  final double height;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final (Color bg, Color sh, Color fg) = switch (kind) {
      BtnKind.primary => (K.primary, K.primaryShadow, K.ink),
      BtnKind.good => (K.good, K.goodShadow, K.ink),
      BtnKind.again => (K.againStrong, K.againShadow, Colors.white),
      BtnKind.secondary => (K.card, K.line, K.ink),
    };
    const depth = 5.0;
    return Pressable(
      onTap: onPressed,
      label: semanticsLabel ?? label,
      excludeChildSemantics: true,
      builder: (context, down) {
        final face = Container(
          constraints: BoxConstraints(minHeight: height),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? bg : K.locked,
            borderRadius: BorderRadius.circular(K.rLg),
            border: kind == BtnKind.secondary && enabled
                ? Border.all(color: K.line, width: 2)
                : null,
            boxShadow: enabled && !down
                ? [BoxShadow(color: sh, offset: const Offset(0, depth))]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                DkIcon(icon!,
                    size: label.isEmpty ? 26 : 24,
                    color: iconColor ?? (enabled ? fg : K.inkSoft),
                    stroke: label.isEmpty ? 3 : 2.5),
              if (icon != null && label.isNotEmpty) const SizedBox(width: 10),
              if (label.isNotEmpty)
                Flexible(
                  child: Text(
                    trUpper(label),
                    textAlign: TextAlign.center,
                    style: T.button.copyWith(color: enabled ? fg : K.inkSoft),
                  ),
                ),
            ],
          ),
        );
        return Padding(
          padding: EdgeInsets.only(
              top: down ? depth : 0, bottom: down ? 0 : depth),
          child: face,
        );
      },
    );
  }
}

/// Düz metin düğmesi (ŞİMDİ DEĞİL, ÇIK, ATLA).
class TextBtn extends StatelessWidget {
  const TextBtn(
      {super.key,
      required this.label,
      required this.onPressed,
      this.color = K.ink2,
      this.fontSize = 17,
      this.icon,
      this.upper = true});
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final double fontSize;
  final DkIcons? icon;
  final bool upper;

  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onPressed,
        focusRadius: 12,
        builder: (context, down) => Opacity(
          opacity: down ? .6 : 1,
          child: Container(
            constraints: const BoxConstraints(minHeight: 52, minWidth: 48),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[
                DkIcon(icon!, size: 16, color: color),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(upper ? trUpper(label) : label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .6,
                        color: color)),
              ),
            ]),
          ),
        ),
      );
}

/// Yuvarlak simge düğmesi: geri (48, çerçeveli) ya da kapat (64, gri).
class CircleBtn extends StatelessWidget {
  const CircleBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.size = 48,
    this.iconSize = 24,
    this.bg = K.card,
    this.fg = K.ink,
    this.border = true,
    this.stroke = 2.5,
  });

  const CircleBtn.close({
    super.key,
    required this.onPressed,
    this.label = 'Kapat',
  })  : icon = DkIcons.x,
        size = 64,
        iconSize = 26,
        bg = K.closeBg,
        fg = K.ink2,
        border = false,
        stroke = 3;

  final DkIcons icon;
  final String label;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color bg;
  final Color fg;
  final bool border;
  final double stroke;

  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onPressed,
        label: label,
        excludeChildSemantics: true,
        focusRadius: size / 2,
        builder: (context, down) => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: down ? K.closeBg : bg,
            shape: BoxShape.circle,
            border: border ? Border.all(color: K.line, width: 2) : null,
          ),
          child: DkIcon(icon, size: iconSize, color: fg, stroke: stroke),
        ),
      );
}

/// Dinle düğmesi (64, açık mavi, çalarken mavi).
class ListenButton extends StatefulWidget {
  const ListenButton(
      {super.key, required this.onListen, this.size = 64, this.iconSize = 30});
  final VoidCallback onListen;
  final double size;
  final double iconSize;

  @override
  State<ListenButton> createState() => _ListenButtonState();
}

class _ListenButtonState extends State<ListenButton> {
  bool _playing = false;
  Timer? _t;

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _tap() {
    widget.onListen();
    setState(() => _playing = true);
    _t?.cancel();
    _t = Timer(const Duration(milliseconds: 1800),
        () => mounted ? setState(() => _playing = false) : null);
  }

  @override
  Widget build(BuildContext context) => Pressable(
        key: const Key('listen'),
        onTap: _tap,
        label: 'Dinle',
        excludeChildSemantics: true,
        focusRadius: widget.size / 2,
        builder: (context, down) => Padding(
          padding: EdgeInsets.only(top: down ? 4 : 0, bottom: down ? 0 : 4),
          child: Container(
            width: widget.size,
            height: widget.size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _playing ? K.again : K.againBg,
              shape: BoxShape.circle,
              boxShadow: down
                  ? null
                  : const [
                      BoxShadow(color: K.againLine, offset: Offset(0, 4))
                    ],
            ),
            child: DkIcon(DkIcons.volume,
                size: widget.iconSize,
                color: _playing ? Colors.white : K.againInk),
          ),
        ),
      );
}

/// Dinle + yavaş dinle (kaplumbağa) ikili düğmesi.
class ListenSplit extends StatefulWidget {
  const ListenSplit({super.key, required this.onListen});
  final void Function(bool slow) onListen;

  @override
  State<ListenSplit> createState() => _ListenSplitState();
}

class _ListenSplitState extends State<ListenSplit> {
  int _playing = -1;
  Timer? _t;

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _tap(int i) {
    widget.onListen(i == 1);
    setState(() => _playing = i);
    _t?.cancel();
    _t = Timer(Duration(milliseconds: i == 1 ? 2600 : 1800),
        () => mounted ? setState(() => _playing = -1) : null);
  }

  Widget _half(int i, double w, DkIcons icon, double iconSize, String label,
          Key key) =>
      Pressable(
        key: key,
        onTap: () => _tap(i),
        label: label,
        excludeChildSemantics: true,
        focusRadius: 16,
        builder: (context, down) => Container(
          width: w,
          height: 64,
          alignment: Alignment.center,
          color: _playing == i
              ? K.again
              : down
                  ? K.againLine
                  : K.againBg,
          child: DkIcon(icon,
              size: iconSize,
              color: _playing == i ? Colors.white : K.againInk),
        ),
      );

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(color: K.againLine, offset: Offset(0, 4))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _half(0, 64, DkIcons.volume, 30, 'Dinle', const Key('listen')),
            Container(width: 2, height: 64, color: K.againLine),
            _half(1, 56, DkIcons.turtle, 26, 'Yavaş dinle',
                const Key('listen-slow')),
          ]),
        ),
      );
}

/// Oturum ilerleme çubuğu (16 yükseklik, yeşil, üstte parlaklık şeridi).
class DkProgressBar extends StatelessWidget {
  const DkProgressBar({super.key, required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final pct = (value.clamp(0, 1) * 100).round();
    return Semantics(
      label: 'İlerleme',
      value: '%$pct',
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: value.clamp(0.0, 1.0)),
        duration: Duration(milliseconds: reduceMotion(context) ? 0 : 350),
        curve: Curves.easeOut,
        builder: (context, v, _) => Container(
          height: 16,
          decoration: BoxDecoration(
              color: K.line, borderRadius: BorderRadius.circular(999)),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: v,
            child: Container(
              decoration: BoxDecoration(
                  color: K.good, borderRadius: BorderRadius.circular(999)),
              padding: const EdgeInsets.fromLTRB(8, 3, 8, 0),
              alignment: Alignment.topCenter,
              child: v > .06
                  ? Container(
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .5),
                          borderRadius: BorderRadius.circular(2)),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Beyaz kart, 2 px çizgi.
class DkCard extends StatelessWidget {
  const DkCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = K.rMd,
    this.color = K.card,
    this.borderColor = K.line,
    this.borderWidth = 2,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) => Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: child,
      );
}

/// Hap biçimli etiket.
class Pill extends StatelessWidget {
  const Pill(this.text,
      {super.key,
      this.bg = K.peach,
      this.fg = K.peachInk,
      this.fontSize = 12,
      this.icon,
      this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3)});
  final String text;
  final Color bg;
  final Color fg;
  final double fontSize;
  final DkIcons? icon;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            DkIcon(icon!, size: fontSize + 6, color: fg, stroke: 2),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(text,
                style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .6,
                    color: fg)),
          ),
        ]),
      );
}

/// Sayfa noktaları (etkin olan uzun ve turuncu).
class Dots extends StatelessWidget {
  const Dots({super.key, required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Sayfa ${index + 1} / $count',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < count; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == index ? 28 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: i == index ? K.primary : K.line,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
          ],
        ),
      );
}

/// Açma/kapama anahtarı (52×32).
class DkSwitch extends StatelessWidget {
  const DkSwitch({super.key, required this.on});
  final bool on;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 52,
        height: 32,
        decoration: BoxDecoration(
            color: on ? K.good : K.toggleOff,
            borderRadius: BorderRadius.circular(16)),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 26,
            height: 26,
            decoration:
                const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      );
}

/// Ayar satırı: başlık, açıklama, anahtar.
class ToggleRow extends StatelessWidget {
  const ToggleRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
    this.boxed = true,
    this.parent = false,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final DkIcons? icon;
  final bool boxed;
  final bool parent;

  @override
  Widget build(BuildContext context) => Pressable(
        onTap: () => onChanged(!value),
        toggled: value,
        label: title,
        focusRadius: 16,
        builder: (context, down) => Container(
          constraints: BoxConstraints(minHeight: boxed ? 72 : 64),
          padding: EdgeInsets.symmetric(
              horizontal: 16, vertical: boxed ? 12 : 10),
          decoration: boxed
              ? BoxDecoration(
                  color: K.card,
                  borderRadius: BorderRadius.circular(K.rMd),
                  border: Border.all(color: K.line, width: 2))
              : null,
          child: Row(children: [
            if (icon != null) ...[
              DkIcon(icon!, size: 28, color: K.againStrong),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: parent
                          ? T.pStrong
                          : T.strong),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: parent
                          ? T.pSmall
                          : T.help),
                ],
              ),
            ),
            const SizedBox(width: 12),
            DkSwitch(on: value),
          ]),
        ),
      );
}

/// Konuşma balonu (sol altta kuyruk).
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({super.key, required this.child, this.tailLeft = 40});
  final Widget child;
  final double tailLeft;

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: K.card,
              borderRadius: BorderRadius.circular(K.rLg),
              border: Border.all(color: K.line, width: 2),
            ),
            child: child,
          ),
          Positioned(
            left: tailLeft,
            bottom: -10,
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: K.card,
                  border: Border(
                    right: BorderSide(color: K.line, width: 2),
                    bottom: BorderSide(color: K.line, width: 2),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}

/// Kesikli çerçeve (soru görsellerindeki gruplar).
class DashedBox extends StatelessWidget {
  const DashedBox(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(12),
      this.color = K.dashed,
      this.fill = K.card,
      this.radius = K.rMd,
      this.minHeight = 0});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color fill;
  final double radius;
  final double minHeight;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _DashPainter(color, radius, fill),
        child: Container(
          constraints: BoxConstraints(minHeight: minHeight),
          padding: padding,
          child: child,
        ),
      );
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color, this.radius, this.fill);
  final Color color;
  final double radius;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
        Offset.zero & size, Radius.circular(radius));
    canvas.drawRRect(r, Paint()..color = fill);
    final p = Path()..addRRect(r.deflate(1));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final m in p.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + 6), paint);
        d += 10;
      }
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) =>
      old.color != color || old.radius != radius || old.fill != fill;
}

/// Alttan açılan sayfa (tutamak çizgili).
Future<T?> showDkSheet<T>(BuildContext context,
        {required WidgetBuilder builder}) =>
    showModalBottomSheet<T>(
      context: context,
      backgroundColor: K.card,
      barrierColor: const Color(0x732B2A33),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                      color: K.locked, borderRadius: BorderRadius.circular(3)),
                ),
              ),
              const SizedBox(height: 14),
              Flexible(child: SingleChildScrollView(child: builder(ctx))),
            ],
          ),
        ),
      ),
    );

OverlayEntry? _toast;
Timer? _toastTimer;

/// Kısa bilgi notu (mavi, üstte; 2,4 sn).
void showDkToast(BuildContext context, DkIcons icon, String text) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  _toastTimer?.cancel();
  _toast?.remove();
  final top = MediaQuery.paddingOf(context).top + 120;
  final entry = OverlayEntry(
    builder: (ctx) => Positioned(
      left: 16,
      right: 16,
      top: top,
      child: IgnorePointer(
        child: Material(
          type: MaterialType.transparency,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 250),
            builder: (context, v, child) => Opacity(opacity: v, child: child),
            child: Semantics(
              liveRegion: true,
              child: Container(
                key: const Key('toast'),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: K.againStrong,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x2E2B2A33),
                        offset: Offset(0, 8),
                        blurRadius: 24)
                  ],
                ),
                child: Row(children: [
                  DkIcon(icon, size: 24, color: Colors.white, stroke: 3),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(text,
                        style: const TextStyle(
                            fontSize: 17,
                            height: 23 / 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  _toast = entry;
  overlay.insert(entry);
  _toastTimer = Timer(const Duration(milliseconds: 2400), hideDkToast);
}

void hideDkToast() {
  _toastTimer?.cancel();
  _toast?.remove();
  _toast = null;
}

/// Veli alanı üst çubuğu: geri + başlık.
class ParentHeader extends StatelessWidget {
  const ParentHeader(
      {super.key, required this.title, this.onBack, this.trailing});
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: K.line, width: 2))),
        child: Row(children: [
          if (onBack != null) ...[
            CircleBtn(
                key: const Key('back'),
                icon: DkIcons.back,
                label: 'Geri',
                iconSize: 22,
                onPressed: onBack),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(title,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: T.pTitle),
          ),
          if (trailing != null) trailing!,
        ]),
      );
}

/// Veli alanı satırı (simge, metin, ok).
class NavRow extends StatelessWidget {
  const NavRow({
    super.key,
    required this.title,
    required this.onTap,
    this.icon,
    this.subtitle,
    this.trailing,
    this.chevron = true,
    this.last = false,
  });

  final String title;
  final String? subtitle;
  final DkIcons? icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool chevron;
  final bool last;

  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onTap,
        focusRadius: 8,
        builder: (context, down) => Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: down ? K.bgParent : null,
            border: last
                ? null
                : const Border(
                    bottom: BorderSide(color: K.lineSoft, width: 2)),
          ),
          child: Row(children: [
            if (icon != null) ...[
              DkIcon(icon!, size: 22, color: K.ink2),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: subtitle == null
                          ? T.pBody.copyWith(fontWeight: FontWeight.w700)
                          : T.pStrong),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: T.code),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            if (chevron && onTap != null) ...[
              const SizedBox(width: 8),
              const DkIcon(DkIcons.right, size: 18, color: K.inkSoft),
            ],
          ]),
        ),
      );
}

/// Kenarlıklı beyaz liste kutusu.
class ListBox extends StatelessWidget {
  const ListBox({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: K.card,
          borderRadius: BorderRadius.circular(K.rMd),
          border: Border.all(color: K.line, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );
}

/// Çocuk alanının yazı boyutu ayarını uygular.
class ChildTextScale extends StatelessWidget {
  const ChildTextScale({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final mq = MediaQuery.of(context);
    final f = app.settings.textScale;
    if (f == 1) return child;
    return MediaQuery(
      data: mq.copyWith(
          textScaler: TextScaler.linear(mq.textScaler.scale(1) * f)),
      child: child,
    );
  }
}
