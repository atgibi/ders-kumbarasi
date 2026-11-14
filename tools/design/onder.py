"""Krallık önderlerini ve Fırıncı Hasan'ı tasarımdan assets/onder altına üretir."""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from svgtpl import render

H = os.path.dirname(__file__)
OUT = os.path.join(H, "..", "..", "assets", "onder")
os.makedirs(OUT, exist_ok=True)
on = lambda c: "inline" if c else "none"
cuce = open(os.path.join(H, "src", "cuce.svg.tpl")).read()
for kim in ("cark", "hasan"):
    for poz in ("dur", "selam"):
        c = kim == "cark"
        v = {"d": {"cark": on(c), "hasan": on(not c), "dur": on(poz == "dur"), "selam": on(poz == "selam"),
                   "gozAcik": on(poz == "dur"), "gozMutlu": on(poz == "selam")},
             "govde": "#A8552B" if c else "#1F4E79", "onluk": "#5E3A1B" if c else "#FBF5E8",
             "sakal": "#F2EEE6" if c else "#7A4D27", "ten": "#D9A07A" if c else "#E3AC82"}
        name = kim + ("" if poz == "dur" else "_selam")
        open(os.path.join(OUT, name + ".svg"), "w").write(render(cuce, v) + "\n")
onder = open(os.path.join(H, "src", "onder.svg.tpl")).read()
for kim in ("yaprak", "pelin", "dokum", "elif"):
    v = {"d": {k: on(k == kim) for k in ("yaprak", "pelin", "dokum", "elif")}}
    open(os.path.join(OUT, kim + ".svg"), "w").write(render(onder, v) + "\n")
print(sorted(os.listdir(OUT)))
