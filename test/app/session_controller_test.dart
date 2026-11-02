import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:ders_kumbarasi/app/session_controller.dart';
import 'package:ders_kumbarasi/core/srs/leitner.dart';
import 'package:ders_kumbarasi/data/content_repository.dart';
import 'package:ders_kumbarasi/data/generators.dart';
import 'package:ders_kumbarasi/data/models.dart';
import 'package:ders_kumbarasi/data/progress_store.dart';

ContentRepository fileRepo() =>
    ContentRepository((p) => File(p).readAsString());

void main() {
  test('tüm içerik paketleri yüklenir ve her kart 50 kez sorunsuz üretilir',
      () async {
    final repo = fileRepo();
    final outcomes = await repo.outcomes();
    expect(outcomes.length, 310);
    var packs = 0;
    for (final s in Subject.values) {
      for (final g in s.grades) {
        final pack = await repo.contentFor(s, g);
        if (pack.isEmpty) continue;
        packs++;
        final codes = outcomes
            .where((o) => o.subject == s && o.grade == g)
            .map((o) => o.code)
            .toSet();
        for (final oc in pack.values) {
          expect(codes, contains(oc.outcomeCode));
          for (final c in oc.cards) {
            expect(c.id, startsWith('${oc.outcomeCode}#'));
            for (var seed = 0; seed < 50; seed++) {
              final q = generate(c, Random(seed));
              expect(q.options.toSet().length, q.options.length, reason: c.id);
              expect(q.answerIndex, inInclusiveRange(0, q.options.length - 1),
                  reason: c.id);
            }
          }
        }
      }
    }
    expect(packs, greaterThan(0));
  });

  group('SessionController', () {
    test(
        'ilk oturum: konu anlatımı + uygulama; yanlış cevap sonda tekrar sorulur',
        () async {
      var now = DateTime(2026, 11, 2, 17);
      final progress = ChildProgress();
      final c = await SessionController.build(
        repo: fileRepo(),
        subject: Subject.matematik,
        grade: 1,
        progress: progress,
        clock: () => now,
        random: Random(3),
      );
      expect(c.plan.newOutcomeId, 'MAT.1.1.1');
      expect(c.steps.first.kind, StepKind.lesson);
      final practiceCount =
          c.steps.where((s) => s.phase == StepPhase.practice).length;
      expect(practiceCount, 6);

      c.completeLesson();
      expect(progress.startedOutcomes, contains('MAT.1.1.1'));

      var first = true;
      while (!c.isDone) {
        final step = c.current;
        expect(step.kind, StepKind.question);
        final q = step.question!;
        // İlk soruyu bilerek yanlış cevapla
        final pick =
            first ? (q.answerIndex + 1) % q.options.length : q.answerIndex;
        c.answer(pick, elapsed: const Duration(seconds: 3));
        first = false;
        c.next();
      }
      expect(c.summary.answered, 6);
      expect(c.summary.correct, 5);
      expect(c.summary.retried, 1);
      expect(c.steps.last.phase, StepPhase.retry);

      now = now.add(const Duration(minutes: 7));
      c.finish();
      expect(progress.dailyMinutes['2026-11-02'], 7);
      expect(progress.streakDays, 1);
      // Doğru cevaplanan kartlar kutu 1'de, yarına planlı
      final boxes = progress.cards.values.map((s) => s.box).toList();
      expect(boxes.where((b) => b == 1).length, 5);
      expect(boxes.where((b) => b == 0).length, 1);
    });

    test(
        'ertesi gün: dünkü kartlar ısınma/tekrar olarak gelir, sıradaki çıktı yeni konu olur',
        () async {
      final repo = fileRepo();
      final day1 = DateTime(2026, 11, 2, 17);
      final progress = ChildProgress();
      final c1 = await SessionController.build(
          repo: repo,
          subject: Subject.matematik,
          grade: 1,
          progress: progress,
          clock: () => day1,
          random: Random(1));
      c1.completeLesson();
      while (!c1.isDone) {
        c1.answer(c1.current.question!.answerIndex,
            elapsed: const Duration(seconds: 2));
        c1.next();
      }
      c1.finish();

      final day2 = DateTime(2026, 11, 3, 17);
      final c2 = await SessionController.build(
          repo: repo,
          subject: Subject.matematik,
          grade: 1,
          progress: progress,
          clock: () => day2,
          random: Random(2));
      expect(c2.plan.newOutcomeId, 'MAT.1.1.2');
      final reviewed = c2.steps
          .where(
              (s) => s.phase == StepPhase.warmup || s.phase == StepPhase.review)
          .map((s) => s.card!.id)
          .toSet();
      expect(reviewed.length, 6);
      expect(reviewed.every((id) => id.startsWith('MAT.1.1.1#')), isTrue);
    });

    test('içeriği olmayan ders boş oturum döner (çökmez)', () async {
      final c = await SessionController.build(
        repo: ContentRepository((p) async => p.contains('tymm_ciktilar')
            ? File(p).readAsString()
            : throw const FileSystemException('yok')),
        subject: Subject.sosyalBilgiler,
        grade: 4,
        progress: ChildProgress(),
      );
      expect(c.steps, isEmpty);
    });

    test('oturum içi tekrar (retry) motoru ikinci kez etkilemez', () async {
      final now = DateTime(2026, 11, 2, 17);
      final progress = ChildProgress();
      final c = await SessionController.build(
          repo: fileRepo(),
          subject: Subject.matematik,
          grade: 1,
          progress: progress,
          clock: () => now,
          random: Random(5));
      c.completeLesson();
      while (c.current.phase != StepPhase.retry) {
        final q = c.current.question!;
        c.answer((q.answerIndex + 1) % q.options.length,
            elapsed: const Duration(seconds: 2));
        c.next();
        if (c.isDone) break;
      }
      final before = Map.of(progress.cards);
      if (!c.isDone) {
        c.answer(c.current.question!.answerIndex,
            elapsed: const Duration(seconds: 1));
      }
      expect(progress.cards, before);
      expect(progress.cards.values.every((s) => s.box == 0), isTrue);
      expect(progress.cards.values.every((s) => s.isDue(now)), isTrue);
      expect(
          progress.cards.values.every((s) => s.reviews == 1 && s.lapses == 0),
          isTrue);
      expect(c.summary.answered, 6);
      // ReviewOutcome sınıflandırması
      expect(
          review(CardState.fresh('x', now), ReviewOutcome.wrong, now).box, 0);
    });
  });

  test(
      'veliyle etkinlik: "Yaptık" kutu ilerletir, "Şimdi değil" kaydı değiştirmez',
      () async {
    final now = DateTime(2026, 11, 2, 17);
    final progress = ChildProgress();
    final c = await SessionController.build(
      repo: fileRepo(),
      subject: Subject.hayatBilgisi,
      grade: 1,
      progress: progress,
      clock: () => now,
      random: Random(1),
      focusOutcome: 'HB.1.1.1',
    );
    c.completeLesson();
    var sawActivity = false;
    while (!c.isDone) {
      final q = c.current.question!;
      if (q.activity) {
        sawActivity = true;
        c.skip();
        expect(
            progress.cards.containsKey(c.steps[c.index - 1].card!.id), isFalse);
      } else {
        c.answer(q.answerIndex, elapsed: const Duration(seconds: 2));
        c.next();
      }
    }
    expect(sawActivity, isTrue);
    final act = CardDef.fromJson(
        'X', {'id': 'X#1', 'type': 'act', 'prompt': 'Birlikte yapın'});
    expect(act.fixed!.activity, isTrue);
    expect(generate(act, Random(1)).options, ['Yaptık', 'Şimdi değil']);
  });
}
