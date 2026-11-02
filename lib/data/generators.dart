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

const _pairs = [
  ('🍎', 'elma'),
  ('🍐', 'armut'),
  ('⭐', 'yıldız'),
  ('🎈', 'balon'),
  ('🐟', 'balık'),
  ('🌼', 'çiçek'),
  ('🚗', 'araba'),
  ('⚽', 'top'),
];

/// İki grubu "daha çok / daha az / eşit" diye karşılaştırma (MAT.1.1.4).
Question _compareGroups(Map<String, Object?> p, Random r) {
  final max = _p(p, 'max', 10);
  final shuffled = List.of(_pairs)..shuffle(r);
  final x = shuffled[0], y = shuffled[1];
  final a = _between(r, 1, max);
  final b = r.nextInt(4) == 0 ? a : _between(r, 1, max);
  final askMore = r.nextBool();
  // Türkçe çoğul eki ünlü uyumuna göre
  final xp = _plural(x.$2), yp = _plural(y.$2);
  final opts = [xp, yp, 'Eşit'];
  final String ans;
  if (a == b) {
    ans = 'Eşit';
  } else if (askMore) {
    ans = a > b ? xp : yp;
  } else {
    ans = a < b ? xp : yp;
  }
  return Question(
    prompt: askMore ? 'Hangisi daha çok?' : 'Hangisi daha az?',
    visual: Visual('compare_groups', {'a': a, 'b': b, 'ea': x.$1, 'eb': y.$1}),
    options: opts,
    answerIndex: opts.indexOf(ans),
    explanation: a == b
        ? 'İkisi de $a tane; sayıları eşit.'
        : '$a tane ${x.$2} ve $b tane ${y.$2} var.',
  );
}

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Türkçe çoğul: son ünlü kalın (a, ı, o, u) ise -lar, ince ise -ler.
String _plural(String word) {
  const back = 'aıou';
  const front = 'eiöü';
  for (var i = word.length - 1; i >= 0; i--) {
    final c = word[i];
    if (back.contains(c)) return '${_cap(word)}lar';
    if (front.contains(c)) return '${_cap(word)}ler';
  }
  return '${_cap(word)}ler';
}

/// Günlük yaşam toplama/çıkarma problemi (MAT.1.2.1): hangi işlem?
/// İyelik ekleri elle yazılmıştır (armut -> armudu, balık -> balığı).
const _people = [
  ('Ali', "Ali'nin"),
  ('Elif', "Elif'in"),
  ('Can', "Can'ın"),
  ('Zeynep', "Zeynep'in"),
  ('Mert', "Mert'in"),
  ('Ayşe', "Ayşe'nin"),
  ('Emir', "Emir'in"),
  ('Defne', "Defne'nin"),
];
const _things = [
  ('elma', 'elması'),
  ('armut', 'armudu'),
  ('balon', 'balonu'),
  ('balık', 'balığı'),
  ('çiçek', 'çiçeği'),
  ('araba', 'arabası'),
  ('top', 'topu'),
  ('kalem', 'kalemi'),
];

Question _wordAddSub(Map<String, Object?> p, Random r) {
  final max = _p(p, 'max', 10);
  final who = _people[r.nextInt(_people.length)];
  final thing = _things[r.nextInt(_things.length)];
  final add = r.nextBool();
  final int a, b;
  final String text;
  if (add) {
    a = _between(r, 1, max - 1);
    b = _between(r, 1, max - a);
    text = '${who.$2} $a ${thing.$1} var. $b ${thing.$1} daha alıyor. '
        'Şimdi kaç ${thing.$2} var?';
  } else {
    a = _between(r, 2, max);
    b = _between(r, 1, a - 1);
    text = '${who.$2} $a ${thing.$1} var. $b tanesini arkadaşına veriyor. '
        'Kaç ${thing.$2} kalır?';
  }
  final plus = '$a + $b = ${a + b}', minus = '$a − $b = ${a - b}';
  final opts = [plus, minus]..shuffle(r);
  return Question(
    prompt: '$text\nHangi işlemi yaparız?',
    say: '$text Hangi işlemi yaparız?',
    options: opts,
    answerIndex: opts.indexOf(add ? plus : minus),
    explanation: add
        ? 'Daha fazla aldığı için toplarız: $plus.'
        : 'Verdiği için azalır, çıkarırız: $minus.',
  );
}

/// Eşit işaretinin iki tarafı (MAT.1.2.3): 3 + 4 = ☐ + 2
Question _equalSides(Map<String, Object?> p, Random r) {
  final max = _p(p, 'max_sum', 10);
  final s = _between(r, 3, max);
  final a = _between(r, 1, s - 1), b = s - a;
  int c;
  do {
    c = _between(r, 0, s);
  } while (c == a || c == b);
  final d = s - c;
  final o = numericOptions(d, r, spread: 2, preferred: [s, d + 1]);
  return Question(
    prompt: '$a + $b = ☐ + $c',
    say:
        'Eşittir işaretinin iki yanı aynı olmalı. $a artı $b, kutu artı $c ediyor. Kutuya hangi sayı gelir?',
    options: o.options,
    answerIndex: o.answerIndex,
    explanation: 'Sol taraf $s eder. $s olması için $d + $c gerekir.',
    hint: 'Önce sol tarafı hesapla.',
  );
}

/// Toplama ve çıkarmanın ters ilişkisi (MAT.1.2.4).
Question _factFamily(Map<String, Object?> p, Random r) {
  final max = _p(p, 'max_sum', 10);
  final s = _between(r, 2, max);
  final a = _between(r, 1, s - 1), b = s - a;
  final askB = r.nextBool();
  final ans = askB ? b : a;
  final o = numericOptions(ans, r, spread: 2, preferred: [s, askB ? a : b]);
  return Question(
    prompt: '$a + $b = $s ise $s − ${askB ? a : b} = ?',
    say: '$a artı $b, $s ediyorsa $s eksi ${askB ? a : b} kaç eder?',
    options: o.options,
    answerIndex: o.answerIndex,
    explanation: 'Toplamdan bir parçayı çıkarırsak diğer parça kalır: $ans.',
  );
}

/// Geriye doğru ritmik sayma (MAT.1.1.5).
Question _countBack(Map<String, Object?> p, Random r) {
  final from = _p(p, 'from', 20);
  final start = _between(r, 5, from);
  final seq = [for (var i = 0; i < 3; i++) start - i];
  final ans = start - 3;
  final o = numericOptions(ans, r, spread: 2, preferred: [start + 1, ans + 2]);
  return Question(
    prompt: '${seq.join(', ')}, ?',
    say: 'Geriye doğru sayıyoruz: ${seq.join(', ')}. Sırada hangi sayı var?',
    options: o.options,
    answerIndex: o.answerIndex,
    explanation:
        'Geriye sayarken her seferinde 1 azalır: ${seq.last}den sonra $ans gelir.',
  );
}

/// Çokluk tahmini (MAT.1.1.7): saymadan yaklaşık değer.
Question _estimate(Map<String, Object?> p, Random r) {
  final targets = [5, 10, 15, 20];
  final t = targets[r.nextInt(targets.length)];
  final n = (t + _between(r, -1, 1)).clamp(3, 20);
  final emoji = _objects[r.nextInt(_objects.length)];
  final opts = ['Yaklaşık 5', 'Yaklaşık 10', 'Yaklaşık 15', 'Yaklaşık 20'];
  return Question(
    prompt: 'Saymadan tahmin et: kaç tane var?',
    visual: Visual('objects', {'emoji': emoji, 'count': n, 'scatter': true}),
    options: opts,
    answerIndex: targets.indexOf(t),
    explanation: 'Tam olarak $n tane var; en yakın tahmin $t.',
  );
}

const _birler = [
  '',
  'bir',
  'iki',
  'üç',
  'dört',
  'beş',
  'altı',
  'yedi',
  'sekiz',
  'dokuz'
];
const _onlar = [
  '',
  'on',
  'yirmi',
  'otuz',
  'kırk',
  'elli',
  'altmış',
  'yetmiş',
  'seksen',
  'doksan'
];

/// Sayının Türkçe okunuşu (0 - 999 999): 1000 -> "bin", 100 -> "yüz".
String sayiOkunusu(int n) {
  if (n == 0) return 'sıfır';
  String uc(int x) {
    final y = x ~/ 100, o = (x % 100) ~/ 10, b = x % 10;
    return [
      if (y == 1) 'yüz' else if (y > 1) '${_birler[y]} yüz',
      if (o > 0) _onlar[o],
      if (b > 0) _birler[b],
    ].join(' ');
  }

  final binler = n ~/ 1000, kalan = n % 1000;
  return [
    if (binler == 1) 'bin' else if (binler > 1) '${uc(binler)} bin',
    if (kalan > 0) uc(kalan),
  ].join(' ');
}

/// Okunuşu verilen sayıyı bulma ya da sayının okunuşunu seçme.
Question _numberWords(Map<String, Object?> p, Random r) {
  final max = _p(p, 'max', 100);
  final n = _between(r, _p(p, 'min', 11), max);
  final toWord = r.nextBool();
  final o = numericOptions(n, r, spread: 2, preferred: [
    if (n >= 10 && n % 10 != 0 && n < 100) (n % 10) * 10 + n ~/ 10,
    n + 10,
    if (n > 10) n - 10,
  ]);
  if (toWord) {
    final words = o.options.map((e) => sayiOkunusu(int.parse(e))).toList();
    return Question(
      prompt: '$n sayısı nasıl okunur?',
      options: words,
      answerIndex: o.answerIndex,
      explanation: '$n: ${sayiOkunusu(n)}.',
    );
  }
  return Question(
    prompt: '“${sayiOkunusu(n)}” hangisidir?',
    say: '${sayiOkunusu(n)} sayısı hangisi?',
    options: o.options,
    answerIndex: o.answerIndex,
    explanation: '${sayiOkunusu(n)} rakamlarla $n diye yazılır.',
  );
}

/// Sıralama: en küçük, en büyük ya da arada kalan sayı.
Question _order3(Map<String, Object?> p, Random r) {
  final max = _p(p, 'max', 100);
  final set = <int>{};
  while (set.length < 3) {
    set.add(_between(r, 0, max));
  }
  final nums = set.toList()..sort();
  final kind = r.nextInt(3);
  final ans = switch (kind) { 0 => nums.first, 1 => nums.last, _ => nums[1] };
  final shown = List.of(nums)..shuffle(r);
  return Question(
    prompt: switch (kind) {
      0 => 'En küçük sayı hangisi?',
      1 => 'En büyük sayı hangisi?',
      _ => '${nums.first} ile ${nums.last} arasındaki sayı hangisi?',
    },
    options: shown.map((e) => '$e').toList(),
    answerIndex: shown.indexOf(ans),
    explanation: 'Küçükten büyüğe: ${nums.join(' < ')}.',
  );
}

const _hal = [
  '',
  "1'i",
  "2'yi",
  "3'ü",
  "4'ü",
  "5'i",
  "6'yı",
  "7'yi",
  "8'i",
  "9'u",
  "10'u",
  "11'i",
  "12'yi"
];
const _yonelme = [
  '',
  "1'e",
  "2'ye",
  "3'e",
  "4'e",
  "5'e",
  "6'ya",
  "7'ye",
  "8'e",
  "9'a",
  "10'a",
  "11'e",
  "12'ye"
];

/// Saatin Türkçe söylenişi: 3:00, 3:30, 3:15, 3:45 (12 saatlik).
String saatSoyle(int h, int m) {
  final next = h == 12 ? 1 : h + 1;
  return switch (m) {
    0 => 'Saat $h',
    30 => 'Saat $h buçuk',
    15 => "Saat ${_hal[h]} çeyrek geçiyor",
    45 => "Saat ${_yonelme[next]} çeyrek var",
    _ => 'Saat $h:${m.toString().padLeft(2, '0')}',
  };
}

Question _clockRead(Map<String, Object?> p, Random r) {
  final mins = (p['minutes'] as List<Object?>?)
          ?.cast<num>()
          .map((e) => e.toInt())
          .toList() ??
      [0, 30];
  final h = _between(r, 1, 12), m = mins[r.nextInt(mins.length)];
  final right = saatSoyle(h, m);
  final set = <String>{right};
  var guard = 0;
  while (set.length < 3 && guard++ < 50) {
    final hh = r.nextBool() ? h : _between(r, 1, 12);
    final mm = mins.length > 1 ? mins[r.nextInt(mins.length)] : m;
    set.add(saatSoyle(hh, mm));
    // Akrep-yelkovan karışıklığı çeldiricisi
    if (m == 0 && h <= 6) set.add(saatSoyle(h * 2 > 12 ? 12 : h * 2, 30));
  }
  final opts = set.take(3).toList();
  if (!opts.contains(right)) opts[0] = right;
  opts.shuffle(r);
  return Question(
    prompt: 'Saat kaç?',
    visual: Visual('clock', {'h': h, 'm': m}),
    options: opts,
    answerIndex: opts.indexOf(right),
    explanation:
        'Kısa kol (akrep) saati, uzun kol (yelkovan) dakikayı gösterir: $right.',
  );
}

/// Çarpmayı tekrarlı toplama olarak görme (MAT.2.2.4).
Question _multiplyAsAdd(Map<String, Object?> p, Random r) {
  final a = _between(r, 2, _p(p, 'a_max', 5));
  final b = _between(r, 1, _p(p, 'b_max', 5));
  final sum = List.filled(a, b).join(' + ');
  final o = numericOptions(a, r, spread: 2, min: 1, preferred: [b, a * b]);
  return Question(
    prompt: '$sum = ? × $b',
    say: '$a tane $b toplanıyor. Kaç kere $b eder?',
    visual: a * b <= 30
        ? Visual('groups', {'emoji': '🍓', 'groups': a, 'each': b})
        : null,
    options: o.options,
    answerIndex: o.answerIndex,
    explanation: '$b sayısını $a kez topladık: $a × $b = ${a * b}.',
  );
}

/// Tek mi çift mi?
Question _oddEven(Map<String, Object?> p, Random r) {
  final n = _between(r, 0, _p(p, 'max', 100));
  final opts = ['Tek', 'Çift'];
  return Question(
    prompt: '$n tek mi, çift mi?',
    options: opts,
    answerIndex: n.isEven ? 1 : 0,
    explanation:
        'Birler basamağı ${n % 10}: ${n.isEven ? 'çift (0, 2, 4, 6, 8)' : 'tek (1, 3, 5, 7, 9)'}.',
  );
}

/// İki sayının toplamı tek mi çift mi? (tümevarımsal akıl yürütme)
Question _oddEvenSum(Map<String, Object?> p, Random r) {
  final max = _p(p, 'max', 50);
  final a = _between(r, 1, max), b = _between(r, 1, max);
  String te(int x) => x.isEven ? 'çift' : 'tek';
  final opts = ['Tek', 'Çift'];
  return Question(
    prompt: '$a + $b toplamı tek mi, çift mi?',
    options: opts,
    answerIndex: (a + b).isEven ? 1 : 0,
    explanation: '${te(a)} + ${te(b)} = ${te(a + b)} (${a + b}).',
    hint: 'Tek + tek = çift, çift + çift = çift, tek + çift = tek.',
  );
}

/// En yakın onluğa ya da yüzlüğe yuvarlama.
Question _roundTo(Map<String, Object?> p, Random r) {
  final to = _p(p, 'to', 10);
  final n = _between(r, to + 1, _p(p, 'max', 999));
  final lo = n ~/ to * to;
  final ans = n - lo >= to ~/ 2 ? lo + to : lo;
  final other = ans == lo ? lo + to : lo;
  final opts = [
    '$lo',
    '${lo + to}',
    if (to == 10) '${lo + 2 * to}' else '${n ~/ 10 * 10}'
  ].toSet().toList()
    ..shuffle(r);
  return Question(
    prompt: '$n sayısını en yakın ${to == 10 ? 'onluğa' : 'yüzlüğe'} yuvarla.',
    options: opts,
    answerIndex: opts.indexOf('$ans'),
    explanation: '$n, $ans sayısına $other sayısından daha yakındır.',
  );
}

/// Birim dönüştürme: m-cm, km-m, kg-g, ton-kg, L-mL, saat-dakika, dakika-saniye, gün-saat, yıl-ay, hafta-gün.
Question _unitConvert(Map<String, Object?> p, Random r) {
  final kinds = (p['kinds'] as List<Object?>?)?.cast<String>() ??
      [
        'm_cm',
        'km_m',
        'kg_g',
        'ton_kg',
        'saat_dk',
        'dk_sn',
        'gun_saat',
        'hafta_gun',
        'yil_ay'
      ];
  final k = kinds[r.nextInt(kinds.length)];
  final (String big, String small, int f) = switch (k) {
    'm_cm' => ('metre', 'santimetre', 100),
    'km_m' => ('kilometre', 'metre', 1000),
    'kg_g' => ('kilogram', 'gram', 1000),
    'ton_kg' => ('ton', 'kilogram', 1000),
    'l_ml' => ('litre', 'mililitre', 1000),
    'saat_dk' => ('saat', 'dakika', 60),
    'dk_sn' => ('dakika', 'saniye', 60),
    'gun_saat' => ('gün', 'saat', 24),
    'hafta_gun' => ('hafta', 'gün', 7),
    'yil_ay' => ('yıl', 'ay', 12),
    _ => ('metre', 'santimetre', 100),
  };
  final n = _between(r, 1, f >= 1000 ? 5 : (f >= 60 ? 3 : 4));
  final ans = n * f;
  final o = numericOptions(ans, r,
      spread: f, min: 1, preferred: [n * 10, n * 100, ans + f]);
  return Question(
    prompt: '$n $big kaç $small eder?',
    options: o.options.map((e) => '$e $small').toList(),
    answerIndex: o.answerIndex,
    explanation: '1 $big = $f $small, öyleyse $n $big = $ans $small.',
  );
}

/// Kesir okuma: boyalı parçaların kesirle gösterimi.
Question _fractionRead(Map<String, Object?> p, Random r) {
  final allowed = (p['parts'] as List<Object?>?)
          ?.cast<num>()
          .map((e) => e.toInt())
          .toList() ??
      [2, 3, 4, 6, 8];
  final n = allowed[r.nextInt(allowed.length)];
  final unit = p['unit'] as bool? ?? false;
  final k = unit ? 1 : _between(r, 1, n);
  final right = '$k/$n';
  final set = <String>{right, '$n/$k', if (k < n) '${n - k}/$n', '$k/${n + 1}'};
  final opts = set.take(3).toList()..shuffle(r);
  return Question(
    prompt: 'Boyalı kısmı gösteren kesir hangisi?',
    visual: Visual('fraction', {'parts': n, 'shaded': k}),
    options: opts,
    answerIndex: opts.indexOf(right),
    explanation:
        'Bütün $n eş parçaya bölünmüş (payda $n), $k parça boyalı (pay $k): $right.',
  );
}

/// Çevre uzunluğu: kare, dikdörtgen, üçgen.
Question _perimeter(Map<String, Object?> p, Random r) {
  final max = _p(p, 'max', 10);
  final t = r.nextInt(3);
  late final int ans;
  late final String text;
  switch (t) {
    case 0:
      final a = _between(r, 2, max);
      ans = 4 * a;
      text = 'Bir kenarı $a cm olan karenin çevresi kaç cm?';
    case 1:
      final a = _between(r, 3, max), b = _between(r, 1, a - 1);
      ans = 2 * (a + b);
      text = 'Kenarları $a cm ve $b cm olan dikdörtgenin çevresi kaç cm?';
    default:
      final a = _between(r, 2, max),
          b = _between(r, 2, max),
          c = _between(r, 2, max);
      ans = a + b + c;
      text = 'Kenarları $a cm, $b cm ve $c cm olan üçgenin çevresi kaç cm?';
  }
  final o = numericOptions(ans, r, spread: 4, min: 1, preferred: [ans ~/ 2]);
  return Question(
    prompt: text,
    visual: Visual('shapes', {
      'items': [
        ['kare', 'dikdortgen', 'ucgen'][t]
      ]
    }),
    options: o.options.map((e) => '$e cm').toList(),
    answerIndex: o.answerIndex,
    explanation: 'Çevre, bütün kenarların toplamıdır: $ans cm.',
  );
}

/// Çarpma ve bölme gerektiren günlük yaşam problemi.
Question _wordMulDiv(Map<String, Object?> p, Random r) {
  final max = _p(p, 'max', 10);
  final a = _between(r, 2, max), b = _between(r, 2, max);
  final thing = _things[r.nextInt(_things.length)];
  final mul = r.nextBool();
  final String text;
  final int ans;
  if (mul) {
    ans = a * b;
    text =
        'Her pakette $b ${thing.$1} var. $a pakette toplam kaç ${thing.$1} vardır?';
  } else {
    ans = b;
    text =
        '${a * b} ${thing.$1} $a kişiye eşit paylaştırılıyor. Her kişi kaç ${thing.$1} alır?';
  }
  final o = numericOptions(ans, r,
      spread: 3, min: 1, preferred: [a + b, if (!mul) a]);
  return Question(
    prompt: text,
    options: o.options,
    answerIndex: o.answerIndex,
    explanation: mul ? '$a × $b = $ans.' : '${a * b} ÷ $a = $ans.',
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
  'compare_groups': _compareGroups,
  'word_add_sub': _wordAddSub,
  'equal_sides': _equalSides,
  'fact_family': _factFamily,
  'count_back': _countBack,
  'estimate': _estimate,
  'number_words': _numberWords,
  'order3': _order3,
  'clock_read': _clockRead,
  'multiply_as_add': _multiplyAsAdd,
  'odd_even': _oddEven,
  'odd_even_sum': _oddEvenSum,
  'round_to': _roundTo,
  'unit_convert': _unitConvert,
  'fraction_read': _fractionRead,
  'perimeter': _perimeter,
  'word_mul_div': _wordMulDiv,
};

Question generate(CardDef card, Random rnd) {
  if (card.fixed != null) return card.fixed!;
  final g = generators[card.generator];
  if (g == null) {
    throw StateError('Bilinmeyen üreteç: ${card.generator} (${card.id})');
  }
  return g(card.generatorParams, rnd);
}
