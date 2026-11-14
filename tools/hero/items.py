"""Kahraman eşyalarının çizimleri (kahramanın 208×228 çizim alanında).

Çıktı lib/game/item_art.g.dart: eşya kimliği -> SVG parçası. Sırt eşyaları
gövdenin arkasına, diğerleri yüzün önüne çizilir (bkz. hero_svg.dart).

    python3 tools/hero/items.py            # Dart dosyasını yazar
    python3 tools/hero/items.py --check    # güncel mi?
    python3 tools/hero/items.py --preview  # /tmp/items_preview.svg

Önizlemedeki kahraman hero_svg.dart'taki çizimin sade bir kopyasıdır
(okçu, kısa saç); yalnızca eşyaların yerini görmek içindir.
"""
import math
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
OUT = ROOT / "lib/game/item_art.g.dart"


def star(cx, cy, r, fill="#E3A535", sw=1.4):
    pts = []
    for i in range(10):
        a = -math.pi / 2 + i * math.pi / 5
        rr = r if i % 2 == 0 else r * .45
        pts.append(f"{cx + rr * math.cos(a):.1f},{cy + rr * math.sin(a):.1f}")
    return f'<polygon points="{" ".join(pts)}" fill="{fill}" stroke-width="{sw}"/>'


ITEMS = {
    # boyun
    "atki": '<path d="M60 97Q80 109 100 97L103 106Q80 121 57 106Z" fill="#B8432F"/>'
            '<path d="M88 108L97 136L87 138L82 111Z" fill="#B8432F"/>'
            '<path d="M65 103l3 4M75 106l2 5M86 106l-1 5M88 130l8-2" fill="none" stroke="#FBF5E8" stroke-width="1.6"/>',
    "madalyon": '<path d="M64 99Q80 120 96 99" fill="none" stroke="#E3A535" stroke-width="2.4"/>'
                '<circle cx="80" cy="120" r="7.5" fill="#E3A535"/>' + star(80, 120, 4.2, "#FBF5E8", 1),
    "kolye": '<path d="M63 99Q80 128 97 99" fill="none" stroke-width="1.6"/>'
             '<circle cx="68" cy="110" r="2.2" fill="#E3A535" stroke-width="1"/><circle cx="92" cy="110" r="2.2" fill="#E3A535" stroke-width="1"/>'
             '<circle cx="80" cy="121" r="6.5" fill="#1F4E79"/><circle cx="80" cy="121" r="3.6" fill="#FBF5E8" stroke-width="1"/>'
             '<circle cx="80" cy="121" r="1.6" fill="#2B2320" stroke="none"/>',
    # rozet (göğüs, izleyicinin solu)
    "rozet_yildiz": '<circle cx="67" cy="126" r="8.5" fill="#1F4E79" stroke-width="1.8"/>' + star(67, 126, 6),
    "rozet_yaprak": '<circle cx="67" cy="126" r="8.5" fill="#FBF5E8" stroke-width="1.8"/>'
                    '<path d="M62 130C62 122 68 119 73 121C73 128 68 131 62 130Z" fill="#2F7A5B" stroke-width="1.4"/>'
                    '<path d="M63 129L71 123" fill="none" stroke-width="1"/>',
    "rozet_ay": '<circle cx="67" cy="126" r="8.5" fill="#6E5A9C" stroke-width="1.8"/>'
                '<path d="M69 120.5A6 6 0 1 0 69 131.5A4.6 4.6 0 1 1 69 120.5Z" fill="#E8B84A" stroke-width="1.2"/>',
    # baş
    "cicek_taci": '<path d="M50 42Q80 30 110 42" fill="none" stroke="#2F7A5B" stroke-width="3"/>'
                  + "".join(f'<circle cx="{x}" cy="{y}" r="4.2" fill="{c}" stroke-width="1.4"/><circle cx="{x}" cy="{y}" r="1.4" fill="#E3A535" stroke="none"/>'
                            for x, y, c in ((54, 40, "#B8432F"), (66, 35, "#FBF5E8"), (80, 33, "#6E5A9C"), (94, 35, "#FBF5E8"), (106, 40, "#B8432F"))),
    "bere": '<path d="M48 46C48 24 112 24 112 46Q80 38 48 46Z" fill="#6E5A9C"/>'
            '<path d="M48 46Q80 38 112 46Q80 52 48 46Z" fill="#5A4882"/>'
            '<path d="M102 34C108 20 118 12 128 10C124 20 116 30 106 38Z" fill="#E3A535"/>'
            '<path d="M106 36L124 14" fill="none" stroke-width="1.2"/>',
    "tac": '<path d="M60 38L63 18L72 28L80 12L88 28L97 18L100 38Q80 32 60 38Z" fill="#E3A535"/>'
           '<circle cx="80" cy="30" r="3" fill="#B8432F" stroke-width="1.4"/><circle cx="68" cy="33" r="2" fill="#1F4E79" stroke-width="1.2"/><circle cx="92" cy="33" r="2" fill="#1F4E79" stroke-width="1.2"/>',
    # el (izleyicinin sağındaki el: 109,153)
    "fener": '<path d="M109 159V166" fill="none" stroke-width="2"/>'
             '<circle cx="109" cy="182" r="15" fill="#E8B84A" fill-opacity=".25" stroke="none"/>'
             '<path d="M101 166H117L115 170V188L117 192H101L103 188V170Z" fill="#5A4B42"/>'
             '<path d="M104 171H114V187H104Z" fill="#E8B84A"/>'
             '<path d="M109 175C106 179 107 183 109 184C111 183 112 179 109 175Z" fill="#B8432F" stroke-width="1"/>',
    "cicek": '<path d="M107 150L101 128M110 150L110 124M113 150L119 129" fill="none" stroke="#2F7A5B" stroke-width="2"/>'
             '<circle cx="101" cy="126" r="5" fill="#B8432F"/><circle cx="110" cy="121" r="5" fill="#E3A535"/><circle cx="119" cy="127" r="5" fill="#6E5A9C"/>'
             '<path d="M103 144L117 144L113 152H107Z" fill="#FBF5E8" stroke-width="1.6"/>',
    "kitap": '<path d="M100 146L120 140L124 162L104 168Z" fill="#1F4E79"/>'
             '<path d="M103 148L121 143" fill="none" stroke="#E3A535" stroke-width="1.6"/>' + star(113, 155, 3.5),
    # sırt (çanta önde, kanat ve pelerin gövdenin arkasında)
    "canta": '<path d="M98 100L56 156" fill="none" stroke="#6C4F35" stroke-width="5"/>'
             '<path d="M40 150H64L66 174H38Z" fill="#8A5A3C"/><path d="M39 150H65L62 160H42Z" fill="#A06E4C"/>'
             '<circle cx="52" cy="160" r="2" fill="#E3A535" stroke-width="1"/>',
    "kanat": '<path d="M62 110C34 82 10 96 14 124C24 118 32 122 38 128C44 124 52 124 60 130Z" fill="#FBF5E8"/>'
             '<path d="M98 110C126 82 150 96 146 124C136 118 128 122 122 128C116 124 108 124 100 130Z" fill="#FBF5E8"/>'
             '<path d="M24 108L56 122M34 98L58 116M136 108L104 122M126 98L102 116" fill="none" stroke="#9AA6B2" stroke-width="1.4"/>',
    "yildiz_pelerin": '<path d="M58 102C42 130 36 162 40 190C66 198 94 198 120 190C124 162 118 130 102 102Z" fill="#1F4E79"/>'
                      + star(44, 180, 4) + star(116, 180, 4) + star(43, 152, 3) + star(117, 152, 3),
}

BACK = {"kanat", "yildiz_pelerin"}

# Dolaptaki küçük resim için eşyanın çevresindeki kutu (viewBox).
BOX = {
    "atki": "52 90 56 52", "madalyon": "58 94 44 40", "kolye": "58 94 44 40",
    "rozet_yildiz": "55 114 24 24", "rozet_yaprak": "55 114 24 24", "rozet_ay": "55 114 24 24",
    "cicek_taci": "44 22 72 26", "bere": "44 6 90 50", "tac": "56 8 48 34",
    "fener": "92 154 34 42", "cicek": "92 112 34 44", "kitap": "94 134 34 40",
    "canta": "34 96 70 82", "kanat": "8 80 144 54", "yildiz_pelerin": "34 98 92 104",
}

HERO = ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="-4 -4 208 228">'
        '<g stroke="#2B2320" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">'
        '<path d="M58 102C44 130 40 160 44 186C68 193 92 193 116 186C120 160 116 130 102 102Z" fill="#9E3624"/>'
        '{back}'
        '<path d="M70 168L68 203M90 168L92 203" fill="none" stroke="#4A3A32" stroke-width="12"/>'
        '<path d="M58 100Q80 92 102 100L112 172Q80 180 48 172Z" fill="#2F7A5B"/>'
        '<path d="M52 140Q80 147 108 140" fill="none" stroke="#5E3A1B" stroke-width="6"/>'
        '<path d="M62 99Q80 110 98 99L96 108Q80 117 64 108Z" fill="#E3A535"/>'
        '<path d="M60 104C50 112 44 130 46 150L56 150C56 134 60 120 66 112Z" fill="#2F7A5B"/><circle cx="51" cy="153" r="6.5" fill="#E8C4A0"/>'
        '<path d="M100 104C110 112 116 130 114 150L104 150C104 134 100 120 94 112Z" fill="#2F7A5B"/><circle cx="109" cy="153" r="6.5" fill="#E8C4A0"/>'
        '<circle cx="48" cy="66" r="6" fill="#E8C4A0"/><circle cx="112" cy="66" r="6" fill="#E8C4A0"/>'
        '<circle cx="80" cy="62" r="32" fill="#E8C4A0"/>'
        '<path d="M48.0 59.3C45.1 27.3 114.9 27.3 112.0 59.3C103.3 44.7 56.7 44.7 48.0 59.3Z" fill="#5A4B42"/>'
        '<path d="M64 57q5 -3 9 0M87 57q5 -3 9 0M74 80q6 5 12 0" fill="none" stroke-width="2"/>'
        '{front}'
        '</g></svg>')


def dart():
    out = ["// ÜRETİLMİŞ DOSYA: elle değiştirmeyin. Kaynak: tools/hero/items.py",
           "// python3 tools/hero/items.py", "",
           "/// Eşya çizimleri: kahramanın çizim alanında SVG parçaları.",
           "const itemArt = <String, String>{"]
    for k in sorted(ITEMS):
        v = ITEMS[k].replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$")
        out.append(f"  '{k}':\n      '{v}',")
    out.append("};")
    out.append("")
    out.append("/// Dolaptaki küçük resim için eşyanın çevresindeki kutu.")
    out.append("const itemBox = <String, String>{")
    for k in sorted(BOX):
        out.append(f"  '{k}': '{BOX[k]}',")
    out.append("};")
    out.append("")
    out.append("/// Gövdenin arkasına çizilen eşyalar.")
    out.append("const itemBack = <String>{" + ", ".join(f"'{k}'" for k in sorted(BACK)) + "};")
    return "\n".join(out) + "\n"


def preview():
    import re
    ids = list(ITEMS)
    parts = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1040 700" style="background:#F4EAD5">']
    for i, k in enumerate(ids):
        x, y = (i % 5) * 208, (i // 5) * 228
        svg = HERO.replace("{back}", ITEMS[k] if k in BACK else "").replace("{front}", "" if k in BACK else ITEMS[k])
        inner = re.sub(r'^<svg[^>]*>', '', svg)[:-6]
        parts.append(f'<svg x="{x}" y="{y}" width="208" height="228" viewBox="-4 -4 208 228">{inner}</svg>'
                     f'<text x="{x + 104}" y="{y + 222}" text-anchor="middle" font-size="14" font-family="sans-serif">{k}</text>')
    parts.append("</svg>")
    return "".join(parts)


def thumbs():
    parts = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 160" style="background:#FBF5E8">']
    for i, k in enumerate(ITEMS):
        x, y = (i % 8) * 100, (i // 8) * 80
        parts.append(f'<svg x="{x+10}" y="{y+5}" width="70" height="70" viewBox="{BOX[k]}"><g stroke="#2B2320" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">{ITEMS[k]}</g></svg>')
    parts.append("</svg>")
    return "".join(parts)


def main():
    text = dart()
    if "--check" in sys.argv:
        if not OUT.exists() or OUT.read_text() != text:
            print("item_art.g.dart güncel değil: python3 tools/hero/items.py")
            sys.exit(1)
        print(f"Eşya çizimleri güncel ({len(ITEMS)}).")
    elif "--preview" in sys.argv:
        pathlib.Path("/tmp/items_preview.svg").write_text(preview())
        pathlib.Path("/tmp/items_thumbs.svg").write_text(thumbs())
        print("/tmp/items_preview.svg")
    else:
        OUT.write_text(text)
        print(f"{OUT.relative_to(ROOT)}: {len(ITEMS)} eşya")


if __name__ == "__main__":
    main()
