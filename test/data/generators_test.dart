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
    'number_words': [
      {'max': 100},
      {'min': 100, 'max': 999},
      {'min': 1000, 'max': 999999},
    ],
    'order3': [
      {'max': 100},
      {'max': 9999},
    ],
    'clock_read': [
      {},
      {
        'minutes': [0, 15, 30, 45],
      },
    ],
    'multiply_as_add': [
      {'a_max': 5, 'b_max': 5},
    ],
    'odd_even': [
      {'max': 1000},
    ],
    'odd_even_sum': [
      {'max': 50},
    ],
    'round_to': [
      {'to': 10, 'max': 999},
      {'to': 100, 'max': 999},
    ],
    'unit_convert': [
      {},
      {
        'kinds': ['l_ml'],
      },
    ],
    'fraction_read': [
      {},
      {'unit': true},
    ],
    'perimeter': [
      {'max': 10},
    ],
    'word_mul_div': [
      {'max': 10},
    ],
    'fraction_compare': [
      {},
      {'unit': true},
    ],
    'fraction_of_set': [
      {},
      {'unit': true},
    ],
    'fraction_add_same': [
      {},
    ],
    'angle_type': [
      {},
    ],
    'area_count': [
      {'max': 6},
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

  test('sayı okunuşları', () {
    expect(sayiOkunusu(0), 'sıfır');
    expect(sayiOkunusu(7), 'yedi');
    expect(sayiOkunusu(10), 'on');
    expect(sayiOkunusu(47), 'kırk yedi');
    expect(sayiOkunusu(100), 'yüz');
    expect(sayiOkunusu(105), 'yüz beş');
    expect(sayiOkunusu(260), 'iki yüz altmış');
    expect(sayiOkunusu(1000), 'bin');
    expect(sayiOkunusu(1999), 'bin dokuz yüz doksan dokuz');
    expect(sayiOkunusu(23045), 'yirmi üç bin kırk beş');
    expect(sayiOkunusu(100000), 'yüz bin');
    expect(sayiOkunusu(999999),
        'dokuz yüz doksan dokuz bin dokuz yüz doksan dokuz');
  });

  test('saat söyleyişi', () {
    expect(saatSoyle(3, 0), 'Saat 3');
    expect(saatSoyle(3, 30), 'Saat 3 buçuk');
    expect(saatSoyle(6, 15), "Saat 6'yı çeyrek geçiyor");
    expect(saatSoyle(5, 45), "Saat 6'ya çeyrek var");
    expect(saatSoyle(12, 45), "Saat 1'e çeyrek var");
  });

  test('yuvarlama: cevap gerçekten en yakın onluk/yüzlük', () {
    for (final to in [10, 100]) {
      final card = CardDef(
          id: 't',
          outcomeCode: 'X',
          generator: 'round_to',
          generatorParams: {'to': to, 'max': 999});
      for (var seed = 0; seed < 300; seed++) {
        final q = generate(card, Random(seed));
        final n = int.parse(RegExp(r'^(\d+)').firstMatch(q.prompt)!.group(1)!);
        final ans = int.parse(q.answer);
        expect(ans % to, 0, reason: q.prompt);
        expect((n - ans).abs() <= to ~/ 2, isTrue,
            reason: '${q.prompt} -> ${q.answer}');
      }
    }
  });

  test('kesir toplama: cevap doğru', () {
    const card =
        CardDef(id: 't', outcomeCode: 'X', generator: 'fraction_add_same');
    for (var seed = 0; seed < 300; seed++) {
      final q = generate(card, Random(seed));
      final m = RegExp(r'^(\d+)/(\d+) ([+−]) (\d+)/(\d+) = \?$')
          .firstMatch(q.prompt)!;
      final a = int.parse(m.group(1)!),
          d = int.parse(m.group(2)!),
          b = int.parse(m.group(4)!);
      final c = m.group(3) == '+' ? a + b : a - b;
      expect(q.answer, '$c/$d', reason: q.prompt);
      expect(c, inInclusiveRange(0, d));
    }
  });

  test('sabit soruların seçenekleri karışır, doğru cevap korunur', () {
    const card = CardDef(
      id: 't',
      outcomeCode: 'X',
      fixed: Question(prompt: 'Soru', options: ['A', 'B', 'C'], answerIndex: 0),
    );
    final positions = <int>{};
    for (var seed = 0; seed < 50; seed++) {
      final q = generate(card, Random(seed));
      expect(q.answer, 'A');
      expect(q.options.toSet(), {'A', 'B', 'C'});
      positions.add(q.answerIndex);
    }
    expect(positions, {0, 1, 2}, reason: 'doğru cevap her konumda görünebilmeli');
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
