"""1. sınıf Matematik içerik paketi (TYMM MAT.1.x.x).

Çalıştırma: python3 tools/content/build.py   (tüm paketleri assets/content'e yazar)

Not: Sabit sorular ve anlatım metinleri bir sınıf öğretmeninin pedagojik
onayından geçmelidir (proje planı 5.6, adım 3).
"""

from common import pack, outcome, lesson, page, mc, gen, V

OUTCOMES = [
    outcome(
        "MAT.1.1.1",
        lessons=[
            lesson("Sayılar ve rakamlar", [
                page("Etrafımızdaki her şeyi sayabiliriz. Burada kaç elma var? Tek tek sayalım: bir, iki, üç!",
                     V("objects", emoji="🍎", count=3)),
                page("Kaç tane olduğunu rakamla yazarız. Üç elmayı 3 rakamıyla gösteririz.",
                     V("text", text="🍎🍎🍎 = 3")),
                page("Sayılar 20'ye kadar devam eder. 10'dan sonra 11, 12, 13 diye sayarız. "
                     "Haydi sen de say!", V("objects", emoji="⭐", count=12)),
            ]),
        ],
        cards=[
            gen("count_objects", max=5),
            gen("count_objects", min=4, max=10),
            gen("count_objects", min=8, max=15),
            gen("count_objects", min=11, max=20),
            mc("Hangisi “yedi” sayısıdır?", ["7", "1", "9"], 0, say="Hangisi yedi sayısı?"),
            mc("Hangisi “on iki” sayısıdır?", ["21", "12", "2"], 1, say="Hangisi on iki sayısı?",
               explain="On iki: bir onluk ve iki birlik, 12 diye yazılır."),
            mc("Hangisi “on dokuz” sayısıdır?", ["9", "91", "19"], 2, say="Hangisi on dokuz sayısı?"),
            mc("İki elimizde toplam kaç parmak var?", ["5", "10", "20"], 1,
               visual=V("text", text="🖐️🖐️"), explain="Bir elimizde 5, iki elimizde 10 parmak var."),
        ],
    ),
    outcome(
        "MAT.1.1.2",
        lessons=[
            lesson("Parçalarla saymak", [
                page("Bazen nesneler dağınık durur. Saymak için onları gruplara ayırırız.",
                     V("objects2", emoji="🐟", a=3, b=4)),
                page("Burada 3 balık ve 4 balık var. İki parçayı birlikte sayınca 7 balık eder.",
                     V("objects2", emoji="🐟", a=3, b=4)),
                page("Beşerli gruplar saymayı kolaylaştırır: 5 ve 2 daha, 7 eder.",
                     V("objects2", emoji="⭐", a=5, b=2)),
            ]),
        ],
        cards=[
            gen("add", max_sum=10, carry=False),
            gen("missing_addend", max_sum=10),
            mc("5 ve 3 birlikte kaç eder?", ["8", "7", "9"], 0, visual=V("objects2", emoji="🍐", a=5, b=3)),
            mc("Toplam 6 top var. 4'ü sepette. Kaç tanesi dışarıda?", ["3", "2", "10"], 1,
               visual=V("objects", emoji="⚽", count=6), explain="4 ve 2 birlikte 6 eder."),
            mc("10 yıldızı iki eşit gruba ayırırsak her grupta kaç yıldız olur?", ["5", "4", "6"], 0,
               visual=V("objects", emoji="⭐", count=10)),
        ],
    ),
    outcome(
        "MAT.1.1.3",
        lessons=[
            lesson("Birinci, ikinci, üçüncü", [
                page("Sıraya girdiğimizde kimin kaçıncı olduğunu söyleriz: birinci, ikinci, üçüncü…",
                     V("row", items=["🐢", "🐇", "🐕", "🐈"])),
                page("Soldan sayalım: kaplumbağa birinci, tavşan ikinci, köpek üçüncü, kedi dördüncü.",
                     V("row", items=["🐢", "🐇", "🐕", "🐈"])),
            ]),
        ],
        cards=[
            gen("ordinal", max=4),
            gen("ordinal", max=6),
            mc("Yarışta en önce gelen kaçıncı olur?", ["Birinci", "Sonuncu", "İkinci"], 0),
            mc("Üç arkadaş sırada. Ortadaki kaçıncıdır?", ["Birinci", "İkinci", "Üçüncü"], 1,
               visual=V("row", items=["🧒", "👧", "👦"])),
        ],
    ),
    outcome(
        "MAT.1.1.4",
        lessons=[
            lesson("Çok mu az mı?", [
                page("İki grubu karşılaştırırken “daha çok”, “daha az” ya da “eşit” deriz.",
                     V("compare_groups", a=5, b=2, ea="🍎", eb="🍐")),
                page("Burada elmalar daha çok, armutlar daha az.", V("compare_groups", a=5, b=2, ea="🍎", eb="🍐")),
                page("Sayıları aynıysa “eşit” deriz: 3 balon ve 3 top.", V("compare_groups", a=3, b=3, ea="🎈", eb="⚽")),
            ]),
        ],
        cards=[
            gen("compare_groups", max=6),
            gen("compare_groups", max=10),
            gen("compare", max=20),
            mc("4 kalem ile 4 silgi için ne deriz?", ["Kalemler daha çok", "Eşit", "Silgiler daha çok"], 1),
        ],
    ),
    outcome(
        "MAT.1.1.5",
        lessons=[
            lesson("Ritmik sayma", [
                page("İkişer ikişer sayalım: 2, 4, 6, 8, 10. Her seferinde 2 ekliyoruz.", V("text", text="2 · 4 · 6 · 8 · 10")),
                page("Onar onar sayalım: 10, 20, 30, 40… 100'e kadar gidebiliriz!", V("text", text="10 · 20 · 30 · 40")),
                page("Geriye de sayabiliriz: 20, 19, 18, 17… Her seferinde 1 azalır.", V("text", text="20 · 19 · 18 · 17")),
            ]),
        ],
        cards=[
            gen("skip_count", steps=[2]),
            gen("skip_count", steps=[5]),
            gen("skip_count", steps=[10]),
            gen("count_back", **{"from": 20}),
            gen("count_back", **{"from": 12}),
        ],
    ),
    outcome(
        "MAT.1.1.6",
        lessons=[
            lesson("Örüntüler", [
                page("Örüntü, belli bir kurala göre tekrar eden dizidir.", V("text", text="🔴🔵🔴🔵🔴🔵")),
                page("Bu örüntüde kırmızı ve mavi sırayla geliyor. Sıradaki kırmızı olur!", V("text", text="🔴🔵🔴🔵🔴 ?")),
                page("Sayılarla da örüntü yaparız: 3, 4, 5, 6… her seferinde 1 artıyor.", V("text", text="3 · 4 · 5 · 6 · ?")),
            ]),
        ],
        cards=[
            mc("🔴🔵🔴🔵🔴 ? Sıradaki hangisi?", ["🔵", "🔴", "🟢"], 0),
            mc("⭐⭐🌙⭐⭐🌙⭐⭐ ? Sıradaki hangisi?", ["⭐", "🌙", "☀️"], 1),
            mc("🍎🍐🍐🍎🍐🍐🍎 ? Sıradaki hangisi?", ["🍎", "🍐", "🍋"], 1),
            mc("🔺🟦🔺🟦🔺 ? Sıradaki hangisi?", ["🔺", "🟦", "⚪"], 1),
            gen("skip_count", steps=[2, 3]),
            gen("count_back", **{"from": 15}),
            mc("10, 8, 6, 4, ? Sıradaki sayı hangisi?", ["3", "2", "5"], 1,
               explain="Her seferinde 2 azalıyor: 4 − 2 = 2."),
        ],
    ),
    outcome(
        "MAT.1.1.7",
        lessons=[
            lesson("Tahmin etmek", [
                page("Bazen saymadan önce tahmin ederiz: “Burada yaklaşık 10 tane var gibi.”",
                     V("objects", emoji="🌼", count=10)),
                page("Bildiğimiz bir grubu kullanırız: bir avucumuz yaklaşık 5 ceviz alır. İki avuç yaklaşık 10 eder.",
                     V("text", text="🤲 ≈ 5")),
                page("Sonra sayarak tahminimizi kontrol ederiz. Yakın tahmin iyi tahmindir!", V("objects", emoji="🌼", count=10)),
            ]),
        ],
        cards=[
            gen("estimate"),
            gen("estimate"),
            mc("Bir sınıfta yaklaşık kaç öğrenci olur?", ["Yaklaşık 2", "Yaklaşık 20", "Yaklaşık 200"], 1),
            mc("Bir elinde yaklaşık kaç misket tutabilirsin?", ["Yaklaşık 5", "Yaklaşık 50", "Yaklaşık 500"], 0),
        ],
    ),
    outcome(
        "MAT.1.1.8",
        lessons=[
            lesson("Karışla, adımla ölçmek", [
                page("Uzunlukları karışımızla, adımımızla ya da ataşla ölçebiliriz.", V("text", text="✋ 👣 📎")),
                page("Masayı karışla, sınıfı adımla ölçmek daha uygundur. Küçük şeyleri ataşla ölçeriz.",
                     V("text", text="📏")),
                page("Ağırlığı da karşılaştırabiliriz: hangisi daha ağır, hangisi daha hafif?", V("text", text="🍉 ⚖️ 🍒")),
            ]),
        ],
        cards=[
            mc("Sınıfın uzunluğunu ölçmek için hangisi daha uygun?", ["Ataş", "Adım", "Silgi"], 1),
            mc("Bir kalemin uzunluğunu ölçmek için hangisi daha uygun?", ["Ataş", "Adım", "Kulaç"], 0),
            mc("Hangisi daha ağırdır?", ["🍉 Karpuz", "🍒 Kiraz"], 0),
            mc("Hangisi daha hafiftir?", ["🧱 Tuğla", "🪶 Tüy"], 1),
            mc("Masa yaklaşık kaç karış olabilir?", ["Yaklaşık 6 karış", "Yaklaşık 600 karış"], 0),
        ],
    ),
    outcome(
        "MAT.1.1.9",
        lessons=[
            lesson("Paralarımız", [
                page("Alışverişte para kullanırız. 1 TL madeni para, diğerleri kâğıt paradır.",
                     V("money", values=[1, 5, 10])),
                page("Kâğıt paralarımız: 5, 10, 20, 50, 100 ve 200 TL.", V("money", values=[20, 50, 100, 200])),
                page("10 TL, 5 TL'den daha fazladır. Paranın üzerindeki sayıya bakarız.", V("money", values=[5, 10])),
            ]),
        ],
        cards=[
            mc("Hangisi daha fazla para?", ["5 TL", "10 TL"], 1, visual=V("money", values=[5, 10])),
            mc("Hangisi en az para?", ["1 TL", "20 TL", "50 TL"], 0, visual=V("money", values=[1, 20, 50])),
            mc("Hangisi en fazla para?", ["100 TL", "200 TL", "50 TL"], 1, visual=V("money", values=[50, 100, 200])),
            mc("Bu para kaç TL?", ["20 TL", "50 TL", "10 TL"], 0, visual=V("money", values=[20])),
            mc("Madeni para hangisi?", ["1 TL", "100 TL", "5 TL"], 0),
        ],
    ),
    outcome(
        "MAT.1.2.1",
        lessons=[
            lesson("Hangi işlemi yapmalı?", [
                page("Bir şeyler eklenince sayı artar. Buna toplama deriz.", V("objects2", emoji="🍎", a=3, b=2)),
                page("Bir şeyler gidince, verilince sayı azalır. Buna çıkarma deriz.",
                     V("objects_crossed", emoji="🎈", total=5, crossed=2)),
                page("Soruyu dinle: “daha aldı” dersek toplarız, “verdi”, “yedi”, “kaçtı” dersek çıkarırız.",
                     V("text", text="➕   ➖")),
            ]),
        ],
        cards=[
            gen("word_add_sub", max=10),
            gen("word_add_sub", max=10),
            gen("word_add_sub", max=20),
            gen("add", max_sum=10),
            gen("sub", max=10),
        ],
    ),
    outcome(
        "MAT.1.2.2",
        lessons=[
            lesson("Zihinden toplama ve çıkarma", [
                page("Büyük sayıdan başlayıp ileri sayarız: 6 + 3 → 7, 8, 9!", V("text", text="6 → 7 → 8 → 9")),
                page("Çıkarırken geri sayarız: 8 − 2 → 7, 6!", V("text", text="8 → 7 → 6")),
                page("Önce tahmin et, sonra hesapla. 9 + 9 yaklaşık 20 eder; tam olarak 18!", V("text", text="9 + 9 ≈ 20")),
            ]),
        ],
        cards=[
            gen("add", max_sum=10),
            gen("add", max_sum=20, carry=False),
            gen("add", min=5, max_sum=20),
            gen("sub", max=10),
            gen("sub", max=20, borrow=False),
            gen("sub", max=20),
        ],
    ),
    outcome(
        "MAT.1.2.3",
        lessons=[
            lesson("Eşittir işareti", [
                page("Eşittir işareti “aynı” demektir. İki yanı birbirine eşit olmalıdır.", V("text", text="3 + 2 = 5")),
                page("5 = 3 + 2 de doğrudur. Eşittir işaretinin iki yanı da 5 eder.", V("text", text="5 = 3 + 2")),
                page("4 + 1 = 3 + 2 de doğrudur; iki yan da 5!", V("text", text="4 + 1 = 3 + 2")),
            ]),
        ],
        cards=[
            gen("equal_sides", max_sum=10),
            gen("equal_sides", max_sum=10),
            mc("Hangisi doğrudur?", ["5 = 2 + 3", "5 = 2 + 2", "5 = 1 + 1"], 0),
            mc("7 = ☐ + 4 Kutuya hangi sayı gelir?", ["3", "11", "4"], 0,
               say="Yedi eşittir kutu artı dört. Kutuya hangi sayı gelir?"),
        ],
    ),
    outcome(
        "MAT.1.2.4",
        lessons=[
            lesson("Toplama ve çıkarma kardeştir", [
                page("3 + 4 = 7. Şimdi tersine çevirelim: 7 − 4 = 3.", V("objects2", emoji="⭐", a=3, b=4)),
                page("Toplama ile çıkarma birbirinin tersidir. Birini bilirsen diğerini de bulursun!",
                     V("text", text="3 + 4 = 7  ↔  7 − 4 = 3")),
            ]),
        ],
        cards=[
            gen("fact_family", max_sum=10),
            gen("fact_family", max_sum=10),
            gen("fact_family", max_sum=20),
            mc("6 + 2 = 8 ise hangisi de doğrudur?", ["8 − 2 = 6", "8 − 2 = 4", "6 − 2 = 8"], 0),
        ],
    ),
    outcome(
        "MAT.1.3.1",
        lessons=[
            lesson("Yön bulma", [
                page("Sağ, sol, ileri, geri… Yönleri söyleyerek yol tarif ederiz.", V("text", text="⬅️ ⬆️ ➡️ ⬇️")),
                page("Kedi mamaya gitmek istiyor. Sağa doğru 4 adım atmalı!",
                     V("grid", size=5, start=[0, 2], target=[4, 2])),
            ]),
        ],
        cards=[
            mc("Kedi mamaya ulaşmak için hangi yöne gitmeli?", ["Sağa", "Sola", "Yukarı"], 0,
               visual=V("grid", size=5, start=[0, 2], target=[4, 2])),
            mc("Kedi mamaya ulaşmak için kaç adım sağa gitmeli?", ["2", "3", "4"], 1,
               visual=V("grid", size=5, start=[1, 1], target=[4, 1])),
            mc("Kedi mamaya ulaşmak için hangi yöne gitmeli?", ["Aşağı", "Yukarı", "Sağa"], 1,
               visual=V("grid", size=5, start=[2, 4], target=[2, 0])),
            mc("Kedi mamaya ulaşmak için kaç adım aşağı gitmeli?", ["2", "4", "1"], 0,
               visual=V("grid", size=5, start=[3, 1], target=[3, 3])),
        ],
    ),
    outcome(
        "MAT.1.3.2",
        lessons=[
            lesson("Eş nesneler", [
                page("İki nesne biçimi ve büyüklüğü aynıysa eştir.", V("shapes", items=["kare", "kare"])),
                page("Üst üste koyunca tam örtüşüyorsa eştir. Kare ile üçgen eş olamaz.",
                     V("shapes", items=["kare", "ucgen"])),
            ]),
        ],
        cards=[
            mc("Bu iki şekil eş mi?", ["Evet", "Hayır"], 0, visual=V("shapes", items=["daire", "daire"])),
            mc("Bu iki şekil eş mi?", ["Evet", "Hayır"], 1, visual=V("shapes", items=["kare", "dikdortgen"])),
            mc("Bu iki şekil eş mi?", ["Evet", "Hayır"], 1, visual=V("shapes", items=["ucgen", "daire"])),
            mc("İki eş nesneyi nasıl anlarız?", ["Üst üste koyarız", "Renklerine bakarız", "Koklarız"], 0),
        ],
    ),
    outcome(
        "MAT.1.3.3",
        lessons=[
            lesson("Nesnelerin biçimleri", [
                page("Etrafımızdaki nesnelerin biçimleri farklıdır. Top yuvarlaktır, kutu köşelidir.",
                     V("text", text="⚽  📦")),
                page("Yuvarlanabilen nesneler: top, portakal. Yuvarlanamayanlar: kitap, kutu.",
                     V("text", text="⚽🍊   📕📦")),
            ]),
        ],
        cards=[
            mc("Hangisi yuvarlanabilir?", ["⚽ Top", "📦 Kutu", "📕 Kitap"], 0),
            mc("Hangisi köşelidir?", ["🍊 Portakal", "📦 Kutu", "⚽ Top"], 1),
            mc("Hangisi diğerlerinden farklı biçimdedir?", ["🍊", "⚽", "📕"], 2),
        ],
    ),
    outcome(
        "MAT.1.3.4",
        lessons=[
            lesson("Çevremizdeki şekiller", [
                page("Pencere kareye, kapı dikdörtgene, saat daireye benzer.", V("text", text="🪟 🚪 🕐")),
                page("Çatıda üçgen görürüz. Evimizi şekillerle çizebiliriz!",
                     V("shapes", items=["ucgen", "kare"])),
            ]),
        ],
        cards=[
            mc("Saat hangi şekle benzer?", ["Daire", "Üçgen", "Kare"], 0, visual=V("emoji", emoji="🕐")),
            mc("Kapı hangi şekle benzer?", ["Daire", "Dikdörtgen", "Üçgen"], 1, visual=V("emoji", emoji="🚪")),
            mc("Ev çatısı hangi şekle benzer?", ["Üçgen", "Daire", "Kare"], 0, visual=V("emoji", emoji="🏠")),
            mc("Hangisi daireye benzer?", ["🍕 Pizza dilimi", "🪙 Bozuk para", "📕 Kitap"], 1),
        ],
    ),
    outcome(
        "MAT.1.3.5",
        lessons=[
            lesson("Üçgen, kare, dikdörtgen, daire", [
                page("Üçgenin 3 kenarı ve 3 köşesi vardır.", V("shapes", items=["ucgen"])),
                page("Karenin 4 kenarı vardır ve hepsi aynı uzunluktadır.", V("shapes", items=["kare"])),
                page("Dikdörtgenin de 4 kenarı vardır; karşılıklı kenarları eşittir.", V("shapes", items=["dikdortgen"])),
                page("Dairenin köşesi yoktur, yuvarlaktır.", V("shapes", items=["daire"])),
            ]),
        ],
        cards=[
            mc("Bu şeklin adı nedir?", ["Üçgen", "Kare", "Daire"], 0, visual=V("shapes", items=["ucgen"])),
            mc("Bu şeklin adı nedir?", ["Dikdörtgen", "Kare", "Daire"], 1, visual=V("shapes", items=["kare"])),
            mc("Bu şeklin adı nedir?", ["Üçgen", "Daire", "Dikdörtgen"], 1, visual=V("shapes", items=["daire"])),
            mc("Bu şeklin adı nedir?", ["Dikdörtgen", "Üçgen", "Daire"], 0, visual=V("shapes", items=["dikdortgen"])),
            mc("Üçgenin kaç köşesi vardır?", ["2", "3", "4"], 1),
            mc("Hangi şeklin köşesi yoktur?", ["Kare", "Üçgen", "Daire"], 2),
            mc("Karenin kaç kenarı vardır?", ["3", "4", "5"], 1),
        ],
    ),
    outcome(
        "MAT.1.4.1",
        lessons=[
            lesson("Verileri saymak ve göstermek", [
                page("Sınıfta en çok hangi meyve seviliyor? Sorup sayarak öğreniriz.",
                     V("text", text="🍎 🍌 🍓")),
                page("Her cevap için bir çizgi çekeriz. Buna çetele denir. Beşinci çizgi diğerlerini çapraz keser.",
                     V("tally", count=7)),
                page("Nesne grafiğinde her nesne bir kişiyi gösterir.", V("pictograph", rows=[
                    {"label": "Elma", "emoji": "🍎", "count": 4},
                    {"label": "Muz", "emoji": "🍌", "count": 2},
                    {"label": "Çilek", "emoji": "🍓", "count": 5}])),
            ]),
        ],
        cards=[
            mc("Çeteleye göre kaç kişi var?", ["5", "6", "8"], 2, visual=V("tally", count=8)),
            mc("Çeteleye göre kaç kişi var?", ["3", "4", "5"], 1, visual=V("tally", count=4)),
            mc("En çok sevilen meyve hangisi?", ["Elma", "Muz", "Çilek"], 2, visual=V("pictograph", rows=[
                {"label": "Elma", "emoji": "🍎", "count": 4},
                {"label": "Muz", "emoji": "🍌", "count": 2},
                {"label": "Çilek", "emoji": "🍓", "count": 5}])),
            mc("En az sevilen hayvan hangisi?", ["Kedi", "Köpek", "Kuş"], 2, visual=V("pictograph", rows=[
                {"label": "Kedi", "emoji": "🐱", "count": 5},
                {"label": "Köpek", "emoji": "🐶", "count": 4},
                {"label": "Kuş", "emoji": "🐦", "count": 1}])),
            mc("Kaç kişi kırmızıyı seçmiş?", ["2", "3", "6"], 1, visual=V("pictograph", rows=[
                {"label": "Kırmızı", "emoji": "🔴", "count": 3},
                {"label": "Mavi", "emoji": "🔵", "count": 6}])),
        ],
    ),
]

PACK = pack("matematik", 1, OUTCOMES)
