"""Anka'nın beş hâlini tasarımdan assets/mascot altına üretir."""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from svgtpl import render

H = os.path.dirname(__file__)
OUT = os.path.join(H, "..", "..", "assets", "mascot")
tpl = open(os.path.join(H, "src", "anka.svg.tpl")).read()


def vals(h):
    on = lambda c: "inline" if c else "none"
    return {"d": {
        "tepe": on(h != "uykulu"),
        "ksd": on(h in ("normal", "uykulu", "ogreten")),
        "ssd": on(h in ("normal", "uykulu", "dusunen")),
        "kalk": on(h == "kutlama"), "kc": on(h == "dusunen"), "si": on(h == "ogreten"),
        "uyku": on(h == "uykulu"), "dusun": on(h == "dusunen"),
        "agizAcik": on(h in ("kutlama", "ogreten")), "agizKapali": on(h not in ("kutlama", "ogreten")),
        "gozNormal": on(h in ("normal", "ogreten")), "gozMutlu": on(h == "kutlama"),
        "gozYukari": on(h == "dusunen"), "gozKapali": on(h == "uykulu"),
        "gozlukNormal": on(h in ("normal", "kutlama", "dusunen")),
        "gozlukYukari": on(h == "ogreten"), "gozlukUyku": on(h == "uykulu"),
    }}


for h, name in [("normal", "anka"), ("kutlama", "anka_kutlama"), ("dusunen", "anka_dusunen"),
                ("uykulu", "anka_uykulu"), ("ogreten", "anka_ogreten")]:
    open(os.path.join(OUT, name + ".svg"), "w").write(render(tpl, vals(h)) + "\n")
    print(name)
