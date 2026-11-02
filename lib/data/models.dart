/// İçerik modelleri: dersler, öğrenme çıktıları, konu anlatımları, kartlar.
library;

enum Subject {
  turkce('turkce', 'Türkçe', '📖'),
  matematik('matematik', 'Matematik', '🔢'),
  hayatBilgisi('hayat_bilgisi', 'Hayat Bilgisi', '🏡'),
  fenBilimleri('fen_bilimleri', 'Fen Bilimleri', '🔬'),
  sosyalBilgiler('sosyal_bilgiler', 'Sosyal Bilgiler', '🌍');

  const Subject(this.id, this.label, this.icon);
  final String id;
  final String label;
  final String icon;

  static Subject fromId(String id) =>
      Subject.values.firstWhere((s) => s.id == id,
          orElse: () => throw ArgumentError('Bilinmeyen ders: $id'));

  /// Maarif Modeli programlarına göre derslerin okutulduğu sınıflar.
  List<int> get grades => switch (this) {
        Subject.turkce => const [1, 2, 3, 4],
        Subject.matematik => const [1, 2, 3, 4],
        Subject.hayatBilgisi => const [1, 2, 3],
        Subject.fenBilimleri => const [3, 4],
        Subject.sosyalBilgiler => const [4],
      };

  static List<Subject> forGrade(int grade) =>
      Subject.values.where((s) => s.grades.contains(grade)).toList();
}

/// Programdaki bir öğrenme çıktısı.
class Outcome {
  const Outcome({
    required this.code,
    required this.subject,
    required this.grade,
    required this.title,
    required this.processSteps,
    this.unit,
    this.area,
  });

  final String code;
  final Subject subject;
  final int grade;
  final String title;
  final List<String> processSteps;

  /// Tema/ünite sırası (Türkçe'de yok; Türkçe beceri alanına bağlıdır).
  final int? unit;

  /// Türkçe beceri alanı (Dinleme/İzleme, Konuşma, Okuma, Yazma).
  final String? area;

  factory Outcome.fromJson(Map<String, Object?> j) => Outcome(
        code: j['kod']! as String,
        subject: Subject.fromId(j['ders']! as String),
        grade: (j['sinif']! as num).toInt(),
        title: j['baslik']! as String,
        processSteps: (j['surec'] as List<Object?>? ?? const [])
            .cast<String>()
            .toList(growable: false),
        unit: (j['unite'] as num?)?.toInt(),
        area: j['alan'] as String?,
      );
}

/// Ekranda çizilen basit görseller (resim dosyası gerektirmez).
class Visual {
  const Visual(this.kind, this.params);
  final String kind;
  final Map<String, Object?> params;

  factory Visual.fromJson(Map<String, Object?> j) => Visual(
        j['kind']! as String,
        Map<String, Object?>.from(j)..remove('kind'),
      );

  Map<String, Object?> toJson() => {'kind': kind, ...params};
}

/// Konu anlatımının bir sayfası.
class LessonPage {
  const LessonPage({required this.text, this.say, this.visual});
  final String text;

  /// Sesli okunacak metin (yoksa [text] okunur).
  final String? say;
  final Visual? visual;

  String get spoken => say ?? text;

  factory LessonPage.fromJson(Map<String, Object?> j) => LessonPage(
        text: j['text']! as String,
        say: j['say'] as String?,
        visual: j['visual'] == null
            ? null
            : Visual.fromJson(j['visual']! as Map<String, Object?>),
      );
}

class Lesson {
  const Lesson({required this.id, required this.title, required this.pages});
  final String id;
  final String title;
  final List<LessonPage> pages;

  factory Lesson.fromJson(Map<String, Object?> j) => Lesson(
        id: j['id']! as String,
        title: j['title']! as String,
        pages: (j['pages']! as List<Object?>)
            .map((p) => LessonPage.fromJson(p! as Map<String, Object?>))
            .toList(growable: false),
      );
}

/// Çocuğa gösterilen somut soru (sabit karttan ya da üreteçten).
class Question {
  const Question({
    required this.prompt,
    required this.options,
    required this.answerIndex,
    this.say,
    this.visual,
    this.explanation,
    this.hint,
  }) : assert(answerIndex >= 0);

  final String prompt;
  final String? say;
  final Visual? visual;
  final List<String> options;
  final int answerIndex;
  final String? explanation;
  final String? hint;

  String get answer => options[answerIndex];
  String get spoken => say ?? prompt;
}

/// Tekrar motorunun izlediği birim. Ya sabit bir sorudur ya da her
/// gösterimde farklı sayılarla soru üreten bir üreteç tanımıdır.
class CardDef {
  const CardDef({
    required this.id,
    required this.outcomeCode,
    this.fixed,
    this.generator,
    this.generatorParams = const {},
    this.fastSeconds = 15,
  }) : assert(fixed != null || generator != null);

  final String id;
  final String outcomeCode;
  final Question? fixed;
  final String? generator;
  final Map<String, Object?> generatorParams;

  /// Bu sürenin altındaki doğru cevap "hızlı doğru" sayılır.
  final int fastSeconds;

  factory CardDef.fromJson(String outcomeCode, Map<String, Object?> j) {
    final type = j['type'] as String? ?? 'mc';
    if (type == 'gen') {
      return CardDef(
        id: j['id']! as String,
        outcomeCode: outcomeCode,
        generator: j['gen']! as String,
        generatorParams:
            Map<String, Object?>.from(j['params'] as Map? ?? const {}),
        fastSeconds: (j['fast'] as num?)?.toInt() ?? 15,
      );
    }
    final options = (j['options']! as List<Object?>).cast<String>();
    final answer = (j['answer']! as num).toInt();
    if (answer < 0 || answer >= options.length) {
      throw FormatException('Geçersiz cevap indeksi: ${j['id']}');
    }
    return CardDef(
      id: j['id']! as String,
      outcomeCode: outcomeCode,
      fixed: Question(
        prompt: j['prompt']! as String,
        say: j['say'] as String?,
        visual: j['visual'] == null
            ? null
            : Visual.fromJson(j['visual']! as Map<String, Object?>),
        options: options,
        answerIndex: answer,
        explanation: j['explain'] as String?,
        hint: j['hint'] as String?,
      ),
      fastSeconds: (j['fast'] as num?)?.toInt() ?? 15,
    );
  }
}

/// Bir öğrenme çıktısına ait içerik paketi.
class OutcomeContent {
  const OutcomeContent({
    required this.outcomeCode,
    required this.lessons,
    required this.cards,
  });

  final String outcomeCode;
  final List<Lesson> lessons;
  final List<CardDef> cards;

  factory OutcomeContent.fromJson(Map<String, Object?> j) {
    final code = j['kod']! as String;
    return OutcomeContent(
      outcomeCode: code,
      lessons: (j['lessons'] as List<Object?>? ?? const [])
          .map((l) => Lesson.fromJson(l! as Map<String, Object?>))
          .toList(growable: false),
      cards: (j['cards'] as List<Object?>? ?? const [])
          .map((c) => CardDef.fromJson(code, c! as Map<String, Object?>))
          .toList(growable: false),
    );
  }
}
