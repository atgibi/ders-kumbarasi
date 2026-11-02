import 'dart:math';

import 'package:flutter/material.dart';

/// Veli kapısı: yazıyla verilen çarpma işlemini rakamla yanıtlamak.
/// Okumayı yeni söken bir çocuğun geçmesi zordur. Doğruysa true döner.
Future<bool> showParentGate(BuildContext context, {Random? random}) async {
  final r = random ?? Random();
  final a = 3 + r.nextInt(7), b = 3 + r.nextInt(7);
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => _GateDialog(a: a, b: b),
  );
  return ok ?? false;
}

class _GateDialog extends StatefulWidget {
  const _GateDialog({required this.a, required this.b});
  final int a;
  final int b;

  @override
  State<_GateDialog> createState() => _GateDialogState();
}

class _GateDialogState extends State<_GateDialog> {
  static const _words = [
    '',
    '',
    'iki',
    'üç',
    'dört',
    'beş',
    'altı',
    'yedi',
    'sekiz',
    'dokuz'
  ];
  final _controller = TextEditingController();
  bool _wrong = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.trim() == '${widget.a * widget.b}') {
      Navigator.pop(context, true);
    } else {
      setState(() => _wrong = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Veli kontrolü'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Devam etmek için yazın: ${_words[widget.a]} kere ${_words[widget.b]} kaç eder?'),
          const SizedBox(height: 12),
          TextField(
            key: const Key('gate-answer'),
            controller: _controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              errorText: _wrong ? 'Cevap doğru değil.' : null,
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç')),
        FilledButton(
            key: const Key('gate-ok'),
            onPressed: _submit,
            child: const Text('Tamam')),
      ],
    );
  }
}
