"""Türkçe paketleri için ortak yapı.

Türkçe öğrenme çıktıları beceri alanlarına bağlıdır (Dinleme/İzleme,
Konuşma, Okuma, Yazma). Ölçülebilen çıktılar soru kartlarıyla, Konuşma ve
Yazma gibi uygulama gerektirenler veliyle etkinlik kartlarıyla işlenir.
Metinlerin tamamı özgündür. Pedagojik onay gerekir.
"""

from common import outcome, lesson, page, mc, act, gen, V

T = lambda t: V("text", text=t)


def listen(story, question, options, answer, explain=None, why=None):
    """Dinleme kartı: hikâye sesli okunur; ses kapalıysa ipucunda yazılıdır."""
    return mc(f"🔊 Dinle ve cevapla: {question}", options, answer,
              say=f"{story} Soru: {question}", hint=story, explain=explain,
              visual=T("🔊 Hikâyeyi dinle"), why=why)


def read(text, question, options, answer, explain=None, why=None):
    """Okuma kartı: kısa metin ekranda; soru altında."""
    return mc(f"{text}\n\n{question}", options, answer, explain=explain, why=why)


def build(grade, P):
    """P: sınıfa özgü içerik sözlüğü. Her çıktıya bir anlatım ve kartlar."""
    g = grade
    out = []

    rich = P.get("lessons", {})

    def o(area, n, title, pages, cards):
        # P["lessons"]["D1"] gibi bir girdi varsa ayrıntılı anlatım (ve
        # "farklı yoldan" ikinci anlatım) varsayılan tek sayfanın yerine geçer
        ls = rich.get(f"{area}{n}") or [lesson(title, pages)]
        out.append(outcome(f"T.{area}.{g}.{n}", lessons=ls, cards=cards))

    # --- Dinleme / İzleme ---
    o("D", 1, "İyi bir dinleyici", [
        page("İyi dinleyici konuşana bakar, sözünü kesmez, merak ettiğini sırası gelince sorar.", T("👀 👂 🙋")),
    ], P["d1"])
    o("D", 2, "Dinlediğimi anlıyorum", [
        page("Dinlerken “Kim? Ne yaptı? Nerede? Ne zaman? Neden?” sorularını düşünürüz.", T("❓ kim · ne · nerede · ne zaman")),
    ], P["d2"])
    o("D", 3, "Konuyu bul", [
        page("Bir metnin konusu “Bu metin ne hakkında?” sorusunun cevabıdır.", T("📌 konu")),
    ], P["d3"])
    d_rest = [k for k in ("d4", "d5") if k in P]
    for i, key in enumerate(d_rest, 4):
        o("D", i, "Dinlemeyi değerlendir" if key == d_rest[-1] else "Dinlemeyi etkileyenler", [
            page("Gürültülü bir ortam dinlemeyi zorlaştırır. Dinledikten sonra “Neyi anladım, neyi kaçırdım?” diye düşünürüz.",
                 T("🔇 🤔")),
        ], P[key])

    # --- Konuşma ---
    o("K", 1, "Konuşmamı yönetiyorum", [
        page("Konuşurken dinleyenlere bakar, sıramızı bekler, selamlaşma sözcükleri kullanırız.", T("👋 🗣️")),
    ], P["k1"])
    o("K", 2, "Ne anlatacağım?", [
        page("Anlatacaklarımızı sıraya koyarız: önce, sonra, en son.", T("1️⃣ 2️⃣ 3️⃣")),
    ], P["k2"])
    o("K", 3, "Konuşma kuralları", [
        page("Anlaşılır bir ses tonuyla, ne çok hızlı ne çok yavaş konuşuruz. Sözcükleri doğru söyleriz.", T("🔊 🐢🐇")),
    ], P["k3"])
    k_rest = [k for k in ("k4", "k5") if k in P]
    for i, key in enumerate(k_rest, 4):
        o("K", i, "Konuşmayı etkileyenler" if (key == "k4" and "k5" in P) else "Konuşmamı değerlendiriyorum", [
            page("Konuştuktan sonra düşünürüz: “Anlaşıldım mı? Neyi daha iyi yapabilirim?”", T("🤔 ✅")),
        ], P[key])

    # --- Okuma ---
    o("O", 1, "Okumaya başlıyoruz", P["o1_pages"], P["o1"])
    o("O", 2, "Okuduğumu anlıyorum", [
        page("Okumadan önce başlığa ve resimlere bakıp tahmin ederiz. Okurken bildiklerimizle bağlantı kurarız.", T("🖼️ ➜ 📖")),
    ], P["o2"])
    o("O", 3, "Okuduğumu çözümlüyorum", [
        page("Metnin konusunu ve ana fikrini (bize vermek istediği mesajı) buluruz.", T("📌 konu · 💡 ana fikir")),
    ], P["o3"])
    o_rest = [k for k in ("o4", "o5") if k in P]
    for i, key in enumerate(o_rest, 4):
        o("O", i, "Okumayı etkileyenler" if key == "o4" else "Okumamı değerlendiriyorum", [
            page("Aydınlık ve sessiz bir ortamda, dik oturarak okumak okumayı kolaylaştırır.", T("💡 🤫 🪑")),
        ], P[key])

    # --- Yazma ---
    o("Y", 1, "Yazıya başlıyoruz", P["y1_pages"], P["y1"])
    o("Y", 2, "Yazımda içerik", [
        page("Yazarken ne anlatacağımızı önceden düşünür, cümlelerimizi sıraya koyarız.", T("💭 ➜ ✏️")),
    ], P["y2"])
    o("Y", 3, "Yazma kuralları", [
        page("Cümleye büyük harfle başlar, uygun noktalama işaretiyle bitiririz. Özel adları büyük harfle yazarız.", T("Ali okula gitti.")),
    ], P["y3"])
    y_rest = [k for k in ("y4", "y5") if k in P]
    for i, key in enumerate(y_rest, 4):
        o("Y", i, "Yazmayı etkileyenler" if (key == "y4" and "y5" in P) else "Yazımı değerlendiriyorum", [
            page("Yazdıktan sonra okuruz: harfler doğru mu, boşluklar uygun mu, noktalama tamam mı?", T("🔍 ✏️")),
        ], P[key])
    return out
