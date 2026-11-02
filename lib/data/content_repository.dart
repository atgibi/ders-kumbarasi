/// Uygulamayla birlikte gelen müfredat ve içerik dosyalarını yükler.
library;

import 'dart:convert';

import 'models.dart';

typedef AssetLoader = Future<String> Function(String path);

class ContentRepository {
  ContentRepository(this._load);
  final AssetLoader _load;

  List<Outcome>? _outcomes;
  final Map<String, Map<String, OutcomeContent>> _content = {};

  static const outcomesAsset = 'assets/curriculum/tymm_ciktilar.json';
  static const unitsAsset = 'assets/curriculum/uniteler.json';

  Map<String, Object?>? _units;

  /// Ünite/tema adı (Matematik, Hayat Bilgisi, Fen, Sosyal). Türkçe'de null.
  Future<String?> unitName(Subject s, int grade, int unit) async {
    try {
      _units ??= jsonDecode(await _load(unitsAsset)) as Map<String, Object?>;
    } on Object {
      return null; // ünite adı yoksa yol yine de açılır
    }
    final bySubject = _units![s.id];
    if (bySubject is! Map) return null;
    final byGrade = bySubject['$grade'];
    if (byGrade is! Map) return null;
    return byGrade['$unit'] as String?;
  }

  static String contentAsset(Subject s, int grade) =>
      'assets/content/${s.id}_$grade.json';

  Future<List<Outcome>> outcomes() async {
    return _outcomes ??=
        (jsonDecode(await _load(outcomesAsset)) as List<Object?>)
            .map((e) => Outcome.fromJson(e! as Map<String, Object?>))
            .toList(growable: false);
  }

  Future<List<Outcome>> outcomesFor(Subject s, int grade) async =>
      (await outcomes())
          .where((o) => o.subject == s && o.grade == grade)
          .toList(growable: false);

  /// Ders/sınıf içerik paketi. Henüz hazırlanmamış paket boş döner.
  Future<Map<String, OutcomeContent>> contentFor(Subject s, int grade) async {
    final key = '${s.id}_$grade';
    final cached = _content[key];
    if (cached != null) return cached;
    Map<String, OutcomeContent> map;
    try {
      final raw = jsonDecode(await _load(contentAsset(s, grade)))
          as Map<String, Object?>;
      map = {
        for (final o in (raw['outcomes']! as List<Object?>))
          (o! as Map<String, Object?>)['kod']! as String:
              OutcomeContent.fromJson(o as Map<String, Object?>),
      };
    } on Exception {
      map = const {};
    } on Error {
      // rootBundle eksik dosyada FlutterError fırlatır
      map = const {};
    }
    return _content[key] = map;
  }
}
