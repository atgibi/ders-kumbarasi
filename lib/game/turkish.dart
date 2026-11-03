/// Özel adlar için Türkçe ek uyumu (kesme işaretiyle).
library;

const _back = 'aıou';
const _front = 'eiöü';
const _hard = 'fstkçşhp';

String? _lastVowel(String w) {
  for (var i = w.length - 1; i >= 0; i--) {
    final c = w[i].toLowerCase();
    if (_back.contains(c) || _front.contains(c)) return c;
  }
  return null;
}

/// Bulunma eki: Demirdağ'da, Ocakvadi'de, Işıkkaya'da.
String locative(String word) {
  final v = _lastVowel(word) ?? 'a';
  final last = word.isEmpty ? '' : word[word.length - 1].toLowerCase();
  final d = _hard.contains(last) ? 't' : 'd';
  final a = _back.contains(v) ? 'a' : 'e';
  return "$word'$d$a";
}
