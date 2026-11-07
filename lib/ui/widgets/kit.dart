/// Tasarım sisteminin ortak bileşenleri (Tasarım Sistemi: 05 Bileşenler).
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import 'dk_icon.dart';
import 'hand.dart';

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

enum BtnKind { primary, good, again, secondary, kok }

/// Veli alanı: tasarımdaki sakin ürün dili (düz lacivert düğmeler, ince
/// çizgiler). Bu alanın altındaki düğmeler çocuk ekranlarındaki ahşap tabela
/// yerine sade çizilir.
class Calm extends InheritedWidget {
  const Calm({super.key, required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Calm>() != null;

  @override
  bool updateShouldNotify(Calm oldWidget) => false;
}

/// Veli alanı iskelesi.
class CalmScaffold extends StatelessWidget {
  const CalmScaffold({super.key, this.backgroundColor, required this.body});
  final Color? backgroundColor;
  final Widget body;

  @override
  Widget build(BuildContext context) => Calm(
        child: Scaffold(backgroundColor: K.bgParent, body: body),
      );
}

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
    if (Calm.of(context)) return _calm(context, enabled);
    // Tasarım: birincil ahşap tabela, ikincil parşömen; zafer zümrüt,
    // tekrar lacivert. Devre dışı: soluk taş.
    final HandStyle style;
    final Color fg;
    if (!enabled) {
      style = HandStyle.tabela.copyWith(
          fill: K.locked,
          texture: HandFill.duz,
          border: K.lockedShade,
          shadows: const [(4, Color(0xFFCFC7B8))]);
      fg = K.inkMuted;
    } else {
      final (HandStyle, Color) r = switch (kind) {
        BtnKind.primary => (HandStyle.tabela, K.kagit3),
        BtnKind.good => (
            HandStyle.tabela.copyWith(
                fill: K.zumrutKoyu,
                texture: HandFill.duz,
                shadows: const [(5, K.goodShadow)]),
            K.kagit3
          ),
        BtnKind.again => (
            HandStyle.tabela.copyWith(
                fill: K.lacivert,
                texture: HandFill.duz,
                shadows: const [(5, K.againShadow)]),
            K.kagit3
          ),
        BtnKind.secondary => (HandStyle.parsomen, K.ink),
        BtnKind.kok => (
            HandStyle.tabela.copyWith(
                fill: K.kokKoyu,
                texture: HandFill.duz,
                shadows: const [(5, Color(0xFF6E2417))]),
            K.kagit3
          ),
      };
      style = r.$1;
      fg = r.$2;
    }
    final sign = kind != BtnKind.secondary;
    final text = sign
        ? T.button.copyWith(color: fg)
        : const TextStyle(
            fontFamily: K.font,
            fontSize: 20,
            height: 1.15,
            fontWeight: FontWeight.w700,
            color: K.ink);
    return Pressable(
      onTap: onPressed,
      label: semanticsLabel ?? label,
      excludeChildSemantics: true,
      builder: (context, down) => HandBox(
        style: style,
        pressed: down && enabled,
        constraints: BoxConstraints(minHeight: height),
        padding: EdgeInsets.symmetric(horizontal: sign ? 26 : 18, vertical: 8),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Align(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null)
                    DkIcon(icon!,
                        size: label.isEmpty ? 26 : 24,
                        color: iconColor ?? fg,
                        stroke: label.isEmpty ? 3 : 2.5),
                  if (icon != null && label.isNotEmpty)
                    const SizedBox(width: 10),
                  if (label.isNotEmpty)
                    Flexible(
                      child:
                          Text(label, textAlign: TextAlign.center, style: text),
                    ),
                ],
              ),
            ),
            if (sign && enabled) ...const [
              Positioned(
                  left: -17, top: 0, bottom: 0, child: Center(child: _Nail())),
              Positioned(
                  right: -17, top: 0, bottom: 0, child: Center(child: _Nail())),
            ],
          ],
        ),
      ),
    );
  }

  Widget _calm(BuildContext context, bool enabled) {
    final secondary = kind == BtnKind.secondary;
    final bg = !enabled
        ? K.locked
        : secondary
            ? Colors.transparent
            : kind == BtnKind.good
                ? K.zumrutKoyu
                : K.lacivert;
    final fg = !enabled
        ? K.inkMuted
        : secondary
            ? K.lacivert
            : K.kagit3;
    return Pressable(
      onTap: onPressed,
      label: semanticsLabel ?? label,
      excludeChildSemantics: true,
      builder: (context, down) => Opacity(
        opacity: down ? .85 : 1,
        child: Container(
          constraints: BoxConstraints(minHeight: math.max(52, height - 4)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
            border: secondary && enabled
                ? Border.all(color: K.lacivert, width: 1.5)
                : null,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null)
              DkIcon(icon!, size: 22, color: iconColor ?? fg, stroke: 2.4),
            if (icon != null && label.isNotEmpty) const SizedBox(width: 8),
            if (label.isNotEmpty)
              Flexible(
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: K.font,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: fg)),
              ),
          ]),
        ),
      ),
    );
  }
}

/// Tabelanın çivisi.
class _Nail extends StatelessWidget {
  const _Nail();

  @override
  Widget build(BuildContext context) => Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
            color: Color(0xB32B2320), shape: BoxShape.circle),
      );
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52, minWidth: 48),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
        builder: (context, down) => SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: HandPainter(HandStyle.muhur.copyWith(
                fill: down ? K.kagit2 : bg,
                borderWidth: border ? 2.5 : 2,
                border: border ? K.murekkep : K.murekkep2)),
            child: Center(
                child: DkIcon(icon, size: iconSize, color: fg, stroke: stroke)),
          ),
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
                  : const [BoxShadow(color: K.againLine, offset: Offset(0, 4))],
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
              size: iconSize, color: _playing == i ? Colors.white : K.againInk),
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
  const DkProgressBar({super.key, required this.value, this.color = K.ahsap});
  final double value;

  /// Dağların rengi (krallık rengi).
  final Color color;

  /// Claude Design › Sis çubuğu: dağların üstündeki sis, ilerledikçe güneş
  /// sağa yürür ve sis çekilir.
  @override
  Widget build(BuildContext context) {
    final pct = (value.clamp(0, 1) * 100).round();
    return Semantics(
      label: 'Sis çubuğu: dağılan sis',
      value: '%$pct',
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: value.clamp(0.0, 1.0)),
        duration: Duration(milliseconds: reduceMotion(context) ? 0 : 350),
        curve: Curves.easeOut,
        builder: (context, v, _) => SizedBox(
          height: 48,
          child: CustomPaint(painter: _FogBarPainter(v, color)),
        ),
      ),
    );
  }
}

class _FogBarPainter extends CustomPainter {
  _FogBarPainter(this.v, this.color);
  final double v;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final frame = Path()
      ..moveTo(10, 3)
      ..cubicTo(w * .4, 1, w * .7, 4, w - 10, 2)
      ..cubicTo(w - 1, 3, w - 1, h - 4, w - 10, h - 2)
      ..cubicTo(w * .6, h - 1, w * .3, h - 4, 10, h - 2)
      ..cubicTo(1, h - 3, 1, 4, 10, 3)
      ..close();
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..color = K.murekkep
      ..strokeJoin = StrokeJoin.round;
    canvas.save();
    canvas.clipPath(frame);
    canvas.drawRect(Offset.zero & size, Paint()..color = K.kagit3);
    // dağlar
    final dag = Path()..moveTo(0, h - 8);
    var x = 0.0;
    var i = 0;
    while (x < w) {
      final mh = const [30.0, 20.0, 25.0][i % 3];
      dag
        ..lineTo(x + 17, h - 8 - mh)
        ..lineTo(x + 34, h - 8);
      x += 34;
      i++;
    }
    dag
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(dag, Paint()..color = color);
    canvas.drawPath(dag, ink..strokeWidth = 1.6);
    canvas.drawRect(Rect.fromLTWH(0, h - 12, w, 12),
        Paint()..color = const Color(0xFF5E7A3A));
    // evler
    for (var k = 22.0; k < w - 10; k += 58) {
      final ev = Path()
        ..moveTo(k, h - 8)
        ..lineTo(k, h - 14)
        ..lineTo(k + 4, h - 18)
        ..lineTo(k + 8, h - 14)
        ..lineTo(k + 8, h - 8)
        ..close();
      canvas.drawPath(ev, Paint()..color = K.safran);
      canvas.drawPath(ev, ink..strokeWidth = 1.3);
    }
    // sis: güneşin sağı
    final fx = 10 + (w - 20) * v;
    final sis = Path()
      ..moveTo(fx, 0)
      ..cubicTo(fx - 9, 8, fx + 7, 16, fx - 4, 24)
      ..cubicTo(fx - 12, 32, fx + 5, 40, fx, h)
      ..lineTo(w + 20, h)
      ..lineTo(w + 20, 0)
      ..close();
    canvas.drawPath(sis, Paint()..color = const Color(0xF2C9D1D9));
    canvas.save();
    canvas.clipPath(sis);
    final tul = Paint()
      ..color = const Color(0x999AA6B2)
      ..strokeWidth = .8;
    for (var t = -h; t < w + h; t += 9) {
      canvas.drawLine(Offset(t, h), Offset(t + h * .53, 0), tul);
    }
    canvas.restore();
    canvas.restore();
    canvas.drawPath(frame, ink..strokeWidth = 2.6);
    // güneş
    final c = Offset(fx, h / 2);
    final ray = Paint()
      ..color = K.safran
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (final (a, b) in const [
      (Offset(0, -17), Offset(0, -22)),
      (Offset(0, 17), Offset(0, 22)),
      (Offset(-13, -10), Offset(-16, -13)),
      (Offset(13, -10), Offset(16, -13)),
      (Offset(-13, 10), Offset(-16, 13)),
      (Offset(13, 10), Offset(16, 13)),
    ]) {
      canvas.drawLine(c + a, c + b, ray);
    }
    canvas.drawCircle(c, 9, Paint()..color = K.safran);
    canvas.drawCircle(c, 9, ink..strokeWidth = 2.2);
  }

  @override
  bool shouldRepaint(_FogBarPainter old) => old.v != v || old.color != color;
}

/// Beyaz kart, 2 px çizgi.
class DkCard extends StatelessWidget {
  const DkCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = K.rMd,
    this.color = K.card,
    this.borderColor = K.murekkep,
    this.borderWidth = 2.5,
    this.margin,
    this.hand = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? margin;

  /// El çizimi kart (çocuk ekranları). Veli alanında sade çerçeve.
  final bool hand;

  @override
  Widget build(BuildContext context) {
    final Widget box = hand
        ? HandBox(
            style: HandStyle.kart.copyWith(
                fill: color, border: borderColor, borderWidth: borderWidth),
            padding: padding,
            child: child,
          )
        : Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: K.line, width: 1.5),
            ),
            child: child,
          );
    return margin == null ? box : Padding(padding: margin!, child: box);
  }
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
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
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
            color: on ? K.zumrutKoyu : K.toggleOff,
            borderRadius: BorderRadius.circular(16)),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
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
          padding:
              EdgeInsets.symmetric(horizontal: 16, vertical: boxed ? 12 : 10),
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
                  Text(title, style: parent ? T.pStrong : T.strong),
                  const SizedBox(height: 2),
                  Text(subtitle, style: parent ? T.pSmall : T.help),
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
  const SpeechBubble(
      {super.key,
      required this.child,
      this.tailLeft = 40,
      this.fill = K.kagit3});
  final Widget child;
  final double tailLeft;

  /// Anka kâğıt, önder parşömen (K.kagit2), bekçi sis tonu (0xFFE3EAF0).
  final Color fill;

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          HandBox(
            style: HandStyle.balon.copyWith(fill: fill),
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            child: child,
          ),
          Positioned(
            left: tailLeft,
            bottom: -16,
            child: CustomPaint(
                size: const Size(26, 20), painter: _TailPainter(fill)),
          ),
        ],
      );
}

class _TailPainter extends CustomPainter {
  _TailPainter(this.fill);
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(2, 0)
      ..quadraticBezierTo(8, 12, 4, size.height)
      ..quadraticBezierTo(16, 12, size.width, 0);
    canvas.drawPath(p, Paint()..color = fill);
    canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round
          ..color = K.murekkep);
    // balonun kenarıyla birleştiği yeri ört
    canvas.drawRect(
        Rect.fromLTWH(4, -3, size.width - 6, 3.6), Paint()..color = fill);
  }

  @override
  bool shouldRepaint(_TailPainter old) => old.fill != fill;
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
    final r =
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
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
Future<R?> showDkSheet<R>(BuildContext context,
        {required WidgetBuilder builder}) =>
    showModalBottomSheet<R>(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            border: Border(bottom: BorderSide(color: K.line, width: 1))),
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
                : const Border(bottom: BorderSide(color: K.lineSoft, width: 2)),
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
