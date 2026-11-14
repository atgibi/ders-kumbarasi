"""Yumuşak efekt seslerini üretir (assets/sfx). Sinüs + hafif üst ses,
yumuşak giriş ve uzun sönüm: tınlayan marimba/çan hissi, sert vuruş yok.

    python3 tools/sfx/make.py     (ffmpeg gerekir)
"""
import math
import pathlib
import struct
import subprocess
import wave

OUT = pathlib.Path(__file__).resolve().parents[2] / "assets/sfx"
SR = 44100


def tone(freq, dur, vol=0.5, attack=0.02, decay=4.0):
    n = int(SR * dur)
    out = []
    for i in range(n):
        t = i / SR
        env = min(1.0, t / attack) * math.exp(-decay * t)
        s = math.sin(2 * math.pi * freq * t) + 0.25 * math.sin(4 * math.pi * freq * t) \
            + 0.08 * math.sin(6 * math.pi * freq * t)
        out.append(vol * env * s / 1.33)
    return out


def mix(parts, total):
    buf = [0.0] * int(SR * total)
    for start, samples in parts:
        o = int(SR * start)
        for i, v in enumerate(samples):
            if o + i < len(buf):
                buf[o + i] += v
    peak = max(1e-9, max(abs(v) for v in buf))
    k = min(1.0, 0.7 / peak)
    return [v * k for v in buf]


def save(name, buf):
    OUT.mkdir(parents=True, exist_ok=True)
    wav = OUT / f"{name}.wav"
    with wave.open(str(wav), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(b"".join(struct.pack("<h", int(v * 32767)) for v in buf))
    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", str(wav), "-b:a", "64k",
                    str(OUT / f"{name}.mp3")], check=True)
    wav.unlink()


C5, D5, E5, G5, A5, C6, E6 = 523.25, 587.33, 659.25, 783.99, 880.0, 1046.5, 1318.5
G4, E4 = 392.0, 329.63

# Doğru: iki notalı yumuşak yükseliş
save("dogru", mix([(0, tone(E5, .5, .5)), (.11, tone(A5, .7, .5))], .9))
# Yanlış: alçak, tek, pes bir "tık" (ceza hissi yok)
save("yanlis", mix([(0, tone(G4, .35, .35, decay=7)), (.09, tone(E4, .45, .3, decay=6))], .6))
# Dokunma: çok kısa, hafif
save("dokun", mix([(0, tone(C6, .12, .18, attack=.004, decay=30))], .14))
# Kutlama: yükselen arpej + parıltı
save("kutlama", mix([(0, tone(C5, .9, .4)), (.12, tone(E5, .9, .4)), (.24, tone(G5, .9, .4)),
                     (.38, tone(C6, 1.4, .45, decay=2.5)), (.52, tone(E6, 1.2, .25, decay=3))], 2.0))
print("assets/sfx yazıldı")
