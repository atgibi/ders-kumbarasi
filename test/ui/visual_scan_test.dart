// Bütün içerikteki görseller (sabit kartlar, üreteçler, konu anlatımları)
// telefon genişliğinde çizilir; taşma ya da hata veren görseller raporlanır.
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ders_kumbarasi/data/content_repository.dart';
import 'package:ders_kumbarasi/data/generators.dart';
import 'package:ders_kumbarasi/data/models.dart';
import 'package:ders_kumbarasi/ui/widgets/visual_view.dart';

void main() {
  testWidgets('her görsel telefon genişliğine sığar', (t) async {
    t.view.physicalSize = const Size(1170, 2532);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final repo = ContentRepository((p) => File(p).readAsString());
    final visuals = <String, Visual>{};
    final pending = <Future<void>>[];
    Future<void> collect() async {
      for (final s in Subject.values) {
        for (final g in s.grades) {
          final pack = await repo.contentFor(s, g);
          for (final oc in pack.values) {
            for (final l in oc.lessons) {
              for (final p in l.pages) {
                final v = p.visual;
                if (v != null) visuals['${oc.outcomeCode} anlatım'] ??= v;
              }
            }
            for (final c in oc.cards) {
              for (var seed = 0; seed < (c.fixed == null ? 4 : 1); seed++) {
                final v = generate(c, Random(seed)).visual;
                if (v != null) visuals['${c.id}#$seed'] = v;
              }
            }
          }
        }
      }
    }

    pending.add(collect());
    await t.runAsync(() => Future.wait(pending));
    expect(visuals, isNotEmpty);

    final problems = <String>[];
    for (final e in visuals.entries) {
      await t.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: VisualView(e.value),
          ),
        ),
      ));
      await t.pump();
      final ex = t.takeException();
      if (ex != null) {
        final msg = '$ex'.split('\n').first;
        problems.add('${e.key} (${e.value.kind}): $msg');
      }
    }
    expect(problems, isEmpty,
        reason: '${problems.length} görsel sorunu:\n'
            '${problems.take(60).join('\n')}');
  });
}
