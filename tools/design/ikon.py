"""Tasarımdaki el çizimi simge setini (Ikon bileşeni) SVG dosyalarına döker.

Kaynak: Claude Design "Bilgelik Diyarı" › Bileşenler › Simge. Her simge iki
tonda üretilir: mürekkep (koyu çizgi) ve kâğıt (_k, koyu zemin üstü).
Çalıştırma: python3 tools/design/ikon.py
"""
import math, os

OUT = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "ikon")

def disli():
    s, n = "", 8
    for i in range(n):
        a0, w = i / n * math.pi * 2, math.pi / n
        pts = [(a0 - w * .55, 10.5), (a0 - w * .32, 13.5), (a0 + w * .32, 13.5), (a0 + w * .55, 10.5)]
        for j, (a, r) in enumerate(pts):
            s += ("M" if i == 0 and j == 0 else "L") + f"{16 + math.cos(a) * r:.1f} {16 + math.sin(a) * r:.1f}"
    return s + "Z"

D = disli()
# ad: (dolgu katmanı [(d, renk)], çizgi katmanı (C = çizgi rengi))
FILL = {
 "isik": [("M16 4C20 10 24 13 24 19A8 8 0 0 1 8 19C8 13 12 10 16 4Z", "#E3A535")],
 "demir": [("M4 24L8 15H24L28 24ZM8 15L11 11H21L24 15Z", "#8C96A0")],
 "kereste": [("M5 9H23A4 4 0 0 1 23 17H5ZM9 17H27A4 4 0 0 1 27 25H9Z", "#A8723F")],
 "ekmek": [("M5 20C5 12 11 9 16 9C21 9 27 12 27 20C27 23 25 24 22 24H10C7 24 5 23 5 20Z", "#D9A441")],
 "kristal": [("M16 3L23 10L20 28H12L9 10Z", "#6E5A9C")],
 "kumas": [("M5 7H13V27H5ZM13 9C19 9 22 12 27 11V25C22 26 19 23 13 23Z", "#2E7D8A")],
 "yildiz": [("M16 3L19.5 11.5L28.5 12.3L21.6 18.2L23.8 27.2L16 22.4L8.2 27.2L10.4 18.2L3.5 12.3L12.5 11.5Z", "#E3A535")],
 "sancak": [("M8 5H26L21 10.5L26 16H8Z", "#B8432F")],
 "tuy": [("M25 3C14 6 8 14 7 26C13 22 21 17 25 3Z", "#2F7A5B")],
 "mesale": [("M16 2C20 6 21 9 20 12H11C10 9 12 6 16 2ZM14 17L12 29H18L17 17Z", "#E3A535")],
 "yavas": [("M5 21C5 13 10 10 16 10C22 10 26 13 26 21Z", "#2F7A5B")],
 "kilit": [("M8 14H24V27H8Z", "#9AA6B2")],
 "kapi": [("M8 28V12A8 8 0 0 1 24 12V28Z", "#8A5A2E")],
 "anahtar": [("M10 4.5A5.5 5.5 0 1 1 9.9 4.5Z", "#E3A535")],
 "ayar": [(D, "#C9D1D9")],
 "defter": [("M7 4H25V29H7Z", "#B8432F")],
 "harita": [("M4 8L11 5L21 8L28 5V24L21 27L11 24L4 27Z", "#EADBC0")],
 "kasaba": [("M7 15H25V28H7Z", "#EADBC0"), ("M4 16L16 5L28 16Z", "#B8432F")],
 "kalkan": [("M16 4L26 8V16C26 22 21 26 16 28C11 26 6 22 6 16V8Z", "#1F4E79")],
 "cadir": [("M4 26L16 6L28 26Z", "#B8432F")],
 "saat": [("M16 5A11 11 0 1 1 15.9 5Z", "#EADBC0")],
 "nota": [("M12 8L24 5V9L12 12Z", "#B8432F")],
}
LINE = {
 "isik": '<path d="M16 4C20 10 24 13 24 19A8 8 0 0 1 8 19C8 13 12 10 16 4Z"/><path d="M14 17C13 20 14 22 16 23" stroke-width="1.6"/><path d="M4 9l2 1.5M28 9l-2 1.5M16 0.8v1.4" stroke-width="1.8"/>',
 "demir": '<path d="M4 24L8 15H24L28 24Z"/><path d="M8 15L11 11H21L24 15"/><path d="M11 19h4" stroke-width="1.5"/>',
 "kereste": '<path d="M23 9H5M23 17H5M5 9V17M27 17H9M27 25H9M9 17V25"/><circle cx="23" cy="13" r="4"/><circle cx="23" cy="13" r="1.5" stroke-width="1.4"/><circle cx="27" cy="21" r="4"/><circle cx="27" cy="21" r="1.5" stroke-width="1.4"/>',
 "ekmek": '<path d="M5 20C5 12 11 9 16 9C21 9 27 12 27 20C27 23 25 24 22 24H10C7 24 5 23 5 20Z"/><path d="M11 13l2 4M16 12l2 4M21 13l2 4" stroke-width="1.7"/>',
 "kristal": '<path d="M16 3L23 10L20 28H12L9 10Z"/><path d="M9 10H23M14 10L16 28M18 10L16 28M14 10L16 3L18 10" stroke-width="1.5"/>',
 "kumas": '<path d="M5 7H13V27H5Z"/><path d="M13 9C19 9 22 12 27 11V25C22 26 19 23 13 23"/><path d="M14 15l3 3l3 -3l3 3l3 -3" stroke-width="1.5"/>',
 "yildiz": '<path d="M16 3L19.5 11.5L28.5 12.3L21.6 18.2L23.8 27.2L16 22.4L8.2 27.2L10.4 18.2L3.5 12.3L12.5 11.5Z"/>',
 "sancak": '<path d="M8 4V29"/><path d="M8 5H26L21 10.5L26 16H8"/><circle cx="8" cy="3" r="1.4" fill="C"/><path d="M5 29h7"/>',
 "tuy": '<path d="M25 3C14 6 8 14 7 26C13 22 21 17 25 3Z"/><path d="M5 29L21 9" stroke-width="1.7"/><circle cx="18" cy="12" r="2.4" fill="#E3A535" stroke-width="1.4"/><path d="M10 20l-3 -2M13 16l-3 -3" stroke-width="1.4"/>',
 "mesale": '<path d="M16 2C20 6 21 9 20 12H11C10 9 12 6 16 2Z"/><path d="M15.5 7C17 8.5 17 10 16.5 12" stroke="#B8432F" stroke-width="1.8"/><path d="M9.5 12H21.5L19.5 17H11.5Z"/><path d="M14 17L12 29H18L17 17"/>',
 "dinle": '<path d="M5 12H10L17 6V26L10 20H5Z" fill="C" fill-opacity="0.18"/><path d="M21 11.5Q24 16 21 20.5M24.5 8Q30 16 24.5 24"/>',
 "yavas": '<path d="M5 21C5 13 10 10 16 10C22 10 26 13 26 21Z"/><path d="M3 21H28"/><path d="M11 13L13 17L18 17L20 13M13 17L11 21M18 17L20 21" stroke-width="1.4"/><circle cx="28" cy="17.5" r="2.6"/><path d="M9 21v3M21 21v3"/>',
 "kilit": '<path d="M11 14V10A5 5 0 0 1 21 10V14"/><path d="M8 14H24V27H8Z"/><path d="M16 19v3" stroke-width="2.6"/>',
 "kapi": '<path d="M8 28V12A8 8 0 0 1 24 12V28Z"/><path d="M12 7.5V28M16 4V28M20 7.5V28" stroke-width="1.3"/><path d="M8 13H24M8 22H24" stroke-width="1.8"/><circle cx="20.5" cy="17.5" r="1.5"/><path d="M5 28H27"/>',
 "anahtar": '<circle cx="10" cy="10" r="5.5"/><circle cx="10" cy="10" r="1.6" stroke-width="1.4"/><path d="M14 14L27 27M22 22l3 -3M25.5 25.5l2.5 -2.5"/>',
 "ayar": f'<path d="{D}"/><circle cx="16" cy="16" r="4"/>',
 "defter": '<path d="M7 4H25V29H7Z"/><path d="M11 4V29" stroke-width="1.6"/><path d="M25 14H21V19H25" fill="#E3A535"/><path d="M14 9h7M14 12h5" stroke="#FBF5E8" stroke-width="1.5"/>',
 "harita": '<path d="M4 8L11 5L21 8L28 5V24L21 27L11 24L4 27Z"/><path d="M11 5V24M21 8V27" stroke-width="1.3"/><path d="M7 20C10 14 15 18 18 13" stroke-dasharray="2 2.4" stroke-width="1.5"/><path d="M21 10l3 3M24 10l-3 3" stroke="#B8432F" stroke-width="1.9"/>',
 "kasaba": '<path d="M4 16L16 5L28 16"/><path d="M7 14V28H25V14"/><path d="M13 28V22A3 3 0 0 1 19 22V28"/><path d="M21 8V5H24V11" stroke-width="1.8"/>',
 "kalkan": '<path d="M16 4L26 8V16C26 22 21 26 16 28C11 26 6 22 6 16V8Z"/><path d="M16 10L17.6 14L21.6 14.3L18.5 16.9L19.5 20.9L16 18.7L12.5 20.9L13.5 16.9L10.4 14.3L14.4 14Z" fill="#E3A535" stroke-width="1.3"/>',
 "geri": '<path d="M19 7L10 16L19 25"/><path d="M10.5 16H26" stroke-width="1.9"/>',
 "ileri": '<path d="M13 7L22 16L13 25"/><path d="M21.5 16H6" stroke-width="1.9"/>',
 "tik": '<path d="M6 17L13 24L26 7" stroke-width="3.2"/>',
 "kapat": '<path d="M8 8L24 24M24 8L8 24" stroke-width="2.6"/>',
 "cadir": '<path d="M4 26L16 6L28 26Z"/><path d="M16 6V26M12 26L16 17L20 26" stroke-width="1.6"/><path d="M2 26H30"/>',
 "saat": '<circle cx="16" cy="16" r="11"/><path d="M16 9V16L21 19"/>',
 "nota": '<path d="M12 8L24 5V9L12 12"/><path d="M12 8V23M24 5V20"/><ellipse cx="9.5" cy="23.5" rx="3" ry="2.3" fill="C"/><ellipse cx="21.5" cy="20.5" rx="3" ry="2.3" fill="C"/>',
 "ses": '<path d="M5 12H10L17 6V26L10 20H5Z"/><path d="M21 13q2 3 0 6"/>',
}

def svg(ad, c):
    fill = "".join(f'<path d="{d}" fill="{col}"/>' for d, col in FILL.get(ad, []))
    line = LINE[ad].replace('"C"', f'"{c}"')
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="-1 -1 34 34">'
            f'<g transform="translate(0.8 0.9)">{fill}</g>'
            f'<g fill="none" stroke="{c}" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">{line}</g></svg>\n')

if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for ad in LINE:
        open(os.path.join(OUT, f"{ad}.svg"), "w").write(svg(ad, "#2B2320"))
        open(os.path.join(OUT, f"{ad}_k.svg"), "w").write(svg(ad, "#FBF5E8"))
    print(len(LINE), "simge")
