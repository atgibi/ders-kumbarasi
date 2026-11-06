/// Karabulut (Claude Design "Karabulut"): yıl sonu düellosunun bulut devi.
/// Üç hâli var: küs (kollar kavuşturulmuş, sis savuruyor), dost (el
/// sallıyor) ve yağmur (filizlere yağmur yağdırıyor).
///
/// flutter_svg filtre ve desen desteklemediği için tasarımdaki el titremesi
/// filtresi çıkarıldı, tül deseni düz renge çevrildi.
library;

enum KarabulutHal { kus, dost, yagmur }

String karabulutSvg(KarabulutHal hal, {double fog = 1, bool ground = true}) {
  final c = switch (hal) {
    KarabulutHal.kus => (
        govde: '#9AA6B2',
        alt: '#7E8A96',
        sakal: '#B7C0C9',
        burun: '#8C969E'
      ),
    KarabulutHal.dost => (
        govde: '#EEF2F5',
        alt: '#C9D1D9',
        sakal: '#FBF5E8',
        burun: '#E2B9A4'
      ),
    KarabulutHal.yagmur => (
        govde: '#C9D1D9',
        alt: '#9AA6B2',
        sakal: '#EEF2F5',
        burun: '#D9B8A8'
      ),
  };
  final kisa = hal == KarabulutHal.yagmur;
  final sakal = kisa
      ? 'M88 100C86 116 98 128 104 132C108 128 114 136 120 134C126 136 132 128 136 132C142 128 154 116 152 100Z'
      : 'M86 100C80 124 92 146 100 152C104 148 110 160 120 162C130 160 136 148 140 152C148 146 160 124 154 100Z';
  final biyik = hal == KarabulutHal.dost
      ? 'M120 100C108 94 96 100 86 92C86 106 108 110 120 104C132 110 154 106 154 92C144 100 132 94 120 100Z'
      : 'M120 98C108 96 96 100 88 114C100 106 112 106 120 104C128 106 140 106 152 114C144 100 132 96 120 98Z';
  final rain = StringBuffer();
  if (kisa) {
    for (var i = 0; i < 9; i++) {
      final x = 52 + i * 17, y0 = 126 + (i % 3) * 14;
      rain.write('M$x ${y0}l-3 10M${x - 6} ${y0 + 22}l-3 10');
    }
  }
  final f = fog.clamp(0.0, 1.0).toStringAsFixed(2);
  const ink = '#2B2320';
  final b = StringBuffer()
    ..write('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 240 200">')
    ..write('<g stroke="$ink" stroke-width="2.4" stroke-linecap="round" '
        'stroke-linejoin="round">');
  if (kisa) {
    b.write('<path d="$rain" fill="none" stroke="#1F4E79" stroke-width="2.4"/>');
    if (ground) {
      b
        ..write('<path d="M18 190C60 184 100 194 140 188C170 184 200 192 224 188" '
            'fill="none" stroke="#8A6A4A" stroke-width="3"/>')
        ..write('<path d="M76 189V172M120 189V168M164 189V173" fill="none" '
            'stroke="#2F7A5B" stroke-width="2.6"/>')
        ..write('<path d="M76 176C66 176 62 168 66 164C74 164 77 170 76 176Z'
            'M76 174C84 172 88 164 84 160C78 162 75 168 76 174Z'
            'M120 172C110 172 106 162 110 158C118 158 121 166 120 172Z'
            'M120 170C130 168 134 158 130 154C122 156 119 164 120 170Z'
            'M164 177C155 177 152 170 155 166C162 166 165 172 164 177Z'
            'M164 175C172 173 175 166 172 162C166 164 163 170 164 175Z" '
            'fill="#2F7A5B" stroke-width="1.6"/>');
    }
  }
  if (hal == KarabulutHal.kus) {
    b.write('<g fill="#C9D1D9" stroke="#9AA6B2" stroke-width="1.6" '
        'opacity="$f">'
        '<path d="M4 62c8 -9 24 -8 32 0c-9 7 -22 7 -32 0Z"/>'
        '<path d="M204 34c8 -8 22 -7 30 0c-8 7 -21 7 -30 0Z"/>'
        '<path d="M196 158c9 -9 26 -8 36 0c-10 8 -25 8 -36 0Z"/>'
        '<path d="M8 150c8 -8 22 -7 30 0c-8 7 -21 7 -30 0Z"/>'
        '</g>');
  }
  if (hal == KarabulutHal.dost) {
    b
      ..write('<path d="M48 104C30 98 18 82 16 66L30 62C33 78 42 88 56 94Z" '
          'fill="${c.govde}"/>')
      ..write('<circle cx="22" cy="58" r="10" fill="${c.govde}"/>');
  }
  b
    ..write('<path d="M40 112C18 112 14 84 36 78C30 52 58 38 78 50C86 26 122 20 '
        '136 42C152 26 186 34 184 60C210 60 222 90 202 108C200 120 186 124 176 '
        '120H64C54 124 42 122 40 112Z" fill="${c.govde}"/>')
    ..write('<path d="M42 106C74 116 168 116 204 100C200 116 188 122 176 120H64'
        'C54 123 44 118 42 106Z" fill="${c.alt}" stroke-width="1.4"/>')
    ..write('<path d="M62 54C70 46 80 48 84 54M132 44C140 36 154 38 158 46" '
        'fill="none" stroke-width="1.6"/>')
    ..write('<path d="$sakal" fill="${c.sakal}"/>');
  if (!kisa) {
    b.write('<path d="M104 122C108 132 112 140 120 146M136 122C132 132 128 140 '
        '120 146" fill="none" stroke-width="1.4"/>');
  }
  switch (hal) {
    case KarabulutHal.kus:
      b
        ..write('<path d="M50 108C70 118 120 132 154 128C162 127 164 138 156 141'
            'C120 148 70 136 46 122Z" fill="${c.govde}"/>')
        ..write('<path d="M190 108C170 118 120 132 86 128C78 127 76 138 84 141'
            'C120 148 170 136 194 122Z" fill="${c.govde}"/>')
        ..write('<circle cx="160" cy="134" r="8" fill="${c.govde}"/>')
        ..write('<circle cx="80" cy="134" r="8" fill="${c.govde}"/>')
        ..write('<path d="M88 70L110 77M152 70L130 77" fill="none" '
            'stroke-width="4.4"/>')
        ..write('<path d="M94 82h14M132 82h14" fill="none" stroke-width="2"/>')
        ..write('<circle cx="101" cy="85" r="2.6" fill="$ink" stroke="none"/>')
        ..write('<circle cx="139" cy="85" r="2.6" fill="$ink" stroke="none"/>');
    case KarabulutHal.dost:
      b
        ..write('<path d="M88 70Q99 61 110 69M130 69Q141 61 152 70" fill="none" '
            'stroke-width="4"/>')
        ..write('<path d="M94 85Q101 78 108 85M132 85Q139 78 146 85" '
            'fill="none" stroke-width="2.4"/>')
        ..write('<circle cx="88" cy="94" r="6" fill="#B8432F" '
            'fill-opacity="0.22" stroke="none"/>')
        ..write('<circle cx="152" cy="94" r="6" fill="#B8432F" '
            'fill-opacity="0.22" stroke="none"/>')
        ..write('<circle cx="200" cy="114" r="9" fill="${c.govde}"/>');
    case KarabulutHal.yagmur:
      b
        ..write('<path d="M88 70Q99 66 110 71M130 71Q141 66 152 70" fill="none" '
            'stroke-width="3.6"/>')
        ..write('<circle cx="101" cy="83" r="2.8" fill="$ink" stroke="none"/>')
        ..write('<circle cx="139" cy="83" r="2.8" fill="$ink" stroke="none"/>')
        ..write('<ellipse cx="120" cy="112" rx="4" ry="5" fill="$ink"/>')
        ..write('<path d="M218 122v18M218 122q7 2 9 9" fill="none" '
            'stroke="#1F4E79" stroke-width="2"/>')
        ..write('<ellipse cx="214" cy="141" rx="5" ry="3.6" fill="#1F4E79" '
            'stroke-width="1.4"/>');
  }
  b
    ..write('<ellipse cx="120" cy="93" rx="10" ry="8" fill="${c.burun}"/>')
    ..write('<path d="$biyik" fill="${c.sakal}"/>')
    ..write('</g></svg>');
  return b.toString();
}
