/// Bekçi çizimleri (Claude Design › Taş Golem ve Bekçi bileşenleri).
///
/// Zırhlı hâlde sis zırhı 8 parçadır; doğru cevapta bir parça düşer.
/// [fallen] doğruysa düşen parçalar bekçinin ayak dibinde durur.
library;

import 'dart:math' as math;

/// Tasarımda çizimi olan bekçiler.
const drawnGuardians = {'golem', 'sarmasik', 'ejder', 'tepegoz', 'ayi'};

String _pieces(List<(String, double, double)> parts,
    List<(double, double, double)> yer, int remaining, bool fallen,
    {String extra0 = ''}) {
  final b = StringBuffer();
  // ters sırada çiz: 0 (kask) en üstte
  for (var i = parts.length - 1; i >= 0; i--) {
    final (d, cx, cy) = parts[i];
    String tr;
    if (i < remaining) {
      tr = '';
    } else if (!fallen) {
      continue;
    } else {
      final (x, y, r) = yer[i];
      tr =
          ' transform="translate($x $y) rotate($r) scale(0.78) translate(${-cx} ${-cy})"';
    }
    b.write('<g$tr><path d="$d" fill="#9AA6B2"/>'
        '<path d="$d" fill="#C9D1D9" fill-opacity="0.35" stroke="none"/>');
    if (i == 0 && i < remaining && extra0.isNotEmpty) b.write(extra0);
    b.write('</g>');
  }
  return b.toString();
}

const _sisKivrim =
    '<g fill="none" stroke="#9AA6B2" stroke-width="3"><path d="M24 90c-9 -6 -4 -17 6 -15M176 84c9 -6 4 -17 -6 -15M34 196c-11 0 -14 -9 -8 -15M166 196c11 0 14 -9 8 -15"/></g>';

/// Bekçinin SVG'si. [armored] yanlışsa kurtarılmış, sevimli hâli.
String guardianSvg(String id,
    {bool armored = false, int remaining = 8, bool fallen = true}) {
  final k = armored ? remaining.clamp(0, 8) : 0;
  if (id == 'golem') return _golem(armored, k, fallen);
  return _bekci(id, armored, k, fallen);
}

String _golem(bool armored, int k, bool fallen) {
  const parts = [
    ('M90 64C86 40 100 28 120 28C140 28 154 40 150 64L146 70H94Z', 120.0, 50.0),
    (
      'M78 100C90 88 150 88 162 100L156 150C140 160 100 160 84 150Z',
      120.0,
      124.0
    ),
    ('M48 100C52 86 70 82 82 92L76 116C64 116 52 112 48 100Z', 65.0, 102.0),
    (
      'M192 100C188 86 170 82 158 92L164 116C176 116 188 112 192 100Z',
      175.0,
      102.0
    ),
    ('M32 134C34 124 52 122 64 130L62 166C52 170 38 166 34 156Z', 48.0, 146.0),
    (
      'M208 134C206 124 188 122 176 130L178 166C188 170 202 166 206 156Z',
      192.0,
      146.0
    ),
    ('M80 206H114L112 236H84Z', 97.0, 221.0),
    ('M126 206H160L156 236H128Z', 143.0, 221.0),
  ];
  const yer = [
    (206.0, 244.0, 24.0),
    (40.0, 244.0, -14.0),
    (86.0, 252.0, 38.0),
    (170.0, 252.0, -30.0),
    (18.0, 250.0, 70.0),
    (224.0, 250.0, -64.0),
    (126.0, 254.0, 12.0),
    (152.0, 256.0, -20.0),
  ];
  final b = StringBuffer(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="-6 -6 252 272">'
      '<ellipse cx="120" cy="248" rx="104" ry="8" fill="#2B2320" opacity="0.12"/>'
      '<g stroke="#2B2320" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round">'
      '<path d="M82 198C80 220 82 236 86 246H112C114 232 114 214 112 198Z" fill="#978E7E"/>'
      '<path d="M158 198C160 220 158 236 154 246H128C126 232 126 214 128 198Z" fill="#978E7E"/>'
      '<path d="M60 104C40 108 30 132 34 160C36 178 46 186 58 184C66 170 66 140 66 116Z" fill="#A39A8A"/>'
      '<path d="M180 104C200 108 210 132 206 160C204 178 194 186 182 184C174 170 174 140 174 116Z" fill="#A39A8A"/>'
      '<circle cx="47" cy="186" r="14" fill="#978E7E"/><circle cx="193" cy="186" r="14" fill="#978E7E"/>'
      '<path d="M60 112C56 84 82 66 120 66C158 66 184 84 180 112C184 150 172 196 150 204H90C68 196 56 150 60 112Z" fill="#A39A8A"/>'
      '<path d="M84 120C80 100 96 90 108 94C112 104 100 124 84 120ZM146 168C152 156 166 158 166 170C160 180 148 178 146 168Z" fill="#BDB4A3" stroke="none"/>'
      '<path d="M94 72C90 48 102 34 120 34C138 34 150 48 146 72C140 80 100 80 94 72Z" fill="#A39A8A"/>'
      '<path d="M90 100l10 8l-4 10M140 130l12 -6l6 10M104 160l-8 12M150 86l8 6M40 140l8 4M196 150l-8 6M100 220l6 8M136 214l8 -4" fill="none" stroke-width="1.6"/>');
  if (!armored || k == 0) {
    b.write(
        '<path d="M94 50C98 32 142 32 146 50C136 42 104 42 94 50Z" fill="#5E7A3A"/>'
        '<path d="M62 100C70 88 84 86 90 92C82 96 72 100 62 100ZM178 100C170 88 156 86 150 92C158 96 168 100 178 100ZM36 150C40 140 50 140 54 146C48 148 42 150 36 150Z" fill="#5E7A3A" stroke-width="1.8"/>'
        '<path d="M128 36l-5 -6M128 36l6 -5M128 36l-1 -8M128 36l7 2" fill="none" stroke="#B8432F" stroke-width="3"/>'
        '<circle cx="128" cy="36" r="3.6" fill="#E3A535" stroke-width="1.6"/>'
        '<path d="M104 57q6 -6 12 0M124 57q6 -6 12 0" fill="none" stroke-width="2.8"/>'
        '<circle cx="100" cy="66" r="5" fill="#B8432F" fill-opacity="0.3" stroke="none"/><circle cx="140" cy="66" r="5" fill="#B8432F" fill-opacity="0.3" stroke="none"/>'
        '<path d="M110 66q10 8 20 0" fill="none" stroke-width="2.4"/>');
  }
  if (armored) {
    b.write(_pieces(parts, yer, k, fallen,
        extra0:
            '<path d="M104 56h10M126 56h10" fill="none" stroke="#EEF2F5" stroke-width="3.4"/>'));
    if (k > 0) {
      b.write(
          '<g fill="none" stroke="#9AA6B2" stroke-width="3"><path d="M28 88c-9 -6 -4 -17 6 -15M212 82c9 -6 4 -17 -6 -15M56 216c-11 0 -14 -9 -8 -15M186 220c11 0 14 -9 8 -15M120 18c-6 -8 4 -14 10 -8"/></g>');
    }
  }
  b.write('</g></svg>');
  return b.toString();
}

String _bekci(String id, bool armored, int k, bool fallen) {
  final z = armored;
  final b = StringBuffer(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="-6 -6 212 232">'
      '<ellipse cx="100" cy="213" rx="72" ry="6" fill="#2B2320" opacity="0.12"/>'
      '<g stroke="#2B2320" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">');
  final List<(String, double, double)> parts;
  final String yarik;
  switch (id) {
    case 'sarmasik':
      final c = z
          ? ('#8C969E', '#6B7480', '#B7C0C9', '#B7C0C9', '#C9D1D9')
          : ('#5E7A3A', '#3E5A2C', '#7E9A55', '#D98C7A', '#F2D492');
      final (govde, koyu, yaprak, petal, yuz) = c;
      final tac = StringBuffer();
      for (var i = 0; i < 8; i++) {
        final a = i / 8 * math.pi * 2;
        String p(double r, double d) =>
            '${(100 + math.cos(a + d) * r).toStringAsFixed(1)} ${(72 + math.sin(a + d) * r).toStringAsFixed(1)}';
        tac.write(
            'M${p(12, 0)}Q${p(26, -0.42)} ${p(32, 0)}Q${p(26, 0.42)} ${p(12, 0)}Z');
      }
      b.write(
          '<path d="M62 210C50 206 42 210 32 214M138 210C150 206 158 210 168 214M100 210V217" fill="none" stroke="$koyu" stroke-width="5"/>'
          '<path d="M62 210C54 172 60 130 84 104H116C140 130 146 172 138 210Z" fill="$govde"/>'
          '<path d="M74 200C70 170 90 160 86 140C82 124 98 116 96 106M126 200C130 170 112 158 116 138C120 124 106 116 106 106" fill="none" stroke="$koyu" stroke-width="3"/>'
          '<path d="M70 160C60 152 62 140 72 138C76 148 74 154 70 160ZM132 176C142 168 140 156 130 154C126 164 128 170 132 176ZM96 186C90 176 96 166 104 168C104 178 100 182 96 186Z" fill="$yaprak" stroke-width="1.6"/>'
          '<path d="M70 132C46 128 34 108 40 92C44 102 52 110 64 114M130 132C154 128 166 108 160 92C156 102 148 110 136 114" fill="none" stroke="$govde" stroke-width="9"/>'
          '<path d="M40 92c-6 -6 0 -14 6 -10M160 92c6 -6 0 -14 -6 -10" fill="none" stroke-width="2"/>'
          '<path d="M56 124l-5 -7l8 2ZM144 124l5 -7l-8 2ZM66 176l-8 -2l6 -5ZM134 176l8 -2l-6 -5ZM48 104l-7 -3l6 -4ZM152 104l7 -3l-6 -4Z" fill="$koyu" stroke-width="1.4"/>'
          '<path d="$tac" fill="$petal" stroke-width="1.8"/>'
          '<circle cx="100" cy="72" r="16" fill="$yuz"/>');
      if (!z || k == 0) {
        b.write(
            '<circle cx="93" cy="70" r="2.6" fill="#2B2320" stroke="none"/><circle cx="107" cy="70" r="2.6" fill="#2B2320" stroke="none"/><path d="M94 78q6 5 12 0" fill="none" stroke-width="2"/><circle cx="89" cy="77" r="3.4" fill="#B8432F" fill-opacity="0.35" stroke="none"/><circle cx="111" cy="77" r="3.4" fill="#B8432F" fill-opacity="0.35" stroke="none"/>');
      }
      parts = const [
        ('M74 82C70 56 84 40 100 40C116 40 130 56 126 82Z', 100.0, 62.0),
        ('M78 52L70 34L88 46Z', 79.0, 44.0),
        ('M100 40L100 20L108 38Z', 103.0, 33.0),
        ('M122 52L130 34L112 46Z', 121.0, 44.0),
        (
          'M78 120C90 112 110 112 122 120L118 160C108 166 92 166 82 160Z',
          100.0,
          140.0
        ),
        ('M42 100l14 -5l6 14l-14 5Z', 52.0, 107.0),
        ('M158 100l-14 -5l-6 14l14 5Z', 148.0, 107.0),
        ('M84 186C94 182 106 182 116 186L114 204H86Z', 100.0, 194.0),
      ];
      yarik = 'M88 66h24';
    case 'ejder':
      final c = z
          ? ('#9AA6B2', '#C9D1D9', '#7E8A96', '#B7C0C9')
          : ('#C8642E', '#F2D492', '#B8432F', '#E3A535');
      final (govde, karin, kanat, boynuz) = c;
      b.write(
          '<path d="M140 196C166 196 178 180 172 164C184 168 188 184 178 196C170 206 152 208 140 204Z" fill="$govde"/>'
          '<path d="M172 164l5 -13l8 11Z" fill="$boynuz" stroke-width="1.8"/>'
          '<path d="M66 132C40 116 30 90 42 78C48 96 60 108 72 116ZM134 132C160 116 170 90 158 78C152 96 140 108 128 116Z" fill="$kanat"/>'
          '<path d="M44 86L64 118M156 86L136 118" fill="none" stroke-width="1.4"/>'
          '<path d="M60 210h24v6h-26zM116 210h24l2 6h-26z" fill="$govde"/>'
          '<path d="M58 210C46 172 62 126 100 124C138 126 154 172 142 210Z" fill="$govde"/>'
          '<path d="M80 210C76 182 84 150 100 148C116 150 124 182 120 210Z" fill="$karin"/>'
          '<path d="M84 168h32M82 184h36M82 198h36" fill="none" stroke-width="1.4"/>'
          '<path d="M66 160C56 164 54 172 58 178M134 160C144 164 146 172 142 178" fill="none" stroke="$govde" stroke-width="10"/>'
          '<path d="M74 56L66 32L86 50ZM126 56L134 32L114 50Z" fill="$boynuz"/>'
          '<path d="M100 48C130 48 146 70 144 94C142 116 122 128 100 128C78 128 58 116 56 94C54 70 70 48 100 48Z" fill="$govde"/>'
          '<path d="M90 50l10 -12l10 12" fill="$kanat"/>'
          '<path d="M78 102C78 90 122 90 122 102C122 116 78 116 78 102Z" fill="$karin"/>'
          '<circle cx="92" cy="100" r="2" fill="#2B2320" stroke="none"/><circle cx="108" cy="100" r="2" fill="#2B2320" stroke="none"/>');
      if (!z || k == 0) {
        b.write(
            '<circle cx="84" cy="78" r="4" fill="#2B2320" stroke="none"/><circle cx="116" cy="78" r="4" fill="#2B2320" stroke="none"/><path d="M76 66l12 -4M124 66l-12 -4" fill="none" stroke-width="2.4"/><path d="M92 118q4 -4 8 0q4 4 8 0" fill="none" stroke-width="2"/>');
      }
      parts = const [
        ('M62 92C58 60 76 44 100 44C124 44 142 60 138 92Z', 100.0, 68.0),
        ('M70 58L64 36L82 50Z', 72.0, 48.0),
        ('M130 58L136 36L118 50Z', 128.0, 48.0),
        (
          'M70 150C86 140 114 140 130 150L126 190C112 198 88 198 74 190Z',
          100.0,
          170.0
        ),
        ('M42 82l20 10l-4 16l-18 -10Z', 50.0, 96.0),
        ('M158 82l-20 10l4 16l18 -10Z', 150.0, 96.0),
        ('M150 192l16 -8l6 12l-16 8Z', 161.0, 196.0),
        ('M60 196h24v12h-24Z', 72.0, 202.0),
      ];
      yarik = 'M80 78h40';
    case 'tepegoz':
      final c = z
          ? ('#B7C0C9', '#8C969E', '#6B7480', '#C9D1D9', '#6B7480')
          : ('#D9B48C', '#6E5A9C', '#5E3A1B', '#B7A9D6', '#3B2418');
      final (ten, tunik, kemer, kristal, sac) = c;
      b.write(
          '<path d="M78 212V194M122 212V194" fill="none" stroke="$ten" stroke-width="14"/>'
          '<ellipse cx="76" cy="212" rx="13" ry="5" fill="#2B2320"/><ellipse cx="124" cy="212" rx="13" ry="5" fill="#2B2320"/>'
          '<path d="M62 204C58 176 66 150 100 146C134 150 142 176 138 204Z" fill="$tunik"/>'
          '<path d="M64 184Q100 192 136 184" fill="none" stroke="$kemer" stroke-width="6"/>'
          '<path d="M66 160C52 170 48 184 52 194" fill="none" stroke="$tunik" stroke-width="13"/>'
          '<circle cx="52" cy="198" r="8" fill="$ten"/>'
          '<path d="M134 160C150 158 158 146 160 136" fill="none" stroke="$tunik" stroke-width="13"/>'
          '<circle cx="160" cy="132" r="8" fill="$ten"/>'
          '<path d="M152 124L160 100L168 124L160 130Z" fill="$kristal"/>'
          '<circle cx="50" cy="96" r="9" fill="$ten"/><circle cx="150" cy="96" r="9" fill="$ten"/>'
          '<circle cx="100" cy="92" r="50" fill="$ten"/>'
          '<path d="M84 46C88 32 100 28 108 36C112 28 122 32 120 44C112 40 94 40 84 46Z" fill="$sac"/>');
      if (!z || k == 0) {
        b.write(
            '<ellipse cx="100" cy="84" rx="15" ry="12" fill="#FBF5E8"/><circle cx="102" cy="86" r="5" fill="#2B2320" stroke="none"/><path d="M84 80Q100 68 116 80" fill="none" stroke-width="2.4"/><path d="M82 66Q100 58 118 66" fill="none" stroke="$sac" stroke-width="5"/><path d="M96 102q4 6 8 0" fill="none" stroke-width="2"/><path d="M84 114q16 12 32 0" fill="none" stroke-width="2.4"/>');
      }
      parts = const [
        ('M52 90C50 50 72 36 100 36C128 36 150 50 148 90Z', 100.0, 62.0),
        ('M92 38L100 22L108 38Z', 100.0, 32.0),
        ('M38 84l12 -6l6 16l-12 4Z', 47.0, 90.0),
        ('M162 84l-12 -6l-6 16l12 4Z', 153.0, 90.0),
        ('M74 160C90 152 110 152 126 160L122 196H78Z', 100.0, 176.0),
        ('M60 154l-18 12l8 16l20 -10Z', 56.0, 166.0),
        ('M140 154l18 12l-8 16l-20 -10Z', 144.0, 166.0),
        ('M150 120l16 -2l2 14l-16 2Z', 159.0, 127.0),
      ];
      yarik = 'M84 78h32';
    default: // ayi
      final c = z
          ? ('#C9D1D9', '#B7C0C9', '#9AA6B2')
          : ('#F4EAD5', '#E4D7BE', '#2E7D8A');
      final (kurk, golge, atki) = c;
      b.write(
          '<path d="M48 210C38 172 56 128 100 126C144 128 162 172 152 210Z" fill="$kurk"/>'
          '<path d="M76 210C72 186 82 160 100 158C118 160 128 186 124 210Z" fill="$golge" stroke-width="1.6"/>'
          '<ellipse cx="72" cy="210" rx="17" ry="8" fill="$kurk"/><ellipse cx="128" cy="210" rx="17" ry="8" fill="$kurk"/>'
          '<path d="M58 160C46 172 44 188 52 196M142 160C154 172 156 188 148 196" fill="none" stroke="$kurk" stroke-width="16"/>'
          '<ellipse cx="52" cy="198" rx="10" ry="8" fill="$kurk"/><ellipse cx="148" cy="198" rx="10" ry="8" fill="$kurk"/>'
          '<path d="M47 202v-4M52 203v-5M57 202v-4M143 202v-4M148 203v-5M153 202v-4" fill="none" stroke-width="1.4"/>'
          '<circle cx="68" cy="60" r="13" fill="$kurk"/><circle cx="132" cy="60" r="13" fill="$kurk"/>'
          '<circle cx="68" cy="60" r="6" fill="$golge" stroke-width="1.4"/><circle cx="132" cy="60" r="6" fill="$golge" stroke-width="1.4"/>'
          '<path d="M100 52C130 52 146 72 144 96C142 118 122 130 100 130C78 130 58 118 56 96C54 72 70 52 100 52Z" fill="$kurk"/>'
          '<ellipse cx="100" cy="106" rx="18" ry="13" fill="$golge"/>'
          '<path d="M92 100h16l-8 8Z" fill="#2B2320"/>'
          '<path d="M64 128Q100 142 136 128L134 140Q100 154 66 140Z" fill="$atki"/>'
          '<path d="M120 140L132 176L118 172Z" fill="$atki"/>'
          '<path d="M72 136l6 4l6 -4l6 4l6 -4l6 4l6 -4l6 4l6 -4l6 4" fill="none" stroke="#EADBC0" stroke-width="1.6"/>');
      if (!z || k == 0) {
        b.write(
            '<circle cx="86" cy="88" r="3.2" fill="#2B2320" stroke="none"/><circle cx="114" cy="88" r="3.2" fill="#2B2320" stroke="none"/><path d="M94 116q6 5 12 0" fill="none" stroke-width="2"/><circle cx="76" cy="100" r="5" fill="#B8432F" fill-opacity="0.25" stroke="none"/><circle cx="124" cy="100" r="5" fill="#B8432F" fill-opacity="0.25" stroke="none"/>');
      }
      parts = const [
        (
          'M60 92C56 62 74 46 100 46C126 46 144 62 140 92L134 100L128 92L122 102L116 92L110 100L104 92L98 102L92 92L86 100L80 92L74 102L68 92Z',
          100.0,
          72.0
        ),
        ('M56 64l12 -16l12 16Z', 68.0, 58.0),
        ('M120 64l12 -16l12 16Z', 132.0, 58.0),
        (
          'M66 148C86 138 114 138 134 148L130 192C112 200 88 200 70 192Z',
          100.0,
          170.0
        ),
        ('M38 168l14 -8l8 14l-14 8Z', 48.0, 170.0),
        ('M162 168l-14 -8l-8 14l14 8Z', 152.0, 170.0),
        ('M56 204h30v10h-30Z', 71.0, 209.0),
        ('M114 204h30v10h-30Z', 129.0, 209.0),
      ];
      yarik = 'M82 78h36';
  }
  if (z) {
    if (k > 0) b.write(_sisKivrim);
    const yer = [
      (150.0, 206.0, 20.0),
      (36.0, 208.0, -30.0),
      (124.0, 210.0, 40.0),
      (66.0, 210.0, -20.0),
      (172.0, 204.0, 10.0),
      (20.0, 206.0, 60.0),
      (188.0, 208.0, -50.0),
      (96.0, 212.0, 12.0),
    ];
    b.write(_pieces(parts, yer, k, fallen,
        extra0:
            '<path d="$yarik" fill="none" stroke="#EEF2F5" stroke-width="3.6"/>'));
  }
  b.write('</g></svg>');
  return b.toString();
}
