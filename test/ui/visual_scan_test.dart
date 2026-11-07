// Bütün içerikteki görseller (sabit kartlar, üreteçler, konu anlatımları)
// telefon genişliğinde çizilir; taşma ya da hata veren görseller raporlanır.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ders_kumbarasi/data/content_repository.dart';
import 'package:ders_kumbarasi/data/generators.dart';
import 'package:ders_kumbarasi/data/models.dart';
import 'package:ders_kumbarasi/ui/widgets/visual_view.dart';

void main() {
  testWidgets('her görsel telefon genişliğine sığar',
      timeout: const Timeout(Duration(minutes: 9)), (t) async {
    t.view.physicalSize = const Size(1170, 2532);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final repo = ContentRepository((p) => File(p).readAsString());
    // Aynı görsel (tür + parametreler) bir kez çizilir
    final visuals = <String, Visual>{};
    final seenSig = <String>{};
    void add(String where, Visual v) {
      if (seenSig.add('${v.kind}|${jsonEncode(v.params)}')) visuals[where] = v;
    }

    Future<void> collect() async {
      for (final s in Subject.values) {
        for (final g in s.grades) {
          final pack = await repo.contentFor(s, g);
          for (final oc in pack.values) {
            for (final l in oc.lessons) {
              for (final p in l.pages) {
                final v = p.visual;
                if (v != null) add('${oc.outcomeCode} anlatım', v);
              }
            }
            for (final c in oc.cards) {
              for (var seed = 0; seed < (c.fixed == null ? 2 : 1); seed++) {
                final v = generate(c, Random(seed)).visual;
                if (v != null) add(c.id, v);
              }
            }
          }
        }
      }
    }

    // Dosya okuma gerçek zamanda yapılmalı (sahte saatte takılır)
    await t.runAsync(collect);
    expect(visuals, isNotEmpty);
    debugPrint('Taranan farklı görsel: ${visuals.length}');

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
      if (problems.length > 60) break;
    }
    expect(problems, isEmpty,
        reason: '${problems.length} görsel sorunu:\n'
            '${problems.take(60).join('\n')}');
  });
}
