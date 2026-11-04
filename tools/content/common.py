"""İçerik paketleri için yardımcılar. Kartlara kimlik otomatik verilir:
<çıktı kodu>#<içerik karması>. Kartların sırası serbestçe değiştirilebilir.
"""
import hashlib
import json


def V(kind, **params):
    return {"kind": kind, **params}


def page(text, visual=None, say=None):
    d = {"text": text}
    if visual is not None:
        d["visual"] = visual
    if say is not None:
        d["say"] = say
    return d


def lesson(title, pages, alt=False):
    """alt=True: "farklı yoldan" ikinci anlatım (oturumda kendiliğinden
    gösterilmez; zorlanan çocuk için)."""
    d = {"title": title, "pages": pages}
    if alt:
        d["alt"] = True
    return d


def mc(prompt, options, answer, *, say=None, visual=None, explain=None, hint=None, fast=None, why=None):
    """why: yanlış seçeneklere özel açıklama, {seçenek sırası: metin}.
    Her çeldirici gerçek bir kavram yanılgısından gelmeli."""
    d = {"type": "mc", "prompt": prompt, "options": options, "answer": answer}
    if why is not None:
        if answer in why:
            raise ValueError(f"Doğru seçeneğe yanılgı notu yazılmaz: {prompt}")
        why = {str(k): v for k, v in why.items()}
    for k, v in (("say", say), ("visual", visual), ("explain", explain), ("hint", hint), ("fast", fast), ("why", why)):
        if v is not None:
            d[k] = v
    return d


def act(prompt, *, say=None, visual=None):
    """Veliyle birlikte yapılan etkinlik kartı (puanlanmaz)."""
    d = {"type": "act", "prompt": prompt}
    if say is not None:
        d["say"] = say
    if visual is not None:
        d["visual"] = visual
    return d


def gen(name, fast=None, **params):
    d = {"type": "gen", "gen": name, "params": params}
    if fast is not None:
        d["fast"] = fast
    return d


def card_id(code, card, taken):
    """Kart kimliği içerikten türetilir: kartların sırası değişse ya da araya
    kart eklense de çocuğun o karttaki tekrar geçmişi korunur. Kartın metni
    değişirse yeni kart sayılır (eski geçmiş artık o soruya ait değildir)."""
    body = {k: v for k, v in card.items() if k != "id"}
    digest = hashlib.sha1(
        json.dumps(body, ensure_ascii=False, sort_keys=True).encode("utf-8")).hexdigest()
    cid = f"{code}#{digest[:8]}"
    n = 2
    while cid in taken:  # aynı kart iki kez yazılmışsa
        cid = f"{code}#{digest[:8]}-{n}"
        n += 1
    taken.add(cid)
    return cid


def outcome(code, lessons, cards):
    for i, l in enumerate(lessons, 1):
        l["id"] = f"{code}/L{i}"
    taken = set()
    for c in cards:
        c["id"] = card_id(code, c, taken)
    return {"kod": code, "lessons": lessons, "cards": cards}


def pack(subject, grade, outcomes):
    return {"ders": subject, "sinif": grade, "outcomes": outcomes}


def _pg(x):
    if isinstance(x, tuple):
        return page(x[0], x[1]) if len(x) == 2 else page(x[0], x[1], say=x[2])
    return page(x)


def seven(title, hook, concrete, picture, rule, example, caution, summary, alt=None, alt_title=None):
    """Yedi adımlı konu anlatımı: hikâye kancası, somut, görsel, kural,
    örnek çözüm, dikkat, özet. Her öğe metin ya da (metin, görsel).
    alt: "farklı yoldan" ikinci anlatımın sayfaları (isteğe bağlı)."""
    ls = [lesson(title, [_pg(p) for p in (hook, concrete, picture, rule, example, caution, summary)])]
    if alt:
        ls.append(lesson(alt_title or f"{title}: başka bir yoldan", [_pg(p) for p in alt], alt=True))
    return ls
