import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:ders_kumbarasi/main.dart';

void main() {
  testWidgets('Uygulama açılır ve başlığı gösterir', (tester) async {
    await tester.pumpWidget(const DersKumbarasiApp());
    expect(find.byKey(const Key('app-title')), findsOneWidget);
    expect(find.text('Ders Kumbarası'), findsOneWidget);
  });
}
