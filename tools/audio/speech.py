#!/usr/bin/env python3
"""Uygulamada sesli okunan sabit metinleri toplar ve Google Cloud Text-to-Speech
ile MP3'e çevirir.

    python3 tools/audio/speech.py collect      # metin listesini günceller
    python3 tools/audio/speech.py synthesize   # eksik sesleri üretir (GOOGLE_TTS_API_KEY gerekir)
    python3 tools/audio/speech.py pack         # uygulamaya gömülü ve indirilecek paketleri yazar

Sesler depoda audio/ klasöründe durur (uygulamaya gömülmez). Uygulamayla
yalnızca sabit ekran cümleleri gelir (assets/audio_ui). Ders sesleri sınıf
sınıf paketlenir (dist/ses-<sınıf>.bin) ve GitHub Releases'tan bir kez indirilir
(lib/app/audio_packs.dart).

Dosya adı metnin FNV-1a karmasıdır; uygulama (lib/app/speaker.dart) aynı
karmayı hesaplayıp kayıtlı sesi bulur, bulamazsa cihazın sesini kullanır.
"""
import base64
import glob
import json
import os
import re
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
AUDIO = ROOT / "audio"
UI_AUDIO = ROOT / "assets/audio_ui"
DIST = ROOT / "dist"

# Uygulama kodunda sabit olarak sesli okunan cümleler
UI_PHRASES = [
    # Geri bildirim (lib/ui/screens/session_screen.dart)
    "Harika!",
    "Tam isabet!",
    "Dikkatle düşündün!",
    "Harika! Birlikte yaptınız.",
    "Bugün çok çalıştın!",
    "Doğrusu:",
    # Sabit ekran metinleri
    "Kim çalışacak?",
    "Fındık uyuyor. Sabah görüşürüz!",
    "Bugünlük süremiz bitti. Yarın devam!",
    "Bugünlük bu kadar!",
    "Bugünlük bu kadar! Yarın görüşürüz.",
    "Şu an yapılacak bir şey yok",
    "Bu ders şu an açılamadı",
]


# Sesli okunmayan işaretler: emoji, ok, kutu, şekil (lib/app/speaker.dart ile aynı)
_SYMBOL_RANGES = (
    (0x200D, 0x200D), (0x2190, 0x21FF), (0x2300, 0x23FF), (0x25A0, 0x25FF),
    (0x2600, 0x27BF), (0x2900, 0x297F), (0x2B00, 0x2BFF), (0xFE00, 0xFE0F),
    (0x1F000, 0x1FAFF), (0xE0000, 0xE007F),
)


def _is_symbol(cp: int) -> bool:
    return any(a <= cp <= b for a, b in _SYMBOL_RANGES)


def speakable(text: str) -> str:
    """Sesli okunacak hale getirir: emoji ve işaretler atılır, boşluk çizgileri
    duraklamaya çevrilir, boşluklar sadeleşir."""
    s = "".join(" " if _is_symbol(ord(ch)) else ch for ch in text)
    s = re.sub(r"_{2,}", " ... ", s)
    s = re.sub(r"\s+", " ", s)
    return s.strip()


def fnv32(data: bytes, offset: int) -> int:
    h = offset
    for b in data:
        h ^= b
        h = (h * 16777619) & 0xFFFFFFFF
    return h


def speech_id(text: str) -> str:
    """İki farklı başlangıçlı 32 bitlik FNV-1a: 16 haneli onaltılık kimlik."""
    data = text.strip().encode("utf-8")
    return f"{fnv32(data, 0x811C9DC5):08x}{fnv32(data, 0x01000193):08x}"


def collect() -> dict:
    texts = set(UI_PHRASES)
    for f in sorted(glob.glob(str(ROOT / "assets/content/*.json"))):
        texts |= _texts_of(json.loads(Path(f).read_text(encoding="utf-8")))
    spoken = {speakable(t) for t in texts}
    mapping = {speech_id(t): t for t in spoken if t}
    AUDIO.mkdir(parents=True, exist_ok=True)
    (ROOT / "tools/audio/texts.json").write_text(
        json.dumps(mapping, ensure_ascii=False, indent=0, sort_keys=True), encoding="utf-8")
    present = sorted(h for h in mapping if (AUDIO / f"{h}.mp3").exists())
    chars = sum(len(t) for t in mapping.values())
    print(f"{len(mapping)} metin, {chars} karakter; kayıtlı ses: {len(present)}")
    return mapping


def pick_voice(key: str) -> str:
    want = os.environ.get("TTS_VOICE")
    if want:
        return want
    url = f"https://texttospeech.googleapis.com/v1/voices?languageCode=tr-TR&key={key}"
    voices = json.loads(urllib.request.urlopen(url, timeout=30).read())["voices"]
    names = [v["name"] for v in voices]
    for pref in ("Chirp3-HD", "Neural2", "Wavenet"):
        found = [n for n in names if pref in n]
        if not found:
            continue
        # Chirp 3 HD'de sıcak, anlaşılır kadın sesleri önce
        for warm in ("Kore", "Aoede", "Leda", "Zephyr"):
            for n in found:
                if n.endswith(warm):
                    print("ses:", n, f"({len(found)} seçenek)")
                    return n
        print("ses:", found[0], f"({len(found)} seçenek: {', '.join(found[:6])})")
        return found[0]
    return names[0]


def _post(req):
    """Kota (429) ya da sunucu hatasında bekleyip yeniden dener."""
    import time
    import urllib.error
    for attempt in range(6):
        try:
            return json.loads(urllib.request.urlopen(req, timeout=60).read())
        except urllib.error.HTTPError as e:
            if e.code not in (429, 500, 502, 503, 504) or attempt == 5:
                raise
            time.sleep(2 ** attempt * 5)
        except (urllib.error.URLError, TimeoutError):
            if attempt == 5:
                raise
            time.sleep(10)


def synthesize():
    key = os.environ.get("GOOGLE_TTS_API_KEY")
    if not key:
        sys.exit("GOOGLE_TTS_API_KEY tanımlı değil: GitHub > Settings > Secrets > Actions")
    mapping = collect()
    voice = pick_voice(key)
    todo = [h for h in mapping if not (AUDIO / f"{h}.mp3").exists()]
    print(f"üretilecek: {len(todo)}")

    def one(h):
        body = {
            "input": {"text": mapping[h]},
            "voice": {"languageCode": "tr-TR", "name": voice},
            "audioConfig": {"audioEncoding": "MP3", "speakingRate": 0.92, "sampleRateHertz": 24000},
        }
        req = urllib.request.Request(
            f"https://texttospeech.googleapis.com/v1/text:synthesize?key={key}",
            data=json.dumps(body).encode(), headers={"Content-Type": "application/json"})
        audio = _post(req)["audioContent"]
        (AUDIO / f"{h}.mp3").write_bytes(base64.b64decode(audio))

    # Paralel istek: 6.000+ ses tek tek saatler sürer; kota hatasında _post bekler
    from concurrent.futures import ThreadPoolExecutor, as_completed
    failed = 0
    with ThreadPoolExecutor(max_workers=int(os.environ.get("TTS_WORKERS", "6"))) as ex:
        futs = [ex.submit(one, h) for h in todo]
        for i, f in enumerate(as_completed(futs), 1):
            try:
                f.result()
            except Exception as e:  # noqa: BLE001
                failed += 1
                if failed <= 5:
                    print("hata:", e)
            if i % 200 == 0:
                print(f"{i}/{len(todo)}", flush=True)
    print(f"bitti: {len(todo) - failed} üretildi, {failed} hata")
    collect()
    if failed:
        sys.exit(1)


def _texts_of(pack: dict) -> set:
    texts = set()
    for o in pack["outcomes"]:
        for l in o["lessons"]:
            for p in l["pages"]:
                texts.add(p.get("say") or p["text"])
        for c in o["cards"]:
            if c["type"] in ("mc", "act"):
                texts.add(c.get("say") or c["prompt"])
                for k in ("explain", "hint"):
                    if c.get(k):
                        texts.add(c[k])
            if c["type"] == "mc":
                # Şıklar dokununca, "neden yanlış" notları geri bildirimde okunur
                texts.update(c["options"])
                w = c.get("why")
                texts.update(v for v in (w.values() if isinstance(w, dict) else (w or [])) if v)
    return {speakable(t) for t in texts if speakable(t)}


def pack():
    """assets/audio_ui: uygulamayla gelen ekran cümleleri.
    dist/ses-<sınıf>.bin: o sınıfın ders sesleri; dist/ses.json: paket listesi.

    Paket biçimi (bağımlılıksız, lib/app/audio_packs.dart okur):
      'DKSES1' + kayıt sayısı (4 bayt, büyük uçlu) +
      her kayıt: 16 haneli kimlik (ASCII) + uzunluk (4 bayt) + MP3 baytları
    """
    import hashlib
    import shutil
    import struct
    collect()
    # 1) Ekran cümleleri uygulamaya gömülür
    if UI_AUDIO.exists():
        shutil.rmtree(UI_AUDIO)
    UI_AUDIO.mkdir(parents=True)
    ui = []
    for t in UI_PHRASES:
        h = speech_id(speakable(t))
        src = AUDIO / f"{h}.mp3"
        if src.exists():
            shutil.copy(src, UI_AUDIO / f"{h}.mp3")
            ui.append(h)
    (UI_AUDIO / "manifest.json").write_text(json.dumps(sorted(ui)), encoding="utf-8")
    # 2) Sınıf paketleri
    by_grade = {}
    for f in sorted(glob.glob(str(ROOT / "assets/content/*.json"))):
        g = int(Path(f).stem.rsplit("_", 1)[1])
        by_grade.setdefault(g, set()).update(
            speech_id(t) for t in _texts_of(json.loads(Path(f).read_text(encoding="utf-8"))))
    DIST.mkdir(exist_ok=True)
    index = {"format": 1, "grades": {}}
    for g, ids in sorted(by_grade.items()):
        ids = sorted(h for h in ids if (AUDIO / f"{h}.mp3").exists())
        out = DIST / f"ses-{g}.bin"
        sha = hashlib.sha256()
        with open(out, "wb") as w:
            w.write(b"DKSES1" + struct.pack(">I", len(ids)))
            for h in ids:
                data = (AUDIO / f"{h}.mp3").read_bytes()
                rec = h.encode("ascii") + struct.pack(">I", len(data)) + data
                w.write(rec)
                sha.update(rec)
        index["grades"][str(g)] = {
            "file": out.name, "count": len(ids), "bytes": out.stat().st_size,
            "version": sha.hexdigest()[:16],
        }
        print(f"{out.name}: {len(ids)} ses, {out.stat().st_size / 1e6:.1f} MB")
    (DIST / "ses.json").write_text(json.dumps(index, indent=1), encoding="utf-8")
    print(f"ekran cümleleri: {len(ui)} (assets/audio_ui)")


if __name__ == "__main__":
    {"collect": collect, "synthesize": synthesize, "pack": pack}[sys.argv[1]]()
