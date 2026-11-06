"""İzometrik kasaba çizimlerini üretir.

Çizimler burada Python ile yazılır; çıktı lib/ui/game/town_art.g.dart
içindeki sabit SVG metinleridir. Böylece görseller yerelde (rsvg-convert ile)
önizlenebilir ve Dart tarafında hiç çizim mantığı kalmaz.

    python3 tools/town/art.py            # Dart dosyasını yazar
    python3 tools/town/art.py --check    # güncel mi? (CI)
    python3 tools/town/art.py --preview  # /tmp/town_preview.svg

flutter_svg filtre ve desen desteklemediği için yalnızca polygon, path,
ellipse kullanılır.
"""
import math
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
OUT = ROOT / "lib/ui/game/town_art.g.dart"
INK = "#2B2320"

BUILDINGS = ["ev", "ocak", "firin", "demirhane", "kitaplik", "cesme", "bahce", "gozlemevi", "han"]


def f(v):
    v = round(v, 1)
    return str(int(v)) if v == int(v) else str(v)


def shade(hex_, k):
    v = int(hex_[1:], 16)
    ch = lambda s: max(0, min(255, round(((v >> s) & 0xFF) * k)))
    return "#%02x%02x%02x" % (ch(16), ch(8), ch(0))


class Sketch:
    def __init__(self, w=64, h=96):
        self.parts = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}">',
                      f'<g stroke="{INK}" stroke-width="1.6" stroke-linejoin="round" stroke-linecap="round">']

    def poly(self, pts, fill):
        p = " ".join(f"{f(pts[i])},{f(pts[i+1])}" for i in range(0, len(pts), 2))
        self.parts.append(f'<polygon points="{p}" fill="{fill}"/>')

    def path(self, d, fill="none", stroke=None, w=None):
        a = f'<path d="{d}" fill="{fill}"'
        if stroke:
            a += f' stroke="{stroke}"'
        if w:
            a += f' stroke-width="{f(w)}"'
        self.parts.append(a + "/>")

    def ellipse(self, cx, cy, rx, ry, fill, stroke=True, opacity=None):
        a = f'<ellipse cx="{f(cx)}" cy="{f(cy)}" rx="{f(rx)}" ry="{f(ry)}" fill="{fill}"'
        if not stroke:
            a += ' stroke="none"'
        if opacity is not None:
            a += f' fill-opacity="{opacity}"'
        self.parts.append(a + "/>")

    def box(self, cx, cy, a, h, left, right, top=None):
        bh = a / 2
        self.poly([cx - a, cy, cx, cy + bh, cx, cy + bh - h, cx - a, cy - h], left)
        self.poly([cx, cy + bh, cx + a, cy, cx + a, cy - h, cx, cy + bh - h], right)
        if top:
            self.poly([cx, cy - bh - h, cx + a, cy - h, cx, cy + bh - h, cx - a, cy - h], top)

    def roof(self, cx, cy, a, h, r, c, c2):
        bh = a / 2
        apex = cy - h - r
        # arka saçak, sol ön yüz, sağ ön yüz
        self.poly([cx - a - 3, cy - h + 1, cx, cy - bh - h - 1, cx, apex], shade(c, .9))
        self.poly([cx - a - 3, cy - h + 1, cx, cy + bh - h + 2, cx, apex], c)
        self.poly([cx, cy + bh - h + 2, cx + a + 3, cy - h + 1, cx, apex], c2)

    def done(self):
        return "".join(self.parts) + "</g></svg>"


def shadow(s, a):
    s.ellipse(32, 82, a + 5, (a + 5) / 2.1, "#000", stroke=False, opacity=".13")


def house(s, lv, wall, wall2, roof, wide=False, sign=None):
    a = 26 if wide else 22
    h = {1: 14, 2: 22, 3: 34}[lv]
    shadow(s, a)
    s.box(32, 80, a, h, wall, wall2)
    # taş temel çizgisi
    s.path(f"M{f(32-a)} {f(80-3)}L32 {f(80+a/2-3)}L{f(32+a)} {f(80-3)}", stroke=shade(wall2, .8), w=1.2)
    if lv == 3:
        s.path(f"M{f(32-a)} {f(80-18)}L32 {f(80+a/2-18)}L{f(32+a)} {f(80-18)}")
    # kapı (sağ yüz)
    dx, dy = 32 + a * .42, 80 + a * .29
    s.poly([dx - 3.5, dy + 1.75, dx + 3.5, dy - 1.75, dx + 3.5, dy - 12.5, dx - 3.5, dy - 9], "#5A4B42")
    if lv >= 2:
        wx, wy = 32 - a * .5, 80 + a * .25 - 7
        win(s, wx, wy, left=True)
        if lv == 3:
            win(s, wx, wy - 15, left=True)
            win(s, 32 + a * .5, 80 + a * .25 - 22, left=False)
    r = 12 if lv == 1 else 16
    if lv >= 2:
        s.box(41, 80 - h - 2, 3, 13, "#9AA6B2", "#7E8A96", top="#5A4B42")
    s.roof(32, 80, a, h, r, roof, shade(roof, .78))
    if lv == 3:
        top = 80 - h - r
        s.path(f"M32 {f(top)}V{f(top-14)}")
        s.poly([32, top - 14, 43, top - 11, 32, top - 7.5], "#E3A535")
    if sign:
        sign(s, lv, a, h)


def win(s, x, y, left):
    k = 1 if left else -1
    s.poly([x - 3, y - 1.5 * k, x + 3, y + 1.5 * k, x + 3, y + 1.5 * k - 6, x - 3, y - 1.5 * k - 6], "#E8B84A")
    s.path(f"M{f(x)} {f(y)}V{f(y-6)}", w=1)


def sign_loaf(s, lv, a, h):
    x, y = 32 - a * .5, 80 + a * .25 - (4 if lv == 1 else h - 6)
    if lv == 1:
        y = 80 + a * .25 - 6
    s.path(f"M{f(x-6)} {f(y)}C{f(x-6)} {f(y-7)} {f(x+6)} {f(y-7)} {f(x+6)} {f(y)}Z", fill="#E3A535")
    s.path(f"M{f(x-2)} {f(y-4)}l1 2M{f(x+2)} {f(y-4)}l1 2", w=1.2)


def sign_anvil(s, lv, a, h):
    x, y = 32 - a - 2, 88
    s.path(f"M{f(x-5)} {f(y-6)}H{f(x+7)}L{f(x+3)} {f(y-3)}V{f(y)}H{f(x-2)}V{f(y-3)}Z", fill="#5A4B42")
    if lv >= 2:
        s.path(f"M{f(x+10)} {f(y-12)}l2 -3M{f(x+13)} {f(y-10)}l3 -1", stroke="#E3A535", w=1.4)


def sign_book(s, lv, a, h):
    x, y = 32 - a * .5, 80 + a * .25 - (6 if lv == 1 else h - 5)
    s.path(f"M{f(x-6)} {f(y-4)}L{f(x)} {f(y-1)}L{f(x+6)} {f(y-4)}V{f(y+3)}L{f(x)} {f(y+6)}L{f(x-6)} {f(y+3)}Z", fill="#F4EAD5")
    s.path(f"M{f(x)} {f(y-1)}V{f(y+6)}", w=1.2)


def sign_inn(s, lv, a, h):
    # asma tabela
    x, y = 32 + a + 1, 80 - h + 4
    s.path(f"M{f(x-6)} {f(y)}H{f(x+4)}", w=1.4)
    s.poly([x - 2, y + 2, x + 6, y - 2, x + 6, y + 5, x - 2, y + 9], "#E3A535")
    if lv >= 2:
        # kervan sandığı
        s.box(10, 88, 5, 6, "#8A5A3C", "#6C4F35", top="#A06E4C")


def tower(s, lv):
    h = {1: 22, 2: 34, 3: 46}[lv]
    shadow(s, 16)
    s.box(32, 80, 15, h, "#C9D1D9", "#9AA6B2")
    for i in range(1, lv + 1):
        y = 80 - i * 11
        s.path(f"M17 {f(y)}L32 {f(y+7.5)}L47 {f(y)}", stroke="#7E8A96", w=1)
    top = 80 - h
    s.path(f"M16 {f(top)}C16 {f(top-20)} 48 {f(top-20)} 48 {f(top)}C42 {f(top+7)} 22 {f(top+7)} 16 {f(top)}Z", fill="#1F4E79")
    s.path(f"M30 {f(top-14)}V{f(top+3)}", stroke="#E8B84A", w=1.6)
    if lv >= 2:
        s.path(f"M34 {f(top-9)}L48 {f(top-18)}", stroke=INK, w=4.4)
        s.path(f"M34 {f(top-9)}L48 {f(top-18)}", stroke="#B8432F", w=2)
    if lv == 3:
        cx, cy = 22, top - 22
        star(s, cx, cy, 4.5)
        star(s, 50, top - 28, 3)
    s.poly([35, 85, 41, 82, 41, 72, 35, 75], "#5A4B42")


def star(s, cx, cy, r):
    pts = []
    for i in range(10):
        ang = -math.pi / 2 + i * math.pi / 5
        rr = r if i % 2 == 0 else r * .45
        pts += [cx + rr * math.cos(ang), cy + rr * math.sin(ang)]
    s.poly(pts, "#E8B84A")


def fountain(s, lv):
    shadow(s, 20)
    s.ellipse(32, 82, 22, 11, "#7E8A96")
    s.ellipse(32, 79, 22, 11, "#9AA6B2")
    s.ellipse(32, 78, 17, 8, "#6FA8D6")
    if lv >= 2:
        s.box(32, 77, 3.5, 14, "#C9D1D9", "#9AA6B2")
        s.ellipse(32, 63, 9, 4, "#C9D1D9")
        s.ellipse(32, 62, 7, 3, "#6FA8D6")
    base = 76 if lv == 1 else 61
    jet = {1: 66, 2: 50, 3: 40}[lv]
    s.path(f"M32 {base}V{jet}M32 {jet}C26 {jet} 24 {jet+6} 22 {base+4}M32 {jet}C38 {jet} 40 {jet+6} 42 {base+4}", stroke="#1F4E79", w=1.8)
    if lv == 3:
        for x in (8, 56):
            s.path(f"M{x} 84l-3 -6h6z", fill="#E3A535")
        s.ellipse(32, 36, 2.5, 2.5, "#FFFFFF")


def garden(s, lv):
    s.poly([32, 67, 55, 78.5, 32, 90, 9, 78.5], "#8A6A4A")
    rows = lv + 1
    for i in range(rows):
        t = (i + 1) / (rows + 1)
        x1, y1 = 9 + 23 * t, 78.5 - 11.5 * t
        x2, y2 = 32 + 23 * t, 90 - 11.5 * t
        s.path(f"M{f(x1)} {f(y1)}L{f(x2)} {f(y2)}", stroke="#6C4F35", w=1.2)
        for k in (1, 2, 3):
            u = k / 4
            px, py = x1 + (x2 - x1) * u, y1 + (y2 - y1) * u
            s.path(f"M{f(px)} {f(py)}v-5", stroke="#2F7A5B", w=1.4)
            c = "#E3A535" if (lv == 3 and k == 2) else ("#B8432F" if lv >= 2 and k == 3 else "#2F7A5B")
            s.ellipse(px, py - 6, 2.4, 2.4, c)
    s.path("M9 78.5L32 67L55 78.5", w=1.4)
    for x in (13, 21, 43, 51):
        y = 78.5 - (x - 9) / 2 if x < 32 else 67 + (x - 32) / 2
        s.path(f"M{x} {f(y)}v-6", w=1.4)
    if lv >= 2:
        s.path("M46 74V56M40 60H52", w=2)
        s.ellipse(46, 54, 3.5, 3.5, "#E8C4A0")
        s.path("M42 52H50L46 47Z", fill="#E3A535")


def hearth(s, lv):
    shadow(s, 15)
    for i in range(9):
        ang = i / 9 * 2 * math.pi
        s.ellipse(32 + 15 * math.cos(ang), 80 + 7.5 * math.sin(ang), 4, 3, "#9AA6B2")
    fh = 10 + lv * 5
    s.path(f"M24 80C24 {f(80-fh*.6)} 30 {f(80-fh*.7)} 32 {f(80-fh)}C34 {f(80-fh*.7)} 40 {f(80-fh*.6)} 40 80Z", fill="#E3A535")
    s.path(f"M28 80C28 {f(80-fh*.4)} 31 {f(80-fh*.45)} 32 {f(80-fh*.7)}C33 {f(80-fh*.45)} 36 {f(80-fh*.4)} 36 80Z", fill="#B8432F")
    if lv >= 2:
        s.path(f"M18 84L22 {f(80-fh-6)}M46 84L42 {f(80-fh-6)}M20 {f(80-fh-6)}H44", stroke="#5A4B42", w=2.2)
        s.path(f"M27 {f(80-fh-6)}V{f(80-fh)}", w=1.2)
        s.path(f"M24 {f(80-fh)}H36L34 {f(80-fh+7)}H26Z", fill="#5A4B42")
    if lv == 3:
        for x, y in ((12, 74), (52, 74)):
            s.box(x, y + 10, 4, 6, "#8A5A3C", "#6C4F35", top="#A06E4C")


def building(bid, lv):
    s = Sketch()
    if bid == "ev":
        house(s, lv, "#F4EAD5", "#E2D2B3", "#B8432F")
    elif bid == "firin":
        house(s, lv, "#EADBC0", "#D4C09C", "#8A5A3C", sign=sign_loaf)
    elif bid == "demirhane":
        house(s, lv, "#B7C0C9", "#9AA6B2", "#5A4B42", sign=sign_anvil)
    elif bid == "kitaplik":
        house(s, lv, "#F4EAD5", "#E2D2B3", "#1F4E79", sign=sign_book)
    elif bid == "han":
        house(s, lv, "#E3C79A", "#C9AC7E", "#2F7A5B", wide=True, sign=sign_inn)
    elif bid == "gozlemevi":
        tower(s, lv)
    elif bid == "cesme":
        fountain(s, lv)
    elif bid == "bahce":
        garden(s, lv)
    elif bid == "ocak":
        hearth(s, lv)
    else:
        raise ValueError(bid)
    return s.done()


def tile(kind):
    """kind: grass, road, pick (yerleştirme için seçilebilir kare)."""
    top = {"grass": "#A9CF8C", "road": "#E6CFA0", "pick": "#C7E8B0"}[kind]
    side = "#C9A86E" if kind == "road" else "#7FA864"
    side2 = "#B8955C" if kind == "road" else "#6C9353"
    p = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 40">',
         f'<g stroke="{INK}" stroke-width="1.2" stroke-linejoin="round">',
         f'<polygon points="0,16 32,32 32,40 0,24" fill="{side}"/>',
         f'<polygon points="32,32 64,16 64,24 32,40" fill="{side2}"/>',
         f'<polygon points="32,0 64,16 32,32 0,16" fill="{top}"/>']
    if kind == "road":
        p.append('<path d="M20 14l4 2M38 20l5 2M30 9l3 1" fill="none" stroke="#B8955C" stroke-width="1.6" stroke-linecap="round"/>')
    else:
        p.append('<path d="M18 15l1-3 1 3M42 19l1-3 1 3M30 23l1-3 1 3" fill="none" stroke="#5E8A47" stroke-width="1.2" stroke-linecap="round"/>')
    if kind == "pick":
        p.append('<polygon points="32,4 56,16 32,28 8,16" fill="none" stroke="#E3A535" stroke-width="2.4" stroke-dasharray="4 3"/>')
    p.append("</g></svg>")
    return "".join(p)


def villager(tone, step):
    coats = ["#B8432F", "#1F4E79", "#2F7A5B", "#E3A535"]
    c = coats[tone % 4]
    legs = "M10 28l-2 6M14 28l3 6" if step else "M10 28l-1 6M14 28l1 6"
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 36">'
            f'<g stroke="{INK}" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">'
            '<ellipse cx="12" cy="34" rx="7" ry="2" fill="#000" fill-opacity=".15" stroke="none"/>'
            f'<path d="{legs}" fill="none"/>'
            f'<path d="M6 28C6 20 8 16 12 16C16 16 18 20 18 28Z" fill="{c}"/>'
            '<circle cx="12" cy="11" r="5" fill="#E8C4A0"/>'
            '<path d="M7 10C8 5 16 5 17 10" fill="#5A4B42"/>'
            '</g></svg>')


def tree(kind):
    s = Sketch(32, 48)
    s.ellipse(16, 42, 9, 4, "#000", stroke=False, opacity=".13")
    s.path("M16 42V30", stroke="#6C4F35", w=3)
    if kind == 0:
        s.ellipse(16, 22, 11, 11, "#2F7A5B")
        s.ellipse(12, 19, 4, 4, "#4E9A72", stroke=False)
    else:
        s.poly([16, 4, 26, 24, 6, 24], "#2F7A5B")
        s.poly([16, 14, 28, 34, 4, 34], "#3E8A66")
    return s.done()


def smoke():
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 30">'
            f'<g stroke="{INK}" stroke-width="1.2" fill="#EEF2F5">'
            '<circle cx="10" cy="24" r="4"/><circle cx="12" cy="15" r="5"/><circle cx="9" cy="6" r="4"/>'
            '</g></svg>')


def all_art():
    art = {}
    for b in BUILDINGS:
        for lv in (1, 2, 3):
            art[f"{b}_{lv}"] = building(b, lv)
    for k in ("grass", "road", "pick"):
        art[f"tile_{k}"] = tile(k)
    for t in range(4):
        for st in (0, 1):
            art[f"villager_{t}_{st}"] = villager(t, bool(st))
    art["smoke"] = smoke()
    art["tree_0"] = tree(0)
    art["tree_1"] = tree(1)
    return art


def dart(art):
    out = ["// ÜRETİLMİŞ DOSYA: elle değiştirmeyin. Kaynak: tools/town/art.py",
           "// python3 tools/town/art.py", "",
           "/// İzometrik kasaba çizimleri (SVG metni).", "const townArt = <String, String>{"]
    for k in sorted(art):
        v = art[k].replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$")
        out.append(f"  '{k}':\n      '{v}',")
    out.append("};")
    return "\n".join(out) + "\n"


def preview(art):
    """Bütün yapıları ve örnek bir kasabayı tek SVG'de gösterir."""
    import re
    parts = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 820" style="background:#F4EAD5">']
    def embed(svg, x, y, w, h):
        inner = re.sub(r'^<svg[^>]*>', '', svg)[:-6]
        vb = re.search(r'viewBox="([^"]+)"', svg).group(1)
        return f'<svg x="{x}" y="{y}" width="{w}" height="{h}" viewBox="{vb}">{inner}</svg>'
    for i, b in enumerate(BUILDINGS):
        for lv in (1, 2, 3):
            parts.append(embed(art[f"{b}_{lv}"], 10 + lv * 0 + (lv - 1) * 95, 10 + i * 0, 0, 0))
    # ızgara: yapılar satır satır
    parts = parts[:1]
    for i, b in enumerate(BUILDINGS):
        col, row = i % 3, i // 3
        for lv in (1, 2, 3):
            x = 10 + col * 300 + (lv - 1) * 96
            y = 10 + row * 150
            parts.append(embed(art["tile_grass"], x, y + 112, 96, 60))
            parts.append(embed(art[f"{b}_{lv}"], x, y - 8, 96, 144))
    # örnek kasaba
    ox, oy, tw = 450, 470, 64
    layout = {(1, 1): "ev_3", (4, 4): "ocak_2", (3, 1): "firin_2", (4, 1): "demirhane_1",
              (1, 3): "kitaplik_3", (3, 3): "cesme_3", (0, 4): "bahce_2", (4, 0): "gozlemevi_3", (3, 4): "han_2"}
    roads = {(2, y) for y in range(6)} | {(x, 2) for x in range(6)}
    trees = {(0, 0): "tree_1", (5, 0): "tree_0", (5, 5): "tree_1", (0, 5): "tree_0", (5, 3): "tree_0"}
    cells = sorted(((x, y) for x in range(6) for y in range(6)), key=lambda c: (c[0] + c[1], c[0]))
    for (x, y) in cells:
        px = ox + (x - y) * tw / 2 - tw / 2
        py = oy + (x + y) * tw / 4
        parts.append(embed(art["tile_road" if (x, y) in roads else "tile_grass"], px, py, tw, 40))
    for (x, y) in cells:
        if (x, y) in layout:
            px = ox + (x - y) * tw / 2 - tw / 2
            py = oy + (x + y) * tw / 4
            parts.append(embed(art[layout[(x, y)]], px, py + 16 - 80, tw, 96))
        elif (x, y) in trees:
            px = ox + (x - y) * tw / 2 - tw / 2
            py = oy + (x + y) * tw / 4
            parts.append(embed(art[trees[(x, y)]], px + 16, py + 16 - 42, 32, 48))
    parts.append(embed(art["villager_1_0"], ox - 20, oy + 40, 18, 27))
    parts.append(embed(art["villager_3_1"], ox + 8, oy + 70, 18, 27))
    parts.append("</svg>")
    return "".join(parts)


def main():
    art = all_art()
    text = dart(art)
    if "--check" in sys.argv:
        if not OUT.exists() or OUT.read_text() != text:
            print("town_art.g.dart güncel değil: python3 tools/town/art.py")
            sys.exit(1)
        print(f"Kasaba çizimleri güncel ({len(art)} parça).")
        return
    if "--preview" in sys.argv:
        pathlib.Path("/tmp/town_preview.svg").write_text(preview(art))
        print("/tmp/town_preview.svg")
        return
    OUT.write_text(text)
    print(f"{OUT.relative_to(ROOT)}: {len(art)} parça")


if __name__ == "__main__":
    main()
