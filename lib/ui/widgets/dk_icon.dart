import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Uygulamanın simge seti (Lucide çizgi simgeleri, kalın çizgi; MIT/ISC).
/// Tasarım paketindeki dk-icons.js ile aynı yollar.
enum DkIcons {
  x,
  flame,
  volume,
  bulb,
  left,
  right,
  down,
  lock,
  star,
  check,
  play,
  again,
  map,
  user,
  users,
  leaf,
  clock,
  moon,
  book,
  blocks,
  house,
  search,
  globe,
  sliders,
  shield,
  hourglass,
  turtle,
  plus,
  trash,
  download,
  upload,
  info,
  back,
  del,
  logout,
  file,
  sprout,
  tree,
  seed,
  family,
  calendar,
  chart,
  type,
  nut,
  pencil,
}

const _f = 'fill="currentColor" stroke="none"';

const Map<DkIcons, String> _paths = {
  DkIcons.x: '<path d="M18 6 6 18"/><path d="m6 6 12 12"/>',
  DkIcons.volume:
      '<path d="M11 5 6 9H2v6h4l5 4z" fill="currentColor"/><path d="M15.54 8.46a5 5 0 0 1 0 7.07"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14"/>',
  DkIcons.bulb:
      '<path d="M15 14c.2-1 .7-1.7 1.5-2.5 1-.9 1.5-2.2 1.5-3.5A6 6 0 0 0 6 8c0 1 .2 2.2 1.5 3.5.7.7 1.3 1.5 1.5 2.5"/><path d="M9 18h6"/><path d="M10 22h4"/>',
  DkIcons.left: '<path d="m15 18-6-6 6-6"/>',
  DkIcons.right: '<path d="m9 18 6-6-6-6"/>',
  DkIcons.down: '<path d="m6 9 6 6 6-6"/>',
  DkIcons.lock:
      '<rect x="4" y="11" width="16" height="10" rx="2.5" fill="currentColor"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/>',
  DkIcons.star:
      '<path $_f d="M12 2.5l2.9 6 6.6.9-4.8 4.6 1.2 6.5L12 17.4l-5.9 3.1 1.2-6.5L2.5 9.4l6.6-.9z" stroke-linejoin="round"/>',
  DkIcons.check: '<path d="M20 6 9 17l-5-5"/>',
  DkIcons.play:
      '<path $_f d="M7 4.5v15a1 1 0 0 0 1.5.86l12-7.5a1 1 0 0 0 0-1.72l-12-7.5A1 1 0 0 0 7 4.5z"/>',
  DkIcons.again:
      '<path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/><path d="M3 3v5h5"/>',
  DkIcons.map:
      '<path d="M14.1 5.55a2 2 0 0 0 1.8 0l3.66-1.83A1 1 0 0 1 21 4.62v12.76a1 1 0 0 1-.55.9l-4.55 2.27a2 2 0 0 1-1.8 0l-4.2-2.1a2 2 0 0 0-1.8 0l-3.66 1.83A1 1 0 0 1 3 19.38V6.62a1 1 0 0 1 .55-.9L8.1 3.45a2 2 0 0 1 1.8 0z"/><path d="M15 5.76v15"/><path d="M9 3.24v15"/>',
  DkIcons.user:
      '<path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>',
  DkIcons.users:
      '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>',
  DkIcons.leaf:
      '<path d="M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.48 19 2c1 2 2 4.18 2 8 0 5.5-4.78 10-10 10Z" fill="currentColor" fill-opacity=".25"/><path d="M2 21c0-3 1.85-5.36 5.08-6C9.5 14.52 12 13 13 12"/>',
  DkIcons.clock: '<circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/>',
  DkIcons.moon:
      '<path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z" fill="currentColor" fill-opacity=".2"/>',
  DkIcons.book:
      '<path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>',
  DkIcons.blocks:
      '<rect x="14" y="3" width="7" height="7" rx="1"/><path d="M10 21V8a1 1 0 0 0-1-1H4a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-5a1 1 0 0 0-1-1H3"/>',
  DkIcons.house:
      '<path d="M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8"/><path d="M3 10a2 2 0 0 1 .71-1.53l7-6a2 2 0 0 1 2.58 0l7 6A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>',
  DkIcons.search: '<circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/>',
  DkIcons.globe:
      '<circle cx="12" cy="12" r="10"/><path d="M12 2a14.5 14.5 0 0 0 0 20 14.5 14.5 0 0 0 0-20"/><path d="M2 12h20"/>',
  DkIcons.sliders:
      '<path d="M20 7h-9"/><path d="M14 17H5"/><circle cx="17" cy="17" r="3"/><circle cx="7" cy="7" r="3"/>',
  DkIcons.shield:
      '<path d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"/>',
  DkIcons.hourglass:
      '<path d="M5 22h14"/><path d="M5 2h14"/><path d="M17 22v-4.17a2 2 0 0 0-.59-1.42L12 12l-4.41 4.41A2 2 0 0 0 7 17.83V22"/><path d="M7 2v4.17a2 2 0 0 0 .59 1.42L12 12l4.41-4.41A2 2 0 0 0 17 6.17V2"/>',
  DkIcons.turtle:
      '<path d="m12 10 2 4v3a1 1 0 0 0 1 1h2a1 1 0 0 0 1-1v-3a8 8 0 1 0-16 0v3a1 1 0 0 0 1 1h2a1 1 0 0 0 1-1v-3l2-4h4Z"/><path d="M4.82 7.9 8 10"/><path d="M15.18 7.9 12 10"/><path d="M16.93 10H20a2 2 0 0 1 0 4H2"/>',
  DkIcons.plus: '<path d="M5 12h14"/><path d="M12 5v14"/>',
  DkIcons.trash:
      '<path d="M3 6h18"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"/><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>',
  DkIcons.download:
      '<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><path d="m7 10 5 5 5-5"/><path d="M12 15V3"/>',
  DkIcons.upload:
      '<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><path d="m17 8-5-5-5 5"/><path d="M12 3v12"/>',
  DkIcons.info:
      '<circle cx="12" cy="12" r="10"/><path d="M12 16v-4"/><path d="M12 8h.01"/>',
  DkIcons.back: '<path d="m12 19-7-7 7-7"/><path d="M19 12H5"/>',
  DkIcons.del:
      '<path d="M10 5a2 2 0 0 0-1.34.52l-6.33 5.74a1 1 0 0 0 0 1.48l6.33 5.74A2 2 0 0 0 10 19h10a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2z"/><path d="m12 9 6 6"/><path d="m18 9-6 6"/>',
  DkIcons.logout:
      '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="m16 17 5-5-5-5"/><path d="M21 12H9"/>',
  DkIcons.file:
      '<path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"/><path d="M14 2v4a2 2 0 0 0 2 2h4"/>',
  DkIcons.sprout:
      '<path d="M7 20h10"/><path d="M10 20c5.5-2.5.8-6.4 3-10"/><path d="M9.5 9.4c1.1.8 1.8 2.2 2.3 3.7-2 .4-3.5.4-4.8-.3-1.2-.6-2.3-1.9-3-4.2 2.8-.5 4.4 0 5.5.8z"/><path d="M14.1 6a7 7 0 0 0-1.1 4c1.9-.1 3.3-.6 4.3-1.4 1-1 1.6-2.3 1.7-4.6-2.7.1-4 1-4.9 2z"/>',
  DkIcons.tree:
      '<path d="M12 22v-7"/><path d="M9 9a3 3 0 1 1 6 0"/><path d="M12 15a6 6 0 0 0 6-6 6 6 0 0 0-6-6 6 6 0 0 0-6 6 6 6 0 0 0 6 6z" fill="currentColor" fill-opacity=".25"/>',
  DkIcons.seed:
      '<ellipse cx="12" cy="14" rx="6" ry="7" fill="currentColor" fill-opacity=".25"/><path d="M12 7c0-2 1-3.5 3-4"/>',
  DkIcons.family:
      '<circle cx="7" cy="5" r="2.5"/><circle cx="17" cy="5" r="2.5"/><circle cx="12" cy="11" r="2"/><path d="M4 21v-6a3 3 0 0 1 3-3"/><path d="M20 21v-6a3 3 0 0 0-3-3"/><path d="M9.5 21v-3.5a2.5 2.5 0 0 1 5 0V21"/>',
  DkIcons.calendar:
      '<rect x="3" y="4" width="18" height="18" rx="2"/><path d="M16 2v4"/><path d="M8 2v4"/><path d="M3 10h18"/>',
  DkIcons.chart:
      '<path d="M3 3v18h18"/><path d="M18 17V9"/><path d="M13 17V5"/><path d="M8 17v-3"/>',
  DkIcons.type:
      '<path d="M4 7V4h16v3"/><path d="M9 20h6"/><path d="M12 4v16"/>',
  DkIcons.pencil:
      '<path d="M21.17 6.81a1 1 0 0 0-3.98-3.98L3.84 16.17a2 2 0 0 0-.5.83l-1.32 4.35a.5.5 0 0 0 .62.62l4.35-1.32a2 2 0 0 0 .83-.5z"/><path d="m15 5 4 4"/>',
  DkIcons.flame:
      '<path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.153.433-2.294 1-3a2.5 2.5 0 0 0 2.5 2.5z" fill="currentColor" fill-opacity=".25"/>',
  // Işık (ana kaynak): kendi renkleriyle (maske değil). Kayıt adı eski
  // sürümden kaldı.
  DkIcons.nut:
      '<path d="M12 1.8l2.3 6.2 6.6.3-5.2 4.1 1.8 6.4L12 15.1l-5.5 3.7 1.8-6.4-5.2-4.1 6.6-.3z" fill="#E3A535" stroke="#7A4F0C" stroke-width="1.6"/><circle cx="12" cy="11" r="2.6" fill="#FFF3C4" stroke="none"/>',
};

final Map<String, String> _cache = {};

String _svg(DkIcons icon, double stroke, Color color) {
  final key = '${icon.name}|$stroke|${color.toARGB32()}';
  return _cache.putIfAbsent(key, () {
    final hex =
        '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    final body = icon == DkIcons.nut
        ? _paths[icon]!
        : _paths[icon]!.replaceAll('currentColor', hex);
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
        'stroke="$hex" stroke-width="$stroke" stroke-linecap="round" '
        'stroke-linejoin="round" stroke-opacity="${color.a}">$body</svg>';
  });
}

/// Tek renkli çizgi simgesi. Renk verilmezse çevredeki IconTheme rengi.
class DkIcon extends StatelessWidget {
  const DkIcon(this.icon,
      {super.key, this.size = 24, this.color, this.stroke = 2.5});

  final DkIcons icon;
  final double size;
  final Color? color;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    final c = color ??
        IconTheme.of(context).color ??
        DefaultTextStyle.of(context).style.color ??
        Colors.black;
    return ExcludeSemantics(
      child: SvgPicture.string(
        _svg(icon, stroke, c),
        width: size,
        height: size,
      ),
    );
  }
}
