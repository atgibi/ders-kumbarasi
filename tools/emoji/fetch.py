"""İçerikte ve kodda geçen emojileri bulur, Twemoji SVG'lerini assets/emoji/ altına indirir.

Twemoji: (c) Twitter, Inc ve katkıda bulunanlar, grafikler CC-BY 4.0.
Emojiler uygulamayla birlikte gelir; böylece eski Android sürümlerinde kutucuk
çıkmaz ve her cihazda aynı görünür.

Kullanım:  python3 tools/emoji/fetch.py          (eksikleri indir)
           python3 tools/emoji/fetch.py --check  (eksik varsa hata ver, ağ yok)
"""
import glob
import json
import os
import sys
import urllib.request

import regex

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, 'assets', 'emoji')
BASE = 'https://raw.githubusercontent.com/jdecked/twemoji/v16.0.1/assets/svg/'

EMOJI_RE = regex.compile(r'\p{Extended_Pictographic}|\p{Regional_Indicator}')


def file_name(cluster: str) -> str:
    """Twemoji dosya adı: ZWJ içermeyen dizilerde FE0F atılır."""
    cps = [ord(c) for c in cluster]
    if 0x200D not in cps:
        cps = [c for c in cps if c != 0xFE0F]
    return '-'.join(f'{c:x}' for c in cps)


def clusters_in(text: str):
    for g in regex.findall(r'\X', text):
        if EMOJI_RE.search(g):
            yield g


def collect():
    found = set()
    files = glob.glob(os.path.join(ROOT, 'assets', 'content', '*.json'))
    files += glob.glob(os.path.join(ROOT, 'lib', '**', '*.dart'), recursive=True)
    for f in files:
        with open(f, encoding='utf-8') as fh:
            for g in clusters_in(fh.read()):
                found.add(g)
    return found


def main():
    check = '--check' in sys.argv
    os.makedirs(OUT, exist_ok=True)
    needed = {}
    for g in collect():
        needed[file_name(g)] = g
    have = {os.path.splitext(n)[0] for n in os.listdir(OUT) if n.endswith('.svg')}
    missing = sorted(set(needed) - have)
    unavailable = []
    if check:
        # Twemoji'de olmayanlar (ör. ok işaretleri) metin olarak çizilir; liste dosyada
        known_missing = set()
        p = os.path.join(OUT, 'unavailable.json')
        if os.path.exists(p):
            known_missing = set(json.load(open(p, encoding='utf-8')))
        real = [m for m in missing if m not in known_missing]
        if real:
            print('Eksik emoji görselleri:', ' '.join(needed[m] for m in real))
            print('Çalıştırın: python3 tools/emoji/fetch.py')
            sys.exit(1)
        print(f'Emoji: {len(needed)} farklı emoji, hepsi hazır.')
        return
    for name in missing:
        try:
            with urllib.request.urlopen(BASE + name + '.svg', timeout=20) as r:
                data = r.read()
            with open(os.path.join(OUT, name + '.svg'), 'wb') as fh:
                fh.write(data)
        except Exception:  # Twemoji'de yok: metin olarak kalır
            unavailable.append(name)
    p = os.path.join(OUT, 'unavailable.json')
    old = set(json.load(open(p, encoding='utf-8'))) if os.path.exists(p) else set()
    with open(p, 'w', encoding='utf-8') as fh:
        json.dump(sorted(old | set(unavailable)), fh, indent=0)
    # Uygulamanın hangi emojinin görseli olduğunu bilmesi için liste
    names = sorted(os.path.splitext(n)[0] for n in os.listdir(OUT) if n.endswith('.svg'))
    with open(os.path.join(ROOT, 'lib', 'ui', 'widgets', 'emoji_names.g.dart'), 'w', encoding='utf-8') as fh:
        fh.write('// tools/emoji/fetch.py tarafından üretildi; elle düzenlemeyin.\n')
        fh.write('const Set<String> twemojiNames = {\n')
        for n in names:
            fh.write(f"  '{n}',\n")
        fh.write('};\n')
    print(f'{len(needed)} emoji, {len(missing) - len(unavailable)} indirildi, '
          f'{len(unavailable)} Twemoji\'de yok: {" ".join(needed[u] for u in unavailable)}')


if __name__ == '__main__':
    main()
