import 'package:flutter_test/flutter_test.dart';

import 'package:ders_kumbarasi/app/speaker.dart';

void main() {
  test('ses kimliği Python aracıyla aynı (tools/audio/speech.py)', () {
    expect(speechId('Merhaba'), '95b5adf1131ceeeb');
    expect(speechId('Harika!'), '5f20b666bd361c98');
    expect(speechId('Çok mu az mı? ğüşıöç'), '047d479d50d1cfe7');
    expect(speechId('  Merhaba  '), speechId('Merhaba'));
  });
}
