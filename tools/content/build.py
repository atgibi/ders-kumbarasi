#!/usr/bin/env python3
"""Tüm içerik paketlerini doğrular ve assets/content/ altına yazar.

    python3 tools/content/build.py          # yaz
    python3 tools/content/build.py --check  # yalnızca doğrula (CI)

Doğrulananlar: çıktı kodları programda var ve pakete uygun; kart kimlikleri
benzersiz; üreteç adları Dart kodunda tanımlı; görsel türleri biliniyor;
cevap indeksleri geçerli; seçenekler tekrarsız.
"""
import importlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).parent))

PACK_MODULES = sorted(p.stem for p in Path(__file__).parent.glob("*_[1-4].py"))

VISUAL_KINDS = {
    "objects", "objects2", "objects_crossed", "groups", "blocks", "number_highlight",
    "row", "emoji", "text", "compare_groups", "shapes", "money", "pictograph", "tally", "grid",
}


def dart_generators():
    src = (ROOT / "lib/data/generators.dart").read_text(encoding="utf-8")
    block = src[src.index("final Map<String, QuestionGenerator> generators"):]
    return set(re.findall(r"'([a-z_]+)':\s*_", block))


def visual_kinds_in_dart():
    src = (ROOT / "lib/ui/widgets/visual_view.dart").read_text(encoding="utf-8")
    return set(re.findall(r"^\s*'([a-z_0-9]+)' =>", src, re.M))


def check_visual(v, where, errors):
    if v is None:
        return
    if v.get("kind") not in VISUAL_KINDS:
        errors.append(f"{where}: bilinmeyen görsel türü {v.get('kind')}")


def validate(pk, curriculum, gens, errors, warnings):
    subj, grade = pk["ders"], pk["sinif"]
    codes = {r["kod"] for r in curriculum if r["ders"] == subj and r["sinif"] == grade}
    seen_ids = set()
    covered = set()
    for oc in pk["outcomes"]:
        code = oc["kod"]
        if code not in codes:
            errors.append(f"{subj}_{grade}: {code} programda bu ders/sınıf için yok")
        covered.add(code)
        if not oc["cards"]:
            errors.append(f"{code}: kart yok")
        if not oc["lessons"]:
            warnings.append(f"{code}: konu anlatımı yok")
        for l in oc["lessons"]:
            if not l["pages"]:
                errors.append(f"{l['id']}: sayfa yok")
            for i, pg in enumerate(l["pages"]):
                check_visual(pg.get("visual"), f"{l['id']} s{i+1}", errors)
        for c in oc["cards"]:
            cid = c["id"]
            if cid in seen_ids:
                errors.append(f"{cid}: tekrarlanan kimlik")
            seen_ids.add(cid)
            if c["type"] == "gen":
                if c["gen"] not in gens:
                    errors.append(f"{cid}: bilinmeyen üreteç {c['gen']}")
            else:
                opts = c["options"]
                if len(opts) < 2:
                    errors.append(f"{cid}: en az 2 seçenek gerekir")
                if len(set(opts)) != len(opts):
                    errors.append(f"{cid}: tekrarlı seçenek {opts}")
                if not (0 <= c["answer"] < len(opts)):
                    errors.append(f"{cid}: cevap indeksi geçersiz")
                check_visual(c.get("visual"), cid, errors)
        if len(oc["cards"]) < 3:
            warnings.append(f"{code}: yalnızca {len(oc['cards'])} kart")
    missing = sorted(codes - covered)
    return missing


def main():
    check_only = "--check" in sys.argv
    curriculum = json.loads((ROOT / "curriculum/tymm_ciktilar.json").read_text(encoding="utf-8"))
    gens = dart_generators()
    dart_kinds = visual_kinds_in_dart()
    errors, warnings = [], []
    if not VISUAL_KINDS <= dart_kinds:
        errors.append(f"Dart'ta çizilmeyen görsel türleri: {sorted(VISUAL_KINDS - dart_kinds)}")
    out_dir = ROOT / "assets/content"
    report = []
    for mod in PACK_MODULES:
        pk = importlib.import_module(mod).PACK
        missing = validate(pk, curriculum, gens, errors, warnings)
        n_cards = sum(len(o["cards"]) for o in pk["outcomes"])
        n_lessons = sum(len(o["lessons"]) for o in pk["outcomes"])
        report.append(f"{mod:22s} çıktı {len(pk['outcomes']):3d}  anlatım {n_lessons:3d}  kart {n_cards:4d}"
                      + (f"  EKSİK: {', '.join(missing)}" if missing else ""))
        target = out_dir / f"{pk['ders']}_{pk['sinif']}.json"
        text = json.dumps(pk, ensure_ascii=False, separators=(",", ":"))
        if check_only:
            if not target.exists() or target.read_text(encoding="utf-8") != text:
                errors.append(f"{target.name} güncel değil: build.py çalıştırılmalı")
        else:
            out_dir.mkdir(parents=True, exist_ok=True)
            target.write_text(text, encoding="utf-8")
    print("\n".join(report))
    for w in warnings:
        print("UYARI:", w)
    for e in errors:
        print("HATA:", e)
    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
