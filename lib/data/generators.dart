/// Parametrik soru üreteçleri: aynı kart her tekrarda farklı sayılarla gelir;
/// çocuk cevabı değil kavramı hatırlar (proje planı 4.4).
library;

import 'dart:math';

import 'models.dart';

typedef QuestionGenerator = Question Function(
    Map<String, Object?> params, Random rnd);

int _p(Map<String, Object?> p, String k, int def) =>
    (p[k] as num?)?.toInt() ?? def;

int _between(Random r, int min, int max) => min + r.nextInt(max - min + 1);

/// Doğru cevabın etrafında, tekrarsız ve negatif olmayan çeldiricilerle
/// karışık seçenek listesi üretir.
({List<String> options, int answerIndex}) numericOptions(
  int answer,
  Random rnd, {
  int count = 3,
  int spread = 3,
  int min = 0,
  List<int> preferred = const [],
}) {
  final set = <int>{answer};
  for (final p in preferred) {
    if (set.length >= count) break;
    if (p >= min && p != answer) set.add(p);
  }
  var guard = 0;
  while (set.length < count && guard++ < 200) {
    final d = _between(rnd, -spread, spread);
    final v = answer + d;
    if (v >= min && d != 0) set.add(v);
  }
  // Çok dar aralıkta (ör. cevap 0) yeterli seçenek yoksa yukarı doğru doldur
  var up = answer + spread + 1;
  while (set.length < count) {
    set.add(up++);
  }
  final list = set.toList()..shuffle(rnd);
  return (
    options: list.map((e) => '$e').toList(growable: false),
    answerIndex: list.indexOf(answer),
  );
}

const _objects = ['🍎', '⭐', '🎈', '🐟', '🌼', '🚗', '🐞', '⚽', '🍐', '🐥'];

Question _countObjects(Map<String, Object?> p, Random r) {
  final max = _p(p, 'max', 10);
  final n = _between(r, _p(p, 'min', 1), max);
  final emoji = _objects[r.nextInt(_objects.length)];
  final o = numericOptions(n, r, spread: 2, min: 1);
  return Question(
    prompt: 'Kaç tane var?',
    say: 'Resimde kaç tane var? Say bakalım.',
    visual: Visual('objects', {'emoji': emoji, 'count': n}),
    options: o.options,
    answerIndex: o.answerIndex,
    explanation: 'Tek tek saydığımızda $n tane buluruz.',
  );
}

Question _compare(Map<String, Object?> p, Random r) {
  final max = _p(p, 'max', 20);
  int a, b;
  do {
    a = _between(r, 0, max);
    b = _between(r, 0, max);
  } while (a == b);
  final askBigger = r.nextBool();
  final ans = askBigger ? max_(a, b) : min_(a, b);
  final opts = [a, b];
  return Question(
    prompt: askBigger ? 'Hangisi daha büyük?' : 'Hangisi daha küçük?',
    options: opts.map((e) => '$e').toList(),
    answerIndex: opts.indexOf(ans),
    explanation: askBigger
        ? '$ans, ${ans == a ? b : a} sayısından daha büyüktür.'
        : '$ans, ${ans == a ? b : a} sayısından daha küçüktür.',
  );
}

int max_(int a, int b) => a > b ? a : b;
int min_(int a, int b) => a < b ? a : b;

Question _add(Map<String, Object?> p, Random r) {
  final maxSum = _p(p, 'max_sum', 10);
  final allowCarry = p['carry'] as bool? ?? true;
  int a, b;
  var guard = 0;
  do {
    a = _between(r, _p(p, 'min', 0), maxSum);
    b = _between(r, 0, maxSum - a);
  } while (!allowCarry && (a % 10) + (b % 10) >= 10 && guard++ < 100);
  final s = a + b;
  final o = numericOptions(s, r,
      spread: 2,
      // Sık hata: basamak birleştirme ("38 + 5 = 313") yerine yakın komşular
      preferred: [s + 1, s - 1, if (s >= 10) s + 10, if (s >= 10) s - 10]);
  return Question(
    prompt: '$a + $b = ?',
    say: '$a artı $b kaç eder?',
    visual: maxSum <= 10
        ? Visual('objects2', {'emoji': '🍎', 'a': a, 'b': b})
        : null,
    options: o.options,
    answerIndex: o.answerIndex,
    explanation: '$a ile $b toplanınca $s olur.',
    hint: maxSum <= 20 ? 'Büyük sayıdan başla, $b tane ileri say.' : null,
  );
}

Question _sub(Map<String, Object?> p, Random r) {
  final max = _p(p, 'max', 10);
  final allowBorrow = p['borrow'] as bool? ?? true;
  int a, b;
  var guard = 0;
  do {
    a = _between(r, 1, max);
    b = _between(r, 0, a);
  } while (!allowBorrow && (a % 10) < (b % 10) && guard++ < 100);
  final d = a - b;
  final o = numericOptions(d, r, spread: 2, preferred: [d + 1, a + b]);
  return Question(
    prompt: '$a − $b = ?',
    say: '$a eksi $b kaç eder?',
    visual: max <= 10
        ? Visual('objects_crossed', {'emoji': '🎈', 'total': a, 'crossed': b})
        : null,
    options: o.options,
    answerIndex: o.answerIndex,
    explanation: '$a içinden $b çıkarılınca $d kalır.',
    hint: max <= 20 ? '$a sayısından $b tane geri say.' : null,
  );
}

Question _missingAddend(Map<String, Object?> p, Random r) {
  final maxSum = _p(p, 'max_sum', 10);
  final s = _between(r, 2, maxSum);
  final a = _between(r, 0, s);
  final b = s - a;
  final o = numericOptions(b, r, spread: 2, preferred: [s]);
  return Question(
    prompt: '$a + ☐ = $s',
    say: '$a ile hangi sayıyı toplarsak $s eder?',
    options: o.options,
    answerIndex: o.answerIndex,
    explanation: '$a + $b = $s, yani kutuya $b gelir.',
    hint: '$a sayısından $s sayısına kadar ileri say.',
  );
}

Question _multiply(Map<String, Object?> p, Random r) {
  final aMax = _p(p, 'a_max', 5);
  final bMax = _p(p, 'b_max', 5);
  final a = _between(r, _p(p, 'a_min', 1), aMax);
  final b = _between(r, _p(p, 'b_min', 1), bMax);
  final m = a * b;
  final o = numericOptions(m, r,
      spread: max_(2, a), preferred: [m + a, m - a, a + b]);
  return Question(
    prompt: '$a × $b = ?',
    say: '$a kere $b kaç eder?',
    visual: m <= 30
        ? Visual('groups', {'emoji': '🍓', 'groups': a, 'each': b})
        : null,
    options: o.options,
    answerIndex: o.answerIndex,
    explanation: '$a tane $b, $m eder.',
  );
}

Question _divide(Map<String, Object?> p, Random r) {
  final qMax = _p(p, 'q_max', 5);
  final dMax = _p(p, 'd_max', 5);
  final d = _between(r, 2, dMax);
  final q = _between(r, 1, qMax);
  final n = d * q;
  final o = numericOptions(q, r, spread: 2, min: 1, preferred: [q + 1, d]);
  return Question(
    prompt: '$n ÷ $d = ?',
    say: '$n bölü $d kaç eder?',
    options: o.options,
    answerIndex: o.answerIndex,
    explanation: '$d × $q = $n olduğu için $n ÷ $d = $q.',
  );
}

Question _placeValue(Map<String, Object?> p, Random r) {
  final digits = _p(p, 'digits', 2);
  final names = [
    'birler',
    'onlar',
    'yüzler',
    'binler',
    'on binler',
    'yüz binler'
  ];
  final lo = digits == 1 ? 0 : pow(10, digits - 1).toInt();
  final hi = pow(10, digits).toInt() - 1;
  final n = _between(r, lo, hi);
  final s = '$n';
  final pos = r.nextInt(digits); // 0 = birler
  final digit = s[s.length - 1 - pos];
  final opts = names.take(digits).toList()..shuffle(r);
  return Question(
    prompt: '$n sayısındaki $digit rakamı hangi basamakta?',
    say: '$n sayısında $digit rakamı hangi basamakta?',
    visual: Visual('number_highlight', {'number': n, 'pos': pos}),
    options: opts,
    answerIndex: opts.indexOf(names[pos]),
    explanation:
        '$digit, sağdan ${pos + 1}. basamakta; yani ${names[pos]} basamağında.',
  );
}

Question _tensOnes(Map<String, Object?> p, Random r) {
  final max = _p(p, 'max', 99);
  final n = _between(r, 10, max);
  final tens = n ~/ 10, ones = n % 10;
  final o = numericOptions(n, r,
      spread: 1, preferred: [ones * 10 + tens, tens + ones, n + 10]);
  return Question(
    prompt: '$tens onluk ve $ones birlik kaç eder?',
    visual: Visual('blocks', {'tens': tens, 'ones': ones}),
    options: o.options,
    answerIndex: o.answerIndex,
    explanation: '$tens onluk = ${tens * 10}, $ones birlik eklenince $n olur.',
  );
}

/// Üleştirme sayı sıfatı: 2 -> ikişer, 5 -> beşer, 10 -> onar.
String _dagitma(int n) =>
    const {
      2: 'ikişer',
      3: 'üçer',
      4: 'dörder',
      5: 'beşer',
      6: 'altışar',
      7: 'yedişer',
      8: 'sekizer',
      9: 'dokuzar',
      10: 'onar',
      100: 'yüzer',
    }[n] ??
    '$n';

Question _skipCount(Map<String, Object?> p, Random r) {
  final step = (p['steps'] as List<Object?>?)
          ?.cast<num>()
          .map((e) => e.toInt())
          .toList() ??
      [2, 5, 10];
  final st = step[r.nextInt(step.length)];
  final start = st * _between(r, 0, 5);
  final seq = [for (var i = 0; i < 4; i++) start + st * i];
  final ans = start + st * 4;
  final o = numericOptions(ans, r, spread: st, preferred: [ans + 1, ans - 1]);
  return Question(
    prompt: '${seq.join(', ')}, ?',
    say:
        'Sayılar ${_dagitma(st)} ${_dagitma(st)} artıyor. Sıradaki sayı hangisi?',
    options: o.options,
    answerIndex: o.answerIndex,
    explanation: 'Her seferinde $st ekliyoruz: ${seq.last} + $st = $ans.',
  );
}

Question _ordinal(Map<String, Object?> p, Random r) {
  final n = _between(r, 3, _p(p, 'max', 6));
  final animals = ['🐢', '🐇', '🐕', '🐈', '🐓', '🦆', '🐑', '🐄'];
  final row = (List.of(animals)..shuffle(r)).take(n).toList();
  final k = r.nextInt(n);
  final ordinals = [
    'birinci',
    'ikinci',
    'üçüncü',
    'dördüncü',
    'beşinci',
    'altıncı',
    'yedinci',
    'sekizinci'
  ];
  final opts = (List.of(row)..shuffle(r)).take(min_(3, n)).toSet();
  opts.add(row[k]);
  final list = opts.toList()..shuffle(r);
  return Question(
    prompt: 'Soldan ${ordinals[k]} hayvan hangisi?',
    visual: Visual('row', {'items': row}),
    options: list,
    answerIndex: list.indexOf(row[k]),
    explanation: 'Soldan saydığımızda ${ordinals[k]} sırada ${row[k]} var.',
  );
}

final Map<String, QuestionGenerator> generators = {
  'count_objects': _countObjects,
  'compare': _compare,
  'add': _add,
  'sub': _sub,
  'missing_addend': _missingAddend,
  'multiply': _multiply,
  'divide': _divide,
  'place_value': _placeValue,
  'tens_ones': _tensOnes,
  'skip_count': _skipCount,
  'ordinal': _ordinal,
};

Question generate(CardDef card, Random rnd) {
  if (card.fixed != null) return card.fixed!;
  final g = generators[card.generator];
  if (g == null) {
    throw StateError('Bilinmeyen üreteç: ${card.generator} (${card.id})');
  }
  return g(card.generatorParams, rnd);
}
