// Bütün içerik ve ilerleme taraması: her sınıfın her dersinde her kart
// üretilir ve denetlenir; her konu sırayla oturumla başlatılır; her
// bölgenin düellosu kurulur. Sorunlar toplanıp tek seferde raporlanır.
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:ders_kumbarasi/app/session_controller.dart';
import 'package:ders_kumbarasi/data/content_repository.dart';
import 'package:ders_kumbarasi/data/generators.dart';
import 'package:ders_kumbarasi/data/models.dart';
import 'package:ders_kumbarasi/data/progress_store.dart';
import 'package:ders_kumbarasi/game/world.dart';

ContentRepository fileRepo() =>
    ContentRepository((p) => File(p).readAsString());

/// Bir sorunun çocuk tarafından doğru cevaplanabilir olduğunu denetler.
List<String> checkQuestion(CardDef c, Question q, int grade) {
  final p = <String>[];
  if (q.prompt.trim().isEmpty) p.add('boş soru metni');
  if (q.activity) return p;
  if (q.answerIndex < 0 || q.answerIndex >= q.options.length) {
    p.add('cevap indeksi dışarıda (${q.answerIndex}/${q.options.length})');
    return p;
  }
  if (q.options.any((o) => o.trim().isEmpty)) p.add('boş seçenek');
  switch (q.kind) {
    case QKind.choice:
      if (q.options.length < 2) p.add('tek seçenek');
      if (q.options.map((o) => o.trim()).toSet().length != q.options.length) {
        p.add('aynı metinli seçenekler: ${q.options}');
      }
      final want = grade <= 1 ? 3 : 4;
      if (c.fixed != null &&
          q.options.length != want &&
          q.options.length != 2) {
        p.add('seçenek sayısı ${q.options.length} (beklenen $want)');
      }
    case QKind.keypad:
      final a = q.options[q.answerIndex];
      if (!RegExp(r'^\d{1,5}$').hasMatch(a)) {
        p.add('tuş takımıyla yazılamayan cevap: "$a"');
      }
    case QKind.clock:
      final pr = q.pairs;
      if (pr == null || pr.length < 3) {
        p.add('saat kurma verisi eksik');
      } else {
        final h = int.tryParse(pr[0]), m = int.tryParse(pr[1]);
        final st = int.tryParse(pr[2]);
        if (h == null || m == null || st == null || st <= 0) {
          p.add('saat kurma verisi bozuk: $pr');
        } else {
          if (h < 1 || h > 12) p.add('saat 1–12 dışında: $h');
          if (m % st != 0) p.add('dakika $m, $st adımla kurulamaz');
        }
      }
    case QKind.order:
      if (q.options.length < 2) p.add('sıralamada tek öğe');
    case QKind.syllables:
      if (q.options.isEmpty) p.add('hece yok');
    case QKind.match:
      final pr = q.pairs;
      if (pr == null || pr.length != q.options.length) {
        p.add('eşleştirme sağ sütunu eksik');
      } else if (pr.toSet().length != pr.length) {
        p.add('eşleştirmede aynı sağ öğe: $pr');
      } else if (q.options.toSet().length != q.options.length) {
        p.add('eşleştirmede aynı sol öğe: ${q.options}');
      }
  }
  // Sabit kartta yanlış seçenek açıklamaları üretimden sonra da kalmalı
  final f = c.fixed;
  if (f != null && f.optionNotes != null) {
    final n = q.optionNotes;
    if (n == null) {
      p.add('yanlış seçenek açıklamaları kayboldu');
    } else {
      for (var i = 0; i < q.options.length; i++) {
        if (i == q.answerIndex) continue;
        final orig = f.options.indexOf(q.options[i]);
        if (orig >= 0 && f.optionNotes![orig] != n[i]) {
          p.add('açıklama yanlış seçeneğe gitti');
          break;
        }
      }
    }
  }
  return p;
}

void main() {
  test('her kart, her sınıfta 40 kez üretilir ve cevaplanabilir', () async {
    final repo = fileRepo();
    final problems = <String>[];
    var cards = 0;
    for (final s in Subject.values) {
      for (final g in s.grades) {
        final pack = await repo.contentFor(s, g);
        for (final oc in pack.values) {
          for (final c in oc.cards) {
            cards++;
            final seen = <String>{};
            for (var seed = 0; seed < 40; seed++) {
              try {
                final q = generate(c, Random(seed));
                for (final e in checkQuestion(c, q, g)) {
                  if (seen.add(e)) problems.add('${c.id}: $e');
                }
              } on Object catch (e) {
                if (seen.add('$e')) problems.add('${c.id}: HATA $e');
              }
            }
          }
        }
      }
    }
    expect(cards, greaterThan(5000));
    expect(problems, isEmpty,
        reason: '${problems.length} sorun:\n${problems.take(80).join('\n')}');
  });

  test('her ders, her sınıf: konular sırayla başlatılabilir (takılma yok)',
      () async {
    final repo = fileRepo();
    final problems = <String>[];
    for (final s in Subject.values) {
      for (final g in s.grades) {
        final outcomes = await repo.outcomesFor(s, g);
        final pack = await repo.contentFor(s, g);
        if (pack.isEmpty) continue;
        final progress = ChildProgress();
        var now = DateTime(2026, 11, 2, 17);
        for (final o in outcomes) {
          if (pack[o.code]?.cards.isEmpty ?? true) continue;
          final c = await SessionController.build(
            repo: repo,
            subject: s,
            grade: g,
            progress: progress,
            clock: () => now,
            random: Random(o.code.hashCode),
            focusOutcome: o.code,
          );
          if (c.steps.isEmpty) {
            problems.add('${o.code}: oturum boş');
            continue;
          }
          var guard = 0;
          var wrong = true; // her konuda ilk soruyu bilerek yanlış cevapla
          while (!c.isDone && guard++ < 200) {
            final st = c.current;
            if (st.kind == StepKind.lesson) {
              if (st.lesson!.pages.isEmpty) {
                problems.add('${o.code}: sayfası olmayan anlatım');
              }
              c.completeLesson();
            } else if (st.question!.activity) {
              c.completeActivity();
              c.next();
            } else {
              final q = st.question!;
              c.answer(wrong ? (q.answerIndex + 1) % q.options.length
                  : q.answerIndex,
                  elapsed: const Duration(seconds: 5));
              wrong = false;
              c.next();
            }
          }
          if (!c.isDone) problems.add('${o.code}: oturum bitmiyor');
          c.finish();
          if (!progress.startedOutcomes.contains(o.code)) {
            problems.add('${o.code}: oturum bitti ama konu başlamadı '
                '(yol düğümü açık kalır, sonraki konu açılmaz)');
          }
          now = now.add(const Duration(hours: 1));
        }
        // Başlanmış konunun tekrar oturumu da kurulur
        final extra = await SessionController.build(
            repo: repo,
            subject: s,
            grade: g,
            progress: progress,
            clock: () => now,
            extraPractice: true);
        if (extra.steps.isEmpty) problems.add('$s/$g: ekstra tekrar boş');
        // Her bölgenin düellosu en az bir soru içerir
        for (final r in regionsOf(s, g, outcomes)) {
          final withContent = r.outcomes
              .where((o) => pack[o.code]?.cards.isNotEmpty ?? false)
              .map((o) => o.code)
              .toList();
          if (withContent.isEmpty) continue;
          final d = await SessionController.duel(
              repo: repo,
              subject: s,
              grade: g,
              progress: progress,
              outcomeCodes: withContent,
              clock: () => now);
          if (d.steps.isEmpty) {
            problems.add('${r.key}: düello boş (bekçi kurtarılamaz)');
          }
        }
      }
    }
    expect(problems, isEmpty,
        reason: '${problems.length} sorun:\n${problems.take(80).join('\n')}');
  });
}
