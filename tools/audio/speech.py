#!/usr/bin/env python3
"""Uygulamada sesli okunan sabit metinleri toplar ve Google Cloud Text-to-Speech
ile MP3'e çevirir.

    python3 tools/audio/speech.py collect      # assets/audio/manifest.json günceller
    python3 tools/audio/speech.py synthesize   # eksik sesleri üretir (GOOGLE_TTS_API_KEY gerekir)

Dosya adı metnin FNV-1a karmasıdır; uygulama (lib/app/speaker.dart) aynı
karmayı hesaplayıp kayıtlı sesi bulur, bulamazsa cihazın sesini kullanır.
"""
import base64
import glob
import json
import os
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
AUDIO = ROOT / "assets/audio"

# Uygulama kodunda sabit olarak sesli okunan cümleler
UI_PHRASES = [
    "Harika!",
    "Harika! Bugünlük bu kadar.",
    "Harika! Birlikte yaptınız.",
]


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
        pk = json.loads(Path(f).read_text(encoding="utf-8"))
        for o in pk["outcomes"]:
            for l in o["lessons"]:
                for p in l["pages"]:
                    texts.add(p.get("say") or p["text"])
            for c in o["cards"]:
                if c["type"] in ("mc", "act"):
                    texts.add(c.get("say") or c["prompt"])
                    for k in ("explain", "hint"):
                        if c.get(k):
                            texts.add(c[k])
    mapping = {speech_id(t): t.strip() for t in texts if t.strip()}
    AUDIO.mkdir(parents=True, exist_ok=True)
    (ROOT / "tools/audio/texts.json").write_text(
        json.dumps(mapping, ensure_ascii=False, indent=0, sort_keys=True), encoding="utf-8")
    present = sorted(h for h in mapping if (AUDIO / f"{h}.mp3").exists())
    (AUDIO / "manifest.json").write_text(json.dumps(present), encoding="utf-8")
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
        female = [n for n in names if pref in n]
        if female:
            print("ses:", female[0], f"({len(female)} seçenek: {', '.join(female[:6])})")
            return female[0]
    return names[0]


def synthesize():
    key = os.environ.get("GOOGLE_TTS_API_KEY")
    if not key:
        sys.exit("GOOGLE_TTS_API_KEY tanımlı değil: GitHub > Settings > Secrets > Actions")
    mapping = collect()
    voice = pick_voice(key)
    todo = [h for h in mapping if not (AUDIO / f"{h}.mp3").exists()]
    print(f"üretilecek: {len(todo)}")
    for i, h in enumerate(todo, 1):
        body = {
            "input": {"text": mapping[h]},
            "voice": {"languageCode": "tr-TR", "name": voice},
            "audioConfig": {"audioEncoding": "MP3", "speakingRate": 0.92, "sampleRateHertz": 24000},
        }
        req = urllib.request.Request(
            f"https://texttospeech.googleapis.com/v1/text:synthesize?key={key}",
            data=json.dumps(body).encode(), headers={"Content-Type": "application/json"})
        audio = json.loads(urllib.request.urlopen(req, timeout=60).read())["audioContent"]
        (AUDIO / f"{h}.mp3").write_bytes(base64.b64decode(audio))
        if i % 50 == 0:
            print(f"{i}/{len(todo)}")
    collect()


if __name__ == "__main__":
    {"collect": collect, "synthesize": synthesize}[sys.argv[1]]()
