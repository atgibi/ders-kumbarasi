#!/usr/bin/env python3
"""TYMM öğretim programı metinlerinden (pdftotext -layout çıktısı) öğrenme
çıktılarını ve süreç bileşenlerini çıkarır.

Kullanım:
    python3 tools/parse_programs.py <txt_klasörü> <çıktı.json>

Uygulamanın parçası değildir; müfredat eşlemesi için geliştirme aracıdır.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

# Ders -> (dosya öneki, kod deseni, dahil edilecek sınıflar)
DERSLER = {
    "turkce": ("ilkokul-turkce-dersi", r"T\.[DKOY]\.(\d)\.(\d+)\.", (1, 2, 3, 4)),
    "matematik": ("ilkokul-matematik-dersi", r"MAT\.(\d)\.(\d+)\.(\d+)\.", (1, 2, 3, 4)),
    "hayat_bilgisi": ("hayat-bilgisi-dersi", r"HB\.(\d)\.(\d+)\.(\d+)\.", (1, 2, 3)),
    "fen_bilimleri": ("fen-bilimleri-dersi", r"FB\.(\d)\.(\d+)\.(\d+)\.", (3, 4)),
    "sosyal_bilgiler": ("sosyal-bilgiler-dersi", r"SB\.(\d)\.(\d+)\.(\d+)\.", (4,)),
}

TURKCE_ALAN = {"D": "Dinleme/İzleme", "K": "Konuşma", "O": "Okuma", "Y": "Yazma"}

ITEM_RE = re.compile(r"^\s*([a-zçğıöşü])\)\s+(.*)$")
# Sol sütundaki etiketler (layout çıktısında satır başına yapışır)
LEFT_LABELS = re.compile(
    r"^\s*(ÖĞRENME ÇIKTILARI(\s+VE)?|VE SÜREÇ BİLEŞENLERİ|SÜREÇ BİLEŞENLERİ)\s*"
)
STOP_RE = re.compile(
    r"İÇERİK ÇERÇEVESİ|Anahtar Kavramlar|ÖĞRENME\s*$|KANITLARI|Ölçme ve|"
    r"ÖĞRETİM PROGRAMI\s*$|^\s*\d+\s*$|DERSİ \(|EK \d|^\s*\d\. SINIF"
)


def clean(s: str) -> str:
    s = re.sub(r"\s+", " ", s).strip()
    # satır sonu tirelemesi: "terimle- riyle" -> "terimleriyle"
    s = re.sub(r"(\w)- (\w)", r"\1\2", s)
    return s


def parse(text: str, code_pat: str, ders: str, siniflar: tuple[int, ...]):
    code_re = re.compile(r"(" + code_pat + r")\s*(.*)$")
    out: dict[str, dict] = {}
    cur = None
    mode = None  # "title" | "item"
    for raw in text.splitlines():
        line = LEFT_LABELS.sub("", raw)
        m = code_re.search(line)
        if m:
            code = m.group(1).rstrip(".")
            grade = int(m.group(2))
            if grade not in siniflar:
                cur = None
                continue
            rest = m.group(m.lastindex)
            # Aynı kod birden çok yerde geçebilir (tanım kutuları, özet tablolar).
            # Her geçişi aday olarak topla; en temiz olan sonra seçilir.
            cur = {"kod": code, "sinif": grade, "baslik": rest, "surec": []}
            out.setdefault(code, []).append(cur)
            mode = "title"
            continue
        if cur is None:
            continue
        if STOP_RE.search(line):
            cur = None
            continue
        im = ITEM_RE.match(line)
        if im:
            cur["surec"].append(im.group(2))
            mode = "item"
            continue
        if not line.strip():
            continue
        # devam satırı
        if mode == "title":
            cur["baslik"] += " " + line.strip()
        elif mode == "item" and cur["surec"]:
            cur["surec"][-1] += " " + line.strip()

    def score(c):
        bad = re.search(r"ÖĞRENME|SÜREÇ|BİLEŞEN|ÇIKTILARI", c["baslik"] + " ".join(c["surec"]))
        return (0 if bad else 1, len(c["surec"]), -len(c["baslik"]))

    result = []
    for cands in out.values():
        c = max(cands, key=score)
        c["baslik"] = clean(c["baslik"])
        c["surec"] = [clean(s) for s in c["surec"]]
        parts = c["kod"].split(".")
        if ders == "turkce":
            c["alan"] = TURKCE_ALAN[parts[1]]
            c["unite"] = None
        else:
            c["unite"] = int(parts[2])
        c["ders"] = ders
        result.append(c)

    def key(c):
        nums = [int(p) if p.isdigit() else p for p in c["kod"].split(".")]
        return [str(n) if isinstance(n, str) else f"{n:04d}" for n in nums]

    result.sort(key=key)
    return result


def main():
    src, dst = Path(sys.argv[1]), Path(sys.argv[2])
    all_rows = []
    for ders, (prefix, pat, siniflar) in DERSLER.items():
        files = sorted(src.glob(prefix + "*.txt"))
        if not files:
            print(f"UYARI: {ders} için dosya yok", file=sys.stderr)
            continue
        rows = parse(files[0].read_text(encoding="utf-8"), pat, ders, siniflar)
        all_rows.extend(rows)
        by_grade: dict[int, int] = {}
        for r in rows:
            by_grade[r["sinif"]] = by_grade.get(r["sinif"], 0) + 1
        empty_title = sum(1 for r in rows if not r["baslik"])
        print(f"{ders:16s} {dict(sorted(by_grade.items()))}  başlıksız={empty_title}")
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(json.dumps(all_rows, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"toplam {len(all_rows)} çıktı -> {dst}")


if __name__ == "__main__":
    main()
