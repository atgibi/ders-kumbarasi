"""İçerik paketleri için yardımcılar. Kartlara kimlik otomatik verilir:
<çıktı kodu>#<sıra>. Sıra değişirse öğrencinin ilerlemesi kaybolur; yeni kart
eklerken listenin SONUNA ekleyin.
"""


def V(kind, **params):
    return {"kind": kind, **params}


def page(text, visual=None, say=None):
    d = {"text": text}
    if visual is not None:
        d["visual"] = visual
    if say is not None:
        d["say"] = say
    return d


def lesson(title, pages):
    return {"title": title, "pages": pages}


def mc(prompt, options, answer, *, say=None, visual=None, explain=None, hint=None, fast=None):
    d = {"type": "mc", "prompt": prompt, "options": options, "answer": answer}
    for k, v in (("say", say), ("visual", visual), ("explain", explain), ("hint", hint), ("fast", fast)):
        if v is not None:
            d[k] = v
    return d


def gen(name, fast=None, **params):
    d = {"type": "gen", "gen": name, "params": params}
    if fast is not None:
        d["fast"] = fast
    return d


def outcome(code, lessons, cards):
    for i, l in enumerate(lessons, 1):
        l["id"] = f"{code}/L{i}"
    for i, c in enumerate(cards, 1):
        c["id"] = f"{code}#{i}"
    return {"kod": code, "lessons": lessons, "cards": cards}


def pack(subject, grade, outcomes):
    return {"ders": subject, "sinif": grade, "outcomes": outcomes}
