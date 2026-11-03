import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/dk_icon.dart';
import '../widgets/kit.dart';

/// D1 Veli kapısı: iki basamaklı çarpma sorusu ve sayı tuş takımı.
/// Okumayı yeni söken bir çocuğun geçmesi zordur. Doğruysa true döner.
Future<bool> showParentGate(BuildContext context, {Random? random}) async {
  final r = random ?? Random();
  final a = 6 + r.nextInt(4), b = 6 + r.nextInt(4);
  final ok = await Navigator.of(context).push<bool>(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => ParentGateScreen(a: a, b: b),
  ));
  return ok ?? false;
}

class ParentGateScreen extends StatefulWidget {
  const ParentGateScreen({super.key, required this.a, required this.b});
  final int a;
  final int b;

  @override
  State<ParentGateScreen> createState() => _ParentGateScreenState();
}

class _ParentGateScreenState extends State<ParentGateScreen> {
  String _input = '';
  int _tries = 0;
  int _wait = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _key(String k) {
    if (_wait > 0) return;
    if (k == 'del') {
      if (_input.isNotEmpty) {
        setState(() => _input = _input.substring(0, _input.length - 1));
      }
      return;
    }
    if (k == 'ok') {
      if (_input.isEmpty) return;
      if (int.tryParse(_input) == widget.a * widget.b) {
        Navigator.of(context).pop(true);
        return;
      }
      final t = _tries + 1;
      if (t >= 3) {
        setState(() {
          _input = '';
          _tries = t;
          _wait = 30;
        });
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (tm) {
          if (!mounted) return tm.cancel();
          setState(() {
            _wait--;
            if (_wait <= 0) {
              _wait = 0;
              _tries = 0;
              tm.cancel();
            }
          });
        });
      } else {
        setState(() {
          _input = '';
          _tries = t;
        });
      }
      return;
    }
    if (_input.length < 3) setState(() => _input += k);
  }

  @override
  Widget build(BuildContext context) {
    final waiting = _wait > 0;
    final msg = waiting
        ? 'Biraz bekleyin: $_wait sn'
        : _tries > 0
            ? 'Bu cevap değil. ${3 - _tries} deneme hakkınız kaldı.'
            : '';
    return Scaffold(
      backgroundColor: K.bgParent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 56,
                child: Row(children: [
                  CircleBtn(
                    key: const Key('gate-cancel'),
                    icon: DkIcons.x,
                    label: 'Vazgeç',
                    iconSize: 22,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  const SizedBox(width: 12),
                  const Text('Veli alanı',
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: K.ink)),
                ]),
              ),
              const SizedBox(height: 14),
              const Text(
                  'Bu bölüm yetişkinler içindir. Devam etmek için soruyu cevaplayın.',
                  style: T.pBodySoft),
              const SizedBox(height: 14),
              Text('${widget.a} × ${widget.b} kaç?',
                  key: const Key('gate-question'), style: T.hero),
              const SizedBox(height: 14),
              Semantics(
                label: 'Cevap',
                value: _input,
                child: Container(
                  key: const Key('gate-answer'),
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: K.card,
                    borderRadius: BorderRadius.circular(K.rMd),
                    border: Border.all(
                        color: _tries > 0 && !waiting ? K.again : K.line,
                        width: 2),
                  ),
                  child: Text(_input,
                      style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: K.ink)),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 22,
                child: Semantics(
                  liveRegion: true,
                  child: Text(msg,
                      key: const Key('gate-message'),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: waiting ? K.ink2 : K.againInk)),
                ),
              ),
              const Spacer(),
              Opacity(
                opacity: waiting ? .4 : 1,
                child: Column(children: [
                  for (final row in const [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                    ['del', '0', 'ok'],
                  ]) ...[
                    Row(children: [
                      for (var i = 0; i < 3; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(child: _Key(k: row[i], onTap: _key)),
                      ],
                    ]),
                    const SizedBox(height: 10),
                  ],
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.k, required this.onTap});
  final String k;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final ok = k == 'ok';
    return Pressable(
      key: Key('gate-key-$k'),
      onTap: () => onTap(k),
      label: k == 'del'
          ? 'Sil'
          : ok
              ? 'Onayla'
              : k,
      excludeChildSemantics: true,
      focusRadius: K.rMd,
      builder: (context, down) => Padding(
        padding: EdgeInsets.only(top: down ? 3 : 0, bottom: down ? 0 : 3),
        child: Container(
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ok ? K.ink : K.card,
            borderRadius: BorderRadius.circular(K.rMd),
            boxShadow: down
                ? null
                : const [BoxShadow(color: K.keyShadow, offset: Offset(0, 3))],
          ),
          child: k == 'del'
              ? const DkIcon(DkIcons.del, size: 28, color: K.ink)
              : ok
                  ? const DkIcon(DkIcons.check,
                      size: 28, color: Colors.white, stroke: 3)
                  : Text(k,
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: K.ink)),
        ),
      ),
    );
  }
}
