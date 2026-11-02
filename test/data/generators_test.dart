import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:ders_kumbarasi/data/generators.dart';
import 'package:ders_kumbarasi/data/models.dart';

/// Sayısal soruların doğru cevabını ekrandaki metinden bağımsız olarak
/// yeniden hesaplar.
int? evalPrompt(String prompt) {
  final m = RegExp(r'^(\d+) ([+−×÷]) (\d+) = \?$').firstMatch(prompt);
  if (m == null) return null;
  final a = int.parse(m.group(1)!), b = int.parse(m.group(3)!);
  return switch (m.group(2)) {
    '+' => a + b,
    '−' => a - b,
    '×' => a * b,
    '÷' => a ~/ b,
    _ => null,
  };
}

void main() {
  final paramsByGen = <String, List<Map<String, Object?>>>{
    'count_objects': [
      {'max': 5},
      {'max': 20},
    ],
    'compare': [
      {'max': 20},
      {'max': 1000},
    ],
    'add': [
      {'max_sum': 10},
      {'max_sum': 20, 'carry': false},
      {'max_sum': 100},
    ],
    'sub': [
      {'max': 10},
      {'max': 100, 'borrow': false},
    ],
    'missing_addend': [
      {'max_sum': 10},
    ],
    'multiply': [
      {'a_max': 10, 'b_max': 10},
    ],
    'divide': [
      {'q_max': 10, 'd_max': 10},
    ],
    'place_value': [
      {'digits': 2},
      {'digits': 6},
    ],
    'tens_ones': [
      {'max': 99},
    ],
    'skip_count': [
      {},
      {
        'steps': [3, 4],
      },
    ],
    'ordinal': [
      {'max': 6},
    ],
    'compare_groups': [
      {'max': 10},
    ],
    'word_add_sub': [
      {'max': 10},
      {'max': 20},
    ],
    'equal_sides': [
      {'max_sum': 10},
      {'max_sum': 20},
    ],
    'fact_family': [
      {'max_sum': 10},
    ],
    'count_back': [
      {'from': 20},
    ],
    'estimate': [
      {},
    ],
  };

  test('tüm üreteçler testte', () {
    expect(paramsByGen.keys.toSet(), generators.keys.toSet());
  });

  for (final entry in paramsByGen.entries) {
    for (final params in entry.value) {
      test('${entry.key} $params: 500 üretim tutarlı', () {
        final card = CardDef(
          id: 't',
          outcomeCode: 'X',
          generator: entry.key,
          generatorParams: params,
        );
        for (var seed = 0; seed < 500; seed++) {
          final q = generate(card, Random(seed));
          expect(q.options.length, greaterThanOrEqualTo(2), reason: q.prompt);
          expect(q.options.toSet().length, q.options.length,
              reason: 'tekrarlı seçenek: ${q.options} (${q.prompt})');
          expect(q.answerIndex, inInclusiveRange(0, q.options.length - 1));
          final expected = evalPrompt(q.prompt);
          if (expected != null) {
            expect(q.answer, '$expected', reason: q.prompt);
          }
          for (final o in q.options) {
            final n = int.tryParse(o);
            if (n != null) expect(n, greaterThanOrEqualTo(0), reason: q.prompt);
          }
        }
      });
    }
  }

  test('toplama: elde yok parametresi eldeli soru üretmez', () {
    const card = CardDef(
      id: 't',
      outcomeCode: 'X',
      generator: 'add',
      generatorParams: {'max_sum': 20, 'carry': false},
    );
    for (var seed = 0; seed < 300; seed++) {
      final q = generate(card, Random(seed));
      final m = RegExp(r'^(\d+) \+ (\d+)').firstMatch(q.prompt)!;
      final a = int.parse(m.group(1)!), b = int.parse(m.group(2)!);
      expect((a % 10) + (b % 10), lessThan(10), reason: q.prompt);
      expect(a + b, lessThanOrEqualTo(20));
    }
  });

  test('basamak: cevap gerçekten o basamağın adı', () {
    const card = CardDef(
      id: 't',
      outcomeCode: 'X',
      generator: 'place_value',
      generatorParams: {'digits': 4},
    );
    const names = ['birler', 'onlar', 'yüzler', 'binler'];
    for (var seed = 0; seed < 200; seed++) {
      final q = generate(card, Random(seed));
      final pos = q.visual!.params['pos']! as int;
      final number = '${q.visual!.params['number']}';
      expect(number.length, 4);
      expect(q.answer, names[pos]);
      expect(q.prompt, contains('${number[number.length - 1 - pos]} rakamı'));
    }
  });

  test('kelime problemi: doğru işlem seçeneği gerçekten doğru', () {
    const card = CardDef(
      id: 't',
      outcomeCode: 'X',
      generator: 'word_add_sub',
      generatorParams: {'max': 10},
    );
    for (var seed = 0; seed < 300; seed++) {
      final q = generate(card, Random(seed));
      final isAdd = q.prompt.contains('daha alıyor');
      expect(q.answer.contains(isAdd ? '+' : '−'), isTrue, reason: q.prompt);
      final m = RegExp(r'^(\d+) [+−] (\d+) = (\d+)$').firstMatch(q.answer)!;
      final a = int.parse(m.group(1)!),
          b = int.parse(m.group(2)!),
          c = int.parse(m.group(3)!);
      expect(c, isAdd ? a + b : a - b);
      expect(c, inInclusiveRange(0, 10));
    }
  });

  test('eşit işareti: iki taraf gerçekten eşit', () {
    const card = CardDef(
      id: 't',
      outcomeCode: 'X',
      generator: 'equal_sides',
      generatorParams: {'max_sum': 10},
    );
    for (var seed = 0; seed < 300; seed++) {
      final q = generate(card, Random(seed));
      final m = RegExp(r'^(\d+) \+ (\d+) = ☐ \+ (\d+)$').firstMatch(q.prompt)!;
      final a = int.parse(m.group(1)!),
          b = int.parse(m.group(2)!),
          c = int.parse(m.group(3)!);
      expect(int.parse(q.answer) + c, a + b, reason: q.prompt);
    }
  });

  test('aynı tohum aynı soruyu üretir (tekrarlanabilirlik)', () {
    const card = CardDef(
        id: 't', outcomeCode: 'X', generator: 'add', generatorParams: {});
    expect(
        generate(card, Random(42)).prompt, generate(card, Random(42)).prompt);
  });

  test('bilinmeyen üreteç açık hata verir', () {
    const card = CardDef(id: 't', outcomeCode: 'X', generator: 'yok');
    expect(() => generate(card, Random(1)), throwsStateError);
  });
}
