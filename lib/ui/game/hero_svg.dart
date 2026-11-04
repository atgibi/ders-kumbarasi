/// Kahraman çizimi (Claude Design › Kahraman bileşeni), çalışma anında SVG.
///
/// Tasarımdaki parametreli bileşenin birebir aktarımı: cinsiyet, yol (6),
/// aşama (5), poz, ten, saç biçimi (12) ve rengi, örtü (şapka/başörtüsü),
/// gözlük, tekerlekli sandalye ve yol arkadaşı. Filtreli kenar titremesi
/// Flutter'da çizilemediği için düz çizgi kullanılır.
library;

import 'dart:math' as math;

import '../../game/game_state.dart';
import '../../game/world.dart';

String _hex(int argb) =>
    '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

String _daire(double x, double y, double r) {
  final k = r * 0.5523;
  String f(double v) => v.toStringAsFixed(2);
  return 'M${f(x - r)} ${f(y)}C${f(x - r)} ${f(y - k)} ${f(x - k)} ${f(y - r)} ${f(x)} ${f(y - r)}'
      'C${f(x + k)} ${f(y - r)} ${f(x + r)} ${f(y - k)} ${f(x + r)} ${f(y)}'
      'C${f(x + r)} ${f(y + k)} ${f(x + k)} ${f(y + r)} ${f(x)} ${f(y + r)}'
      'C${f(x - k)} ${f(y + r)} ${f(x - r)} ${f(y + k)} ${f(x - r)} ${f(y)}Z';
}

const _sapka0 = 'M9 21C8 10 32 10 31 21C28 16 12 16 9 21Z';

String _kivir() {
  final b = StringBuffer();
  for (var k = 0; k < 7; k++) {
    final a = math.pi * (1.08 + k * 0.14);
    b.write(_daire(20 + math.cos(a) * 10.5, 21 + math.sin(a) * 10.5, 3.8));
  }
  return b.toString();
}

/// Saç biçimleri: (ad, ön, arka, çizgi) 40×40 yüz kutusunda.
final List<(String, String, String, String)> hairStyles = [
  ('Kısa', _sapka0, '', ''),
  ('Kâkül', 'M8.5 23C7 9 33 9 31.5 23C30 19 29 18 28 17L12 17C11 18 10 19 8.5 23Z', '', ''),
  ('Kıvırcık', _kivir(), '', ''),
  ('Kabarık', 'M10 18C12 12 28 12 30 18C26 15 14 15 10 18Z', _daire(20, 19, 16), ''),
  (
    'İki örgü',
    _sapka0,
    'M9 21C6 26 7 32 9 36C11 36 12 35 12 34C10 30 10 26 11 22ZM31 21C34 26 33 32 31 36C29 36 28 35 28 34C30 30 30 26 29 22Z',
    'M8 27L11 28M8 31L11 32M32 27L29 28M32 31L29 32'
  ),
  ('At kuyruğu', _sapka0, 'M29 14C38 14 39 26 34 34C33 28 32 22 28 18Z', ''),
  ('Topuz', _sapka0, _daire(20, 8, 5), ''),
  ('Uzun düz', _sapka0, 'M8 20C7 9 33 9 32 20L33 37L26 37L27 24L13 24L14 37L7 37Z', ''),
  (
    'Dalgalı',
    _sapka0,
    'M8 20C7 9 33 9 32 20C35 24 31 27 34 31C31 33 28 31 27 29L27 22L13 22L13 29C12 31 9 33 6 31C9 27 5 24 8 20Z',
    ''
  ),
  ('Yandan ayrık', 'M9 22C8 10 32 9 31 20C28 14 20 13 15 16C13 18 11 19 9 22Z', '', ''),
  ('Çok kısa', 'M10 18C12 11 28 11 30 18C27 15 13 15 10 18Z', '', ''),
  ('Taç örgü', _sapka0, '', 'M10 17Q12 14 14 16Q16 13 18 15Q20 12 22 15Q24 13 26 16Q28 14 30 17'),
];

/// Yüz kutusundaki (40×40) yolu 200×220 çizim alanına taşır.
String _t(String s) {
  const cx = 80.0, cy = 62.0, u = 32 / 11;
  var i = 0;
  return s.replaceAllMapped(RegExp(r'-?\d+(\.\d+)?'), (m) {
    final v = double.parse(m.group(0)!);
    final o = (i++ % 2 == 0) ? cx + (v - 20) * u : cy + (v - 22) * u;
    return o.toStringAsFixed(1);
  });
}

/// Saç seçim düğmesinin küçük yüz önizlemesi (40×40).
String hairChipSvg(int style, int skin, int hairColor) {
  final h = hairStyles[style.clamp(0, hairStyles.length - 1)];
  final sac = _hex(hairColors[hairColor.clamp(0, hairColors.length - 1)].toARGB32());
  final ten = _hex(skinTones[skin.clamp(0, skinTones.length - 1)].toARGB32());
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 40 40">'
      '${h.$3.isEmpty ? '' : '<path d="${h.$3}" fill="$sac" stroke="#2B2320" stroke-width="1.2"/>'}'
      '<circle cx="20" cy="22" r="11" fill="$ten" stroke="#2B2320" stroke-width="1.2"/>'
      '<path d="${h.$2}" fill="$sac" stroke="#2B2320" stroke-width="1.2"/>'
      '${h.$4.isEmpty ? '' : '<path d="${h.$4}" fill="none" stroke="#2B2320" stroke-width="1.1"/>'}'
      '<circle cx="16" cy="23" r="1" fill="#2B2320"/><circle cx="24" cy="23" r="1" fill="#2B2320"/>'
      '</svg>';
}

/// Kahramanın tam çizimi (viewBox 200×220).
String heroSvg(HeroLook look,
    {HeroStage stage = HeroStage.cirak,
    bool cheer = false,
    bool companion = true}) {
  final yol = look.heroPath.id;
  final seviye = stage.index;
  final ortu = switch (look.accessory) {
    2 => 'sapka',
    3 => 'basortusu',
    _ => 'yok',
  };
  final gozluk = look.accessory == 1;
  final sandalye = look.chair;
  final h = ortu == 'basortusu'
      ? ('', '', '', '')
      : hairStyles[look.hair.clamp(0, hairStyles.length - 1)];
  final sac = _hex(hairColors[look.hairColor.clamp(0, hairColors.length - 1)].toARGB32());
  final ten = _hex(skinTones[look.skin.clamp(0, skinTones.length - 1)].toARGB32());
  const renkler = {
    'sovalye': '#1F4E79',
    'okcu': '#2F7A5B',
    'bilge': '#6E5A9C',
    'kasif': '#A8552B',
    'usta': '#D9A441',
    'ozan': '#B8432F',
  };
  final renk = renkler[yol] ?? '#C2A878';
  final pelerin = yol == 'ozan' ? '#1F4E79' : '#9E3624';
  final sus = seviye >= 4 ? '#E3A535' : '#EADBC0';
  final tSol = cheer ? 'translate(-2 -94)' : 'translate(0 0)';
  final hayvan = const {
    'sovalye': 'at',
    'okcu': 'tilki',
    'bilge': 'baykus',
    'kasif': 'keci',
    'usta': 'kunduz',
    'ozan': 'serce',
  }[yol];

  final b = StringBuffer()
    ..write('<svg xmlns="http://www.w3.org/2000/svg" viewBox="-4 -4 208 228">')
    ..write('<ellipse cx="104" cy="211" rx="84" ry="6" fill="#2B2320" opacity="0.12"/>')
    ..write('<g stroke="#2B2320" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">');
  void w(bool on, String s) {
    if (on) b.write(s);
  }

  w(seviye >= 2,
      '<path d="M58 102C44 130 40 160 44 186C68 193 92 193 116 186C120 160 116 130 102 102Z" fill="$pelerin"/>');
  w(seviye >= 3,
      '<path d="M46 182C70 188 92 188 114 182" fill="none" stroke="$sus" stroke-width="4" stroke-dasharray="6 4"/>');
  w(ortu == 'basortusu',
      '<path d="M42 66C40 34 62 20 80 20C98 20 120 34 118 66C118 86 110 100 98 108H62C50 100 42 86 42 66Z" fill="#2F7A5B"/>');
  w(yol == 'okcu',
      '<path d="M98 92L114 84L122 118L106 124Z" fill="#8A5A2E"/><path d="M104 88L108 70M110 86L118 70" fill="none"/><circle cx="108" cy="68" r="3.4" fill="#E3A535"/><circle cx="118" cy="68" r="3.4" fill="#E3A535"/>');
  w(sandalye,
      '<g fill="none" stroke-width="3"><path d="M52 124V174H108L114 198M52 124L46 116"/></g>');
  w(!sandalye,
      '<path d="M70 168L68 203M90 168L92 203" fill="none" stroke="#4A3A32" stroke-width="12"/><ellipse cx="66" cy="205" rx="9" ry="5" fill="#2B2320"/><ellipse cx="94" cy="205" rx="9" ry="5" fill="#2B2320"/>');
  w(sandalye,
      '<path d="M70 168L102 170L104 196M86 168L112 172L114 196" fill="none" stroke="#4A3A32" stroke-width="11"/><ellipse cx="108" cy="199" rx="8" ry="4.5" fill="#2B2320"/><ellipse cx="118" cy="199" rx="8" ry="4.5" fill="#2B2320"/>');
  b
    ..write('<path d="M58 100Q80 92 102 100L112 172Q80 180 48 172Z" fill="$renk"/>')
    ..write('<path d="M64 112C70 120 90 120 96 112" fill="none" stroke-width="1.4"/>');
  w(yol == 'usta', '<path d="M64 114H96V170Q80 174 64 170Z" fill="#8A5A2E"/>');
  w(seviye >= 1,
      '<path d="M52 140Q80 147 108 140" fill="none" stroke="#5E3A1B" stroke-width="6"/><path d="M75 139h10v10h-10z" fill="#E3A535" stroke-width="2"/><path d="M62 99Q80 110 98 99L96 108Q80 117 64 108Z" fill="#E3A535"/><path d="M92 107L101 124L92 122Z" fill="#E3A535"/>');
  w(yol == 'kasif',
      '<circle cx="80" cy="124" r="8" fill="#E3A535"/><path d="M80 118L82 124L80 130L78 124Z" fill="#B8432F" stroke-width="1.2"/><path d="M72 110L80 116L88 110" fill="none" stroke-width="1.4"/>');
  w(!cheer,
      '<path d="M60 104C50 112 44 130 46 150L56 150C56 134 60 120 66 112Z" fill="$renk"/><circle cx="51" cy="153" r="6.5" fill="$ten"/>');
  w(cheer,
      '<path d="M62 106C52 96 46 80 44 62L54 60C56 76 62 90 68 100Z" fill="$renk"/><circle cx="49" cy="57" r="6.5" fill="$ten"/>');
  b
    ..write('<path d="M100 104C110 112 116 130 114 150L104 150C104 134 100 120 94 112Z" fill="$renk"/><circle cx="109" cy="153" r="6.5" fill="$ten"/>')
    ..write('<path d="M74 88h12v12h-12z" fill="$ten" stroke="none"/>')
    ..write('<circle cx="48" cy="66" r="6" fill="$ten"/><circle cx="112" cy="66" r="6" fill="$ten"/>');
  w(h.$3.isNotEmpty, '<path d="${_t(h.$3)}" fill="$sac"/>');
  b.write('<circle cx="80" cy="62" r="32" fill="$ten"/>');
  w(h.$2.isNotEmpty, '<path d="${_t(h.$2)}" fill="$sac"/>');
  w(h.$4.isNotEmpty, '<path d="${_t(h.$4)}" fill="none" stroke-width="1.8"/>');
  w(ortu == 'basortusu',
      '<path d="M48 54C54 34 106 34 112 54C100 44 60 44 48 54Z" fill="#2F7A5B"/><path d="M56 46q4 -3 8 0M72 41q4 -3 8 0M88 41q4 -3 8 0" fill="none" stroke="#FBF5E8" stroke-width="1.6"/>');
  w(ortu == 'sapka',
      '<path d="M54 42C56 18 104 18 106 42Z" fill="#1F4E79"/><path d="M40 44Q80 34 120 44Q80 52 40 44Z" fill="#1F4E79"/><path d="M56 36Q80 30 104 36" fill="none" stroke="#E3A535" stroke-width="3"/>');
  w(seviye >= 4 && ortu != 'sapka',
      '<path d="M50 46Q80 38 110 46" fill="none" stroke="#E3A535" stroke-width="4"/><path d="M104 44C104 30 110 20 120 14C120 26 114 36 108 44Z" fill="#2F7A5B"/><circle cx="80" cy="41" r="3.5" fill="#B8432F"/>');
  b.write('<g stroke-width="2"><path d="M64 57q5 -3 9 0M87 57q5 -3 9 0" fill="none"/>'
      '<circle cx="63" cy="76" r="5.5" fill="#B8432F" fill-opacity="0.32" stroke="none"/><circle cx="97" cy="76" r="5.5" fill="#B8432F" fill-opacity="0.32" stroke="none"/>');
  if (cheer) {
    b.write('<path d="M73 79q7 10 14 0Z" fill="#B8432F"/><path d="M63 68q5 -6 10 0M85 68q5 -6 10 0" fill="none" stroke-width="2.6"/>');
  } else {
    b.write('<path d="M74 80q6 5 12 0" fill="none"/>');
  }
  b.write('</g>');
  w(gozluk,
      '<g fill="#FBF5E8" fill-opacity="0.3" stroke-width="2"><circle cx="69" cy="66" r="7.5"/><circle cx="91" cy="66" r="7.5"/><path d="M76.5 65q3.5 -2 7 0" fill="none"/></g>');

  // yol eşyaları
  w(yol == 'sovalye',
      '<g transform="$tSol"><path d="M28 116H58V138C58 152 48 162 43 165C38 162 28 152 28 138Z" fill="#1F4E79"/><circle cx="43" cy="134" r="6" fill="#E3A535" stroke-width="1.8"/><path d="M43 121v4M43 143v4M32 134h4M50 134h4" fill="none" stroke="#E3A535" stroke-width="2"/></g>'
          '<path d="M111 40V196" fill="none" stroke="#8A5A2E" stroke-width="4"/><path d="M113 42H138L131 51L138 60H113Z" fill="#B8432F"/><circle cx="111" cy="37" r="3" fill="#E3A535"/>');
  w(yol == 'okcu',
      '<g transform="$tSol"><path d="M40 106C24 128 24 160 42 182" fill="none" stroke="#8A5A2E" stroke-width="4.5"/><path d="M40 106L42 182" fill="none" stroke="#E3A535" stroke-width="1.6"/></g>');
  w(yol == 'bilge',
      '<g transform="$tSol"><path d="M36 126L58 121L61 146L39 151Z" fill="#B8432F"/><path d="M40 129L57 125M41 133L58 129" fill="none" stroke="#FBF5E8" stroke-width="1.4"/></g>'
          '<path d="M112 44V198" fill="none" stroke="#8A5A2E" stroke-width="4"/><path d="M112 26L119 36L112 46L105 36Z" fill="#E3A535"/><path d="M100 26l-4 -3M124 26l4 -3M112 18v-4" fill="none" stroke="#E3A535" stroke-width="2"/>');
  w(yol == 'kasif',
      '<path d="M104 146L130 132" fill="none" stroke="#EADBC0" stroke-width="9"/><path d="M104 146L130 132" fill="none" stroke-width="1.2" stroke-dasharray="2 3"/><circle cx="130" cy="132" r="4.6" fill="#EADBC0"/>');
  w(yol == 'usta',
      '<path d="M110 156L126 116" fill="none" stroke="#8A5A2E" stroke-width="5"/><path d="M115 109L136 117L132 127L111 119Z" fill="#8C96A0"/>'
          '<g transform="$tSol"><path d="M40 124L52 122L60 168L48 170Z" fill="#D9A441"/><path d="M43 132h4M44 140h5M45 148h4M46 156h5" fill="none" stroke-width="1.4"/></g>');
  w(yol == 'ozan',
      '<path d="M64 142L124 78" fill="none" stroke="#5E3A1B" stroke-width="5"/><ellipse cx="60" cy="150" rx="15" ry="19" transform="rotate(-42 60 150)" fill="#A8723F"/><circle cx="62" cy="148" r="4" fill="#2B2320" stroke="none"/><path d="M118 80l6 4M114 84l6 4M122 76l6 4" fill="none" stroke-width="2"/><path d="M124 78l6 16" fill="none" stroke="#B8432F" stroke-width="3"/>');
  w(sandalye,
      '<g fill="none" stroke-width="3"><circle cx="78" cy="186" r="24"/><circle cx="78" cy="186" r="19" stroke-width="1.6"/><path d="M78 167V205M59 186H97M65 173L91 199M91 173L65 199" stroke-width="1.2"/><circle cx="122" cy="204" r="6"/></g>');

  // yol arkadaşı
  if (companion) {
    w(hayvan == 'at',
        '<path d="M150 180v26M158 184v22M176 184v22M184 180v26" fill="none" stroke-width="4"/><ellipse cx="166" cy="176" rx="25" ry="14" fill="#A8723F"/><path d="M180 170C184 154 190 146 196 144C202 148 200 160 193 163L189 174Z" fill="#A8723F"/><path d="M184 154C180 160 178 166 178 170M188 150C184 156 182 160 182 166" fill="none" stroke="#5E3A1B" stroke-width="3"/><path d="M142 172C132 178 134 192 138 198" fill="none" stroke="#5E3A1B" stroke-width="4"/><circle cx="194" cy="151" r="1.6" fill="#2B2320"/>');
    w(hayvan == 'tilki',
        '<path d="M146 194C130 192 122 174 130 162C136 172 142 180 152 182Z" fill="#C8642E"/><path d="M130 162C125 166 125 172 128 176C132 172 132 166 130 162Z" fill="#FBF5E8" stroke-width="1.6"/><path d="M142 204C140 184 152 174 168 176C180 178 186 188 184 204Z" fill="#C8642E"/><circle cx="184" cy="170" r="11" fill="#C8642E"/><path d="M177 162L178 149L186 159M186 159L194 149L194 164" fill="#C8642E"/><path d="M190 172L201 176L190 180Z" fill="#FBF5E8"/><circle cx="201" cy="176" r="1.8" fill="#2B2320"/><circle cx="187" cy="168" r="1.6" fill="#2B2320"/>');
    w(hayvan == 'baykus',
        '<path d="M150 206C146 184 154 166 166 166C178 166 186 184 182 206Z" fill="#A8723F"/><path d="M156 206C154 192 158 184 166 184C174 184 178 192 176 206Z" fill="#EADBC0" stroke-width="1.6"/><path d="M154 172L151 158L161 167M171 167L181 158L178 172" fill="#A8723F"/><circle cx="160" cy="176" r="5.5" fill="#FBF5E8" stroke-width="1.8"/><circle cx="172" cy="176" r="5.5" fill="#FBF5E8" stroke-width="1.8"/><circle cx="160" cy="177" r="2" fill="#2B2320"/><circle cx="172" cy="177" r="2" fill="#2B2320"/><path d="M164 181L166 186L168 181Z" fill="#E3A535" stroke-width="1.4"/>');
    w(hayvan == 'keci',
        '<path d="M150 184v22M158 186v20M174 186v20M182 184v22" fill="none" stroke-width="3.6"/><ellipse cx="166" cy="180" rx="22" ry="12" fill="#EADBC0"/><path d="M182 176C184 164 190 160 196 162C200 166 198 174 192 178Z" fill="#EADBC0"/><path d="M186 160C182 148 190 140 200 144M190 162C190 152 196 148 202 152" fill="none" stroke-width="3"/><path d="M194 178l-1 8" fill="none" stroke-width="2.4"/><circle cx="193" cy="167" r="1.6" fill="#2B2320"/>');
    w(hayvan == 'kunduz',
        '<path d="M146 200C134 202 128 208 132 212C140 213 146 209 150 206Z" fill="#5E3A1B"/><path d="M146 206C142 186 152 174 166 174C180 174 188 186 186 206Z" fill="#7A4D27"/><path d="M174 188h6v6h-6z" fill="#FBF5E8" stroke-width="1.4"/><circle cx="176" cy="181" r="1.8" fill="#2B2320"/><circle cx="160" cy="176" r="3.4" fill="#7A4D27"/>');
    w(hayvan == 'serce',
        '<path d="M148 186L138 176L144 190Z" fill="#7A4D27"/><ellipse cx="160" cy="192" rx="14" ry="10" fill="#A8723F"/><path d="M152 188C158 184 166 186 168 194C162 196 156 194 152 188Z" fill="#5E3A1B"/><circle cx="172" cy="182" r="7" fill="#A8723F"/><path d="M178 182L185 184L178 186Z" fill="#E3A535"/><circle cx="174" cy="180" r="1.5" fill="#2B2320"/><path d="M156 202v6M164 202v6" fill="none" stroke-width="1.8"/>');
  }
  b.write('</g></svg>');
  return b.toString();
}
