/// Çoktan seçmeli dışındaki soru türleri (Claude Design 16a–16g): tuş
/// takımı, sıralama, eşleştirme, saat kurma, hece kartları.
///
/// Her tür, çocuğun cevabı hazır olduğunda [onChanged] ile "doğru mu?"
/// bilgisini bildirir (hazır değilse null). Kontrol düğmesi soru ekranında.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../theme.dart';
import '../widgets/hand.dart';
import '../widgets/kit.dart';

typedef ReadyChanged = void Function(bool? correct);

class KindView extends StatelessWidget {
  const KindView(
      {super.key,
      required this.question,
      required this.onChanged,
      required this.locked});
  final Question question;
  final ReadyChanged onChanged;

  /// Cevap kontrol edildi: artık değiştirilemez.
  final bool locked;

  @override
  Widget build(BuildContext context) => switch (question.kind) {
        QKind.keypad =>
          _Keypad(q: question, onChanged: onChanged, locked: locked),
        QKind.order => _Build(
            q: question, onChanged: onChanged, locked: locked, syllables: false),
        QKind.syllables => _Build(
            q: question, onChanged: onChanged, locked: locked, syllables: true),
        QKind.match => _Match(q: question, onChanged: onChanged, locked: locked),
        QKind.clock =>
          _ClockSet(q: question, onChanged: onChanged, locked: locked),
        QKind.choice => const SizedBox.shrink(),
      };
}

/// Küçük taş levha (seçilebilir öğe).
class _Tile extends StatelessWidget {
  const _Tile(
      {super.key,
      required this.label,
      required this.onTap,
      this.state = 0,
      this.big = false});
  final String label;
  final VoidCallback? onTap;

  /// 0 normal, 1 seçili, 2 doğru, 3 yanlış/sönük
  final int state;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final style = switch (state) {
      1 => HandStyle.levha.copyWith(border: K.lacivert, borderWidth: 4.5),
      2 => HandStyle.levha.copyWith(
          fill: K.goodBg,
          texture: HandFill.duz,
          border: K.zumrutKoyu,
          shadows: const [(4, Color(0xFF9FBFA8)), (7, K.zumrutKoyu)]),
      3 => HandStyle.levha.copyWith(
          fill: K.sis2,
          texture: HandFill.sisli,
          border: K.murekkep2,
          shadows: const [(4, K.sis), (7, K.murekkep2)]),
      _ => HandStyle.levha,
    };
    return Pressable(
      onTap: onTap,
      label: label,
      excludeChildSemantics: true,
      selected: state == 1,
      builder: (context, down) => HandBox(
        style: style,
        pressed: down,
        constraints: BoxConstraints(minHeight: big ? 72 : 60, minWidth: 64),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(label,
              style: TextStyle(
                  fontFamily: K.display,
                  fontSize: big ? 30 : 24,
                  fontWeight: FontWeight.w700,
                  color: state == 3 ? K.murekkep2 : K.murekkep)),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ 16a tuş takımı

class _Keypad extends StatefulWidget {
  const _Keypad({required this.q, required this.onChanged, required this.locked});
  final Question q;
  final ReadyChanged onChanged;
  final bool locked;

  @override
  State<_Keypad> createState() => _KeypadState();
}

class _KeypadState extends State<_Keypad> {
  String _typed = '';

  void _key(String k) {
    if (widget.locked) return;
    setState(() {
      if (k == 'del') {
        if (_typed.isNotEmpty) _typed = _typed.substring(0, _typed.length - 1);
      } else if (_typed.length < 5) {
        _typed = _typed == '0' ? k : _typed + k;
      }
    });
    widget.onChanged(_typed.isEmpty ? null : _typed == widget.q.answerText);
  }

  @override
  Widget build(BuildContext context) {
    Widget key(String k) => Expanded(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Pressable(
              key: Key('key-$k'),
              label: k == 'del' ? 'Sil' : k,
              excludeChildSemantics: true,
              onTap: widget.locked ? null : () => _key(k),
              builder: (context, down) => HandBox(
                style: HandStyle.tas,
                pressed: down,
                constraints: const BoxConstraints(minHeight: 58),
                child: Center(
                  child: k == 'del'
                      ? const Icon(Icons.backspace_outlined,
                          color: K.murekkep, size: 26)
                      : Text(k,
                          style: const TextStyle(
                              fontFamily: K.display,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: K.murekkep)),
                ),
              ),
            ),
          ),
        );
    return Column(
      key: const Key('keypad'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          label: _typed.isEmpty ? 'Cevap kutusu boş' : 'Yazdığın: $_typed',
          child: ExcludeSemantics(
            child: HandBox(
              style: HandStyle.kart,
              constraints: const BoxConstraints(minHeight: 76),
              child: Center(
                child: Text(_typed.isEmpty ? '?' : _typed,
                    style: TextStyle(
                        fontFamily: K.display,
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: _typed.isEmpty ? K.sis : K.murekkep)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['del', '0'],
        ])
          Row(children: [
            for (final k in row) key(k),
            if (row.length == 2) const Expanded(child: SizedBox()),
          ]),
      ],
    );
  }
}

// ------------------------------------------- 16c sıralama / 16f hece kartları

class _Build extends StatefulWidget {
  const _Build(
      {required this.q,
      required this.onChanged,
      required this.locked,
      required this.syllables});
  final Question q;
  final ReadyChanged onChanged;
  final bool locked;
  final bool syllables;

  @override
  State<_Build> createState() => _BuildState();
}

class _BuildState extends State<_Build> {
  late final List<String> _pool;
  final List<int> _placed = [];

  int get _need => widget.q.options.length;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random(widget.q.prompt.hashCode);
    _pool = [...widget.q.options, ...?(widget.syllables ? widget.q.pairs : null)];
    // doğru sırada başlamasın
    var guard = 0;
    do {
      _pool.shuffle(rnd);
    } while (guard++ < 10 &&
        _pool.take(_need).join('|') == widget.q.options.join('|'));
  }

  void _report() {
    if (_placed.length < _need) {
      widget.onChanged(null);
      return;
    }
    final built = [for (final i in _placed) _pool[i]];
    widget.onChanged(built.join('|') == widget.q.options.join('|'));
  }

  @override
  Widget build(BuildContext context) {
    final full = _placed.length >= _need;
    final remaining = [
      for (var i = 0; i < _pool.length; i++)
        if (!_placed.contains(i)) i
    ];
    return Column(
      key: const Key('build-area'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // yuvalar
        HandBox(
          style: HandStyle.kart.copyWith(fill: K.kagit2),
          padding: const EdgeInsets.all(10),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: widget.syllables ? 4 : 10,
            runSpacing: 10,
            children: [
              for (var s = 0; s < _need; s++)
                s < _placed.length
                    ? _Tile(
                        key: Key('slot-$s'),
                        label: _pool[_placed[s]],
                        big: true,
                        onTap: widget.locked
                            ? null
                            : () {
                                setState(() => _placed.removeAt(s));
                                _report();
                              },
                      )
                    : Container(
                        width: 64,
                        height: 72,
                        decoration: BoxDecoration(
                          border: Border.all(color: K.murekkep2, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
            ],
          ),
        ),
        if (!widget.syllables && !widget.locked)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text('Yanlış yere koyduğuna dokunursan geri gelir.',
                style: TextStyle(
                    fontFamily: K.hand, fontSize: 15, color: K.murekkep2)),
          ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 14,
          children: [
            for (var r = 0; r < remaining.length; r++)
              _Tile(
                // dolunca anahtar yok: kalanlar seçilemez
                key: full ? null : Key('option-$r'),
                label: _pool[remaining[r]],
                big: true,
                state: full ? 3 : 0,
                onTap: widget.locked || full
                    ? null
                    : () {
                        setState(() => _placed.add(remaining[r]));
                        _report();
                      },
              ),
          ],
        ),
      ],
    );
  }
}

// -------------------------------------------------------- 16b eşleştirme

class _Match extends StatefulWidget {
  const _Match({required this.q, required this.onChanged, required this.locked});
  final Question q;
  final ReadyChanged onChanged;
  final bool locked;

  @override
  State<_Match> createState() => _MatchState();
}

class _MatchState extends State<_Match> {
  late final List<int> _rightOrder;
  final Set<int> _done = {};
  int? _left;
  int? _wrong;
  int _mistakes = 0;

  @override
  void initState() {
    super.initState();
    _rightOrder = List.generate(widget.q.options.length, (i) => i)
      ..shuffle(math.Random(widget.q.prompt.hashCode + 7));
  }

  void _pickRight(int j) {
    final l = _left;
    if (l == null || widget.locked) return;
    setState(() {
      if (l == j) {
        _done.add(j);
        _left = null;
        _wrong = null;
      } else {
        _mistakes++;
        _wrong = j;
      }
    });
    if (_done.length == widget.q.options.length) {
      widget.onChanged(_mistakes == 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.q;
    return Row(
      key: const Key('match-area'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(children: [
            for (var i = 0; i < q.options.length; i++) ...[
              _Tile(
                key: Key('left-$i'),
                label: q.options[i],
                state: _done.contains(i) ? 2 : (_left == i ? 1 : 0),
                onTap: _done.contains(i) || widget.locked
                    ? null
                    : () => setState(() {
                          _left = i;
                          _wrong = null;
                        }),
              ),
              const SizedBox(height: 12),
            ],
          ]),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(children: [
            for (final j in _rightOrder) ...[
              _Tile(
                key: Key('right-$j'),
                label: q.pairs![j],
                state: _done.contains(j) ? 2 : (_wrong == j ? 3 : 0),
                onTap: _done.contains(j) || widget.locked
                    ? null
                    : () => _pickRight(j),
              ),
              const SizedBox(height: 12),
            ],
          ]),
        ),
      ],
    );
  }
}

// --------------------------------------------------------- 16g saat kurma

class _ClockSet extends StatefulWidget {
  const _ClockSet(
      {required this.q, required this.onChanged, required this.locked});
  final Question q;
  final ReadyChanged onChanged;
  final bool locked;

  @override
  State<_ClockSet> createState() => _ClockSetState();
}

class _ClockSetState extends State<_ClockSet> {
  int _h = 12, _m = 0;

  int get _th => int.parse(widget.q.pairs![0]);
  int get _tm => int.parse(widget.q.pairs![1]);
  int get _step => int.parse(widget.q.pairs![2]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _report());
  }

  void _report() => widget.onChanged(_h == _th && _m == _tm);

  void _change(int dh, int dm) {
    if (widget.locked) return;
    setState(() {
      _m += dm;
      if (_m >= 60) {
        _m -= 60;
      } else if (_m < 0) {
        _m += 60;
      }
      _h = ((_h - 1 + dh) % 12 + 12) % 12 + 1;
    });
    _report();
  }

  @override
  Widget build(BuildContext context) {
    Widget btn(String key, String label, IconData icon, VoidCallback f) =>
        Pressable(
          key: Key(key),
          label: label,
          excludeChildSemantics: true,
          onTap: widget.locked ? null : f,
          builder: (context, down) => SizedBox(
            width: 56,
            height: 56,
            child: CustomPaint(
              painter: HandPainter(
                  HandStyle.muhur.copyWith(fill: down ? K.kagit2 : K.kagit3)),
              child: Icon(icon, color: K.murekkep, size: 28),
            ),
          ),
        );
    Widget row(String what, String minus, String plus, VoidCallback m,
            VoidCallback p) =>
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          btn(minus, '$what geri', Icons.remove, m),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(what,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: K.display,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          btn(plus, '$what ileri', Icons.add, p),
        ]);
    return Column(
      key: const Key('clock-face'),
      children: [
        Semantics(
          label: 'Saat $_h, dakika $_m',
          liveRegion: true,
          child: SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(painter: _ClockPainter(_h, _m)),
          ),
        ),
        const SizedBox(height: 14),
        row('Kısa kol (saat)', 'clock-h-minus', 'clock-h-plus',
            () => _change(-1, 0), () => _change(1, 0)),
        const SizedBox(height: 10),
        row('Uzun kol (dakika)', 'clock-m-minus', 'clock-m-plus',
            () => _change(0, -_step), () => _change(0, _step)),
      ],
    );
  }
}

class _ClockPainter extends CustomPainter {
  _ClockPainter(this.h, this.m);
  final int h, m;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 4;
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = K.murekkep;
    canvas.drawCircle(c, r, Paint()..color = K.kagit3);
    canvas.drawCircle(c, r, ink);
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 1; i <= 12; i++) {
      final a = i / 12 * 2 * math.pi - math.pi / 2;
      tp.text = TextSpan(
          text: '$i',
          style: const TextStyle(
              fontFamily: K.display,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: K.murekkep));
      tp.layout();
      tp.paint(
          canvas,
          c +
              Offset(math.cos(a), math.sin(a)) * (r - 18) -
              Offset(tp.width / 2, tp.height / 2));
    }
    final ma = m / 60 * 2 * math.pi - math.pi / 2;
    final ha = ((h % 12) + m / 60) / 12 * 2 * math.pi - math.pi / 2;
    canvas.drawLine(
        c,
        c + Offset(math.cos(ma), math.sin(ma)) * (r - 26),
        Paint()
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..color = K.lacivert);
    canvas.drawLine(
        c,
        c + Offset(math.cos(ha), math.sin(ha)) * (r - 52),
        Paint()
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..color = K.kokKoyu);
    canvas.drawCircle(c, 7, Paint()..color = K.safran);
    canvas.drawCircle(c, 7, ink..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_ClockPainter old) => old.h != h || old.m != m;
}
