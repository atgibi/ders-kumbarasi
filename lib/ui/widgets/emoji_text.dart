import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'emoji_names.g.dart';

/// Twemoji dosya adı (tools/emoji/fetch.py ile aynı kural).
String emojiFileName(String cluster) {
  var cps = cluster.runes.toList();
  if (!cps.contains(0x200D)) cps = cps.where((c) => c != 0xFE0F).toList();
  return cps.map((c) => c.toRadixString(16)).join('-');
}

/// Kümede çizilecek bir emoji görseli varsa yolu.
String? emojiAsset(String cluster) {
  final n = emojiFileName(cluster);
  return twemojiNames.contains(n) ? 'assets/emoji/$n.svg' : null;
}

/// Metindeki emojileri uygulamayla gelen görsellerle çizer (her cihazda aynı;
/// eski Android'de kutucuk çıkmaz).
class EmojiText extends StatelessWidget {
  const EmojiText(this.text,
      {super.key, this.style, this.textAlign, this.maxLines});
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final base = DefaultTextStyle.of(context).style.merge(style);
    final size = base.fontSize ?? 16;
    final spans = <InlineSpan>[];
    final buf = StringBuffer();
    for (final g in text.characters) {
      final a = g.runes.first > 0xFF ? emojiAsset(g) : null;
      if (a == null) {
        buf.write(g);
        continue;
      }
      if (buf.isNotEmpty) {
        spans.add(TextSpan(text: buf.toString()));
        buf.clear();
      }
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size * .04),
          child: Builder(builder: (context) {
            final s = MediaQuery.textScalerOf(context).scale(size) * 1.12;
            return SvgPicture.asset(a, width: s, height: s);
          }),
        ),
      ));
    }
    if (buf.isNotEmpty) spans.add(TextSpan(text: buf.toString()));
    return Text.rich(
      TextSpan(style: base, children: spans),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      semanticsLabel: text,
    );
  }
}

/// Tek emoji (büyük görsel olarak).
class EmojiImage extends StatelessWidget {
  const EmojiImage(this.emoji, {super.key, this.size = 40});
  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    final a = emojiAsset(emoji);
    if (a == null) {
      return Text(emoji,
          textScaler: TextScaler.noScaling,
          style: TextStyle(fontSize: size * .85, height: 1));
    }
    return SvgPicture.asset(a, width: size, height: size);
  }
}
