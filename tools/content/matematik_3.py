"""3. sınıf Matematik içerik paketi (TYMM MAT.3.x.x).

Not: Sabit sorular ve anlatım metinleri bir sınıf öğretmeninin pedagojik
onayından geçmelidir.
"""

from common import pack, outcome, lesson, page, mc, gen, V

PIE = lambda parts, shaded: V("fraction", parts=parts, shaded=shaded)

OUTCOMES = [
    outcome("MAT.3.1.1", lessons=[lesson("1000'e kadar sayılar", [
        page("10 onluk bir yüzlük eder. Yüzlükler, onluklar ve birliklerle 1000'e kadar sayabiliriz.", V("text", text="10 × 10 = 100")),
        page("3 yüzlük, 4 onluk ve 5 birlik 345 eder: üç yüz kırk beş.", V("text", text="345 = üç yüz kırk beş")),
    ])], cards=[
        gen("number_words", min=100, max=999),
        gen("number_words", min=100, max=1000),
        mc("Hangisi “yedi yüz altı”dır?", ["760", "706", "7006"], 1, say="Hangisi yedi yüz altı?"),
        mc("4 yüzlük, 2 onluk ve 9 birlik kaç eder?", ["429", "492", "4209"], 0),
        mc("Bin sayısı nasıl yazılır?", ["100", "1000", "10000"], 1),
    ]),
    outcome("MAT.3.1.2", lessons=[lesson("Üç basamaklı sayılar", [
        page("Üç basamaklı sayılarda soldan sağa: yüzler, onlar, birler basamağı.", V("number_highlight", number=582, pos=2)),
        page("582 sayısında 5'in basamak değeri 500, 8'in basamak değeri 80, 2'nin basamak değeri 2'dir.",
             V("text", text="500 + 80 + 2 = 582")),
    ])], cards=[
        gen("place_value", digits=3),
        gen("place_value", digits=3),
        mc("736 sayısında 7 rakamının basamak değeri kaçtır?", ["7", "70", "700"], 2),
        mc("900 + 40 + 1 kaç eder?", ["941", "9401", "914"], 0),
        mc("608 sayısında onlar basamağındaki rakam hangisi?", ["6", "0", "8"], 1),
    ]),
    outcome("MAT.3.1.3", lessons=[lesson("Sıralama ve yuvarlama", [
        page("Üç basamaklı sayıları karşılaştırırken önce yüzlere, sonra onlara, sonra birlere bakarız.", V("text", text="482 < 491")),
        page("En yakın onluğa yuvarlarken birler basamağına bakarız: 5 ve üstü yukarı, 4 ve altı aşağı. 67 → 70, 63 → 60.",
             V("text", text="67 ≈ 70")),
    ])], cards=[
        gen("order3", max=999),
        gen("compare", max=999),
        gen("round_to", to=10, max=999),
        gen("round_to", to=100, max=999),
        mc("348 sayısı hangi iki yüzlük arasındadır?", ["200 ile 300", "300 ile 400", "400 ile 500"], 1),
    ]),
    outcome("MAT.3.1.4", lessons=[lesson("Ritmik sayma", [
        page("Altışar, yedişer, sekizer, dokuzar sayarız. Bu sayılar çarpım tablosunu da oluşturur!", V("text", text="7 · 14 · 21 · 28")),
        page("Onar ve yüzer de sayabiliriz: 300, 400, 500…", V("text", text="300 · 400 · 500")),
    ])], cards=[
        gen("skip_count", steps=[6]),
        gen("skip_count", steps=[7]),
        gen("skip_count", steps=[8, 9]),
        gen("skip_count", steps=[100]),
        mc("900, 800, 700, ? Sıradaki sayı hangisi?", ["600", "650", "690"], 0),
    ]),
    outcome("MAT.3.1.5", lessons=[lesson("Tek ve çift sayılar", [
        page("İkişer eşleştirdiğimizde artan kalmıyorsa sayı çifttir. Bir tane artıyorsa tektir.", V("objects", emoji="🧦", count=7)),
        page("Birler basamağı 0, 2, 4, 6, 8 olan sayılar çift; 1, 3, 5, 7, 9 olanlar tektir.", V("text", text="Çift: 0 2 4 6 8   Tek: 1 3 5 7 9")),
    ])], cards=[
        gen("odd_even", max=100),
        gen("odd_even", max=1000),
        mc("Hangisi çift sayıdır?", ["35", "48", "71"], 1),
        mc("Hangisi tek sayıdır?", ["120", "246", "357"], 2),
    ]),
    outcome("MAT.3.1.6", lessons=[lesson("Tek + çift = ?", [
        page("İki çift sayının toplamı çifttir: 4 + 6 = 10.", V("text", text="çift + çift = çift")),
        page("İki tek sayının toplamı da çifttir: 3 + 5 = 8. Tek ile çiftin toplamı tektir: 3 + 4 = 7.",
             V("text", text="tek + tek = çift · tek + çift = tek")),
    ])], cards=[
        gen("odd_even_sum", max=50),
        gen("odd_even_sum", max=500),
        mc("Tek + tek toplamı ne olur?", ["Her zaman tek", "Her zaman çift", "Bazen tek, bazen çift"], 1),
        mc("Tek + çift toplamı ne olur?", ["Her zaman tek", "Her zaman çift"], 0),
    ]),
    outcome("MAT.3.1.7", lessons=[lesson("Örüntülerde kural", [
        page("Her adımda bir sıra daha ekleniyor: 1, 3, 6, 10… Eklenen sayılar 2, 3, 4…", V("text", text="1 · 3 · 6 · 10")),
        page("Kuralı bulunca 5. adımı da bulabiliriz: 10 + 5 = 15.", V("text", text="10 + 5 = 15")),
    ])], cards=[
        mc("2, 4, 8, 16, ? Sıradaki sayı hangisi?", ["18", "24", "32"], 2, explain="Her adımda sayı iki katına çıkıyor."),
        mc("1, 3, 6, 10, ? Sıradaki sayı hangisi?", ["12", "14", "15"], 2, explain="Eklenen sayılar 2, 3, 4, 5…"),
        mc("5, 10, 20, 35, ? Sıradaki sayı hangisi?", ["40", "50", "55"], 2, explain="Eklenen sayılar 5, 10, 15, 20…"),
        gen("skip_count", steps=[6, 7, 8, 9]),
        mc("🔺 · 🔺🔺🔺 · 🔺🔺🔺🔺🔺 · ? Sonraki adımda kaç üçgen olur?", ["6", "7", "9"], 1),
    ]),
    outcome("MAT.3.1.8", lessons=[lesson("100'e kadar tahmin", [
        page("Kalabalık bir grubun bir parçasını sayıp kaç parça olduğuna bakarak tahmin ederiz.",
             V("objects", emoji="🐟", count=60)),
        page("Bir sırada 10 balık var, yaklaşık 6 sıra: yaklaşık 60 balık!", V("objects", emoji="🐟", count=60)),
    ])], cards=[
        mc("Saymadan tahmin et: yaklaşık kaç tane var?", ["Yaklaşık 20", "Yaklaşık 50", "Yaklaşık 90"], 1,
           visual=V("objects", emoji="⭐", count=52)),
        mc("Saymadan tahmin et: yaklaşık kaç tane var?", ["Yaklaşık 30", "Yaklaşık 60", "Yaklaşık 100"], 2,
           visual=V("objects", emoji="🌼", count=97)),
        mc("Bir otobüste yaklaşık kaç yolcu oturabilir?", ["Yaklaşık 5", "Yaklaşık 50", "Yaklaşık 500"], 1),
    ]),
    outcome("MAT.3.1.9", lessons=[lesson("Kesirle yazmak", [
        page("Yarımı 1/2, çeyreği 1/4 diye yazarız. Bütünü 2/2 ya da 4/4 diye de yazabiliriz.", PIE(2, 1)),
        page("1/4 demek: bütün 4 eş parçaya bölündü, 1 parçası alındı.", PIE(4, 1)),
    ])], cards=[
        gen("fraction_read", parts=[2, 4]),
        mc("Yarım hangi kesirle gösterilir?", ["1/2", "1/4", "2/1"], 0),
        mc("Çeyrek hangi kesirle gösterilir?", ["1/2", "1/4", "4/1"], 1),
        mc("4/4 neye eşittir?", ["Bir bütün", "Yarım", "Çeyrek"], 0, visual=PIE(4, 4)),
    ]),
    outcome("MAT.3.1.10", lessons=[lesson("Birim kesirler", [
        page("Bir bütünü eş parçalara bölünce her parça bir birim kesirdir: 1/3, 1/5, 1/8…", PIE(3, 1)),
        page("Parça sayısı arttıkça her parça küçülür: 1/8, 1/2'den küçüktür.", PIE(8, 1)),
    ])], cards=[
        gen("fraction_read", parts=[3, 5, 6, 8], unit=True),
        gen("fraction_read", parts=[2, 3, 4, 6], unit=True),
        mc("Hangisi daha büyüktür?", ["1/2", "1/8"], 0),
        mc("Bir pizza 6 eş parçaya bölündü. Bir parça pizzanın ne kadarıdır?", ["1/6", "6/1", "1/5"], 0, visual=PIE(6, 1)),
    ]),
    outcome("MAT.3.1.11", lessons=[lesson("Pay ve payda", [
        page("Kesirde alttaki sayı payda: bütün kaç eş parçaya bölündü? Üstteki sayı pay: kaç parça alındı?", PIE(5, 3)),
        page("3/5 kesrinde pay 3, payda 5'tir.", V("text", text="3 ← pay\n—\n5 ← payda")),
    ])], cards=[
        gen("fraction_read", parts=[3, 4, 5, 6, 8]),
        gen("fraction_read", parts=[3, 4, 5, 6, 8]),
        mc("5/8 kesrinin paydası kaçtır?", ["5", "8", "13"], 1),
        mc("2/7 kesrinin payı kaçtır?", ["2", "7", "9"], 0),
    ]),
    outcome("MAT.3.1.12", lessons=[lesson("Analog ve dijital saat", [
        page("Yelkovan 3'ü gösteriyorsa saat çeyrek geçiyordur. Dijital saatte 15 yazar.", V("clock", h=4, m=15)),
        page("Yelkovan 9'u gösteriyorsa bir sonraki saate çeyrek vardır. 4.45'te saat 5'e çeyrek vardır.", V("clock", h=4, m=45)),
    ])], cards=[
        gen("clock_read", minutes=[0, 15, 30, 45]),
        gen("clock_read", minutes=[15, 45]),
        gen("clock_read", minutes=[0, 15, 30, 45]),
        mc("Dijital saat 07.30 gösteriyor. Saat kaç?", ["Saat 7 buçuk", "Saat 3 buçuk", "Saat 7"], 0),
        mc("Dijital saat 09.15 gösteriyor. Saat kaç?", ["Saat 9'u çeyrek geçiyor", "Saat 9'a çeyrek var", "Saat 3"], 0),
    ]),
    outcome("MAT.3.1.13", lessons=[lesson("Zaman birimleri", [
        page("1 dakika 60 saniye, 1 saat 60 dakika, 1 gün 24 saattir.", V("text", text="60 sn · 60 dk · 24 sa")),
        page("1 hafta 7 gün, 1 yıl 12 ay ya da 365 gündür.", V("text", text="7 gün · 12 ay · 365 gün")),
    ])], cards=[
        gen("unit_convert", kinds=["saat_dk", "dk_sn", "gun_saat", "hafta_gun", "yil_ay"]),
        gen("unit_convert", kinds=["saat_dk", "dk_sn", "gun_saat", "hafta_gun", "yil_ay"]),
        mc("Bir yıl kaç gündür?", ["300", "365", "730"], 1),
        mc("Yarım saat kaç dakikadır?", ["15", "30", "50"], 1),
    ]),
    outcome("MAT.3.1.14", lessons=[lesson("Ne kadar sürer?", [
        page("Bazı işler saniyeler, bazıları dakikalar, bazıları saatler sürer.", V("text", text="⏱️ 👟 ✈️")),
        page("Göz kırpmak 1 saniye, diş fırçalamak 2 dakika, bir film izlemek yaklaşık 2 saat sürer.", V("text", text="😉 🪥 🎬")),
    ])], cards=[
        mc("Dişlerini fırçalamak yaklaşık ne kadar sürer?", ["2 saniye", "2 dakika", "2 saat"], 1),
        mc("Bir ders yaklaşık ne kadar sürer?", ["40 saniye", "40 dakika", "40 saat"], 1),
        mc("Gece uykusu yaklaşık ne kadar sürer?", ["10 dakika", "10 saat", "10 gün"], 1),
        mc("Hangisi daha uzun sürer?", ["Bir film izlemek", "Ellerini yıkamak"], 0),
    ]),
    outcome("MAT.3.1.15", lessons=[lesson("Uzunluk ve kütle birimleri", [
        page("1 metre 100 santimetre, 1 kilometre 1000 metredir.", V("text", text="1 m = 100 cm · 1 km = 1000 m")),
        page("1 kilogram 1000 gram, 1 ton 1000 kilogramdır.", V("text", text="1 kg = 1000 g · 1 ton = 1000 kg")),
    ])], cards=[
        gen("unit_convert", kinds=["m_cm", "km_m"]),
        gen("unit_convert", kinds=["kg_g", "ton_kg"]),
        mc("İki şehir arası uzaklık hangi birimle ölçülür?", ["Santimetre", "Kilometre", "Gram"], 1),
        mc("Bir filin kütlesi hangi birimle ölçülür?", ["Gram", "Ton", "Metre"], 1),
        mc("Yarım kilogram kaç gramdır?", ["50", "500", "5000"], 1),
    ]),
    outcome("MAT.3.1.16", lessons=[lesson("Paralarımız", [
        page("1 TL 100 kuruştur. 4 tane 25 kuruş da 1 TL eder.", V("text", text="25 + 25 + 25 + 25 = 100 kr")),
        page("Bir 20 TL, iki tane 10 TL'ye ya da dört tane 5 TL'ye eşittir.", V("money", values=[20, 10, 10])),
    ])], cards=[
        mc("50 TL kaç tane 10 TL eder?", ["5", "10", "50"], 0),
        mc("100 TL kaç tane 20 TL eder?", ["4", "5", "20"], 1),
        mc("3 TL kaç kuruştur?", ["30", "300", "3000"], 1),
        mc("2 tane 50 kuruş ve 1 TL toplam kaç TL eder?", ["2 TL", "51 TL", "3 TL"], 0),
        mc("15 TL'lik kitap için 20 TL verirsek kaç TL para üstü alırız?", ["5 TL", "15 TL", "35 TL"], 0),
    ]),
    outcome("MAT.3.2.1", lessons=[lesson("Tahmin ve zihinden işlem", [
        page("Sayıları en yakın onluğa yuvarlayarak hızlı tahmin ederiz: 198 + 302 ≈ 200 + 300 = 500.", V("text", text="198 + 302 ≈ 500")),
        page("Zihinden toplarken önce yüzlükleri, sonra onlukları, sonra birlikleri toplarız.", V("text", text="230 + 150 = 380")),
    ])], cards=[
        gen("add", min=100, max_sum=999, carry=False),
        gen("sub", max=999, borrow=False),
        gen("add", min=10, max_sum=200),
        mc("298 + 401 yaklaşık kaç eder?", ["Yaklaşık 500", "Yaklaşık 700", "Yaklaşık 900"], 1),
    ]),
    outcome("MAT.3.2.2", lessons=[lesson("Eldeli toplama, onluk bozarak çıkarma", [
        page("Birlerin toplamı 10 ya da fazlaysa bir onluğu “elde” olarak onlar basamağına aktarırız.", V("text", text="47 + 38 = 85")),
        page("Çıkarmada birler yetmezse onlar basamağından bir onluk bozarız: 52 − 27 = 25.", V("text", text="52 − 27 = 25")),
    ])], cards=[
        gen("add", min=10, max_sum=999),
        gen("add", min=100, max_sum=999),
        gen("sub", max=999),
        gen("sub", max=999),
        gen("fact_family", max_sum=500),
    ]),
    outcome("MAT.3.2.3", lessons=[lesson("Çarpım tablosu", [
        page("10'a kadar çarpım tablosunu bilmek çarpma ve bölmeyi hızlandırır.", V("text", text="7 × 8 = 56")),
        page("Bölme çarpmanın tersidir: 56 ÷ 8 = 7 çünkü 7 × 8 = 56.", V("text", text="56 ÷ 8 = 7")),
    ])], cards=[
        gen("multiply", a_min=2, a_max=10, b_min=2, b_max=10),
        gen("multiply", a_min=6, a_max=9, b_min=6, b_max=9),
        gen("divide", q_max=10, d_max=10),
        gen("divide", q_max=10, d_max=10),
    ]),
    outcome("MAT.3.2.4", lessons=[lesson("Çarpma ve bölme işlemi", [
        page("Bir sayıyı 10 ile çarpınca sağına bir sıfır ekleriz: 23 × 10 = 230.", V("text", text="23 × 10 = 230")),
        page("İki basamaklı bir sayıyı bir basamaklı sayıyla çarparken önce birleri, sonra onları çarparız: 14 × 3 = 42.", V("text", text="14 × 3 = 42")),
    ])], cards=[
        gen("multiply", a_min=10, a_max=30, b_min=2, b_max=5),
        gen("multiply", a_min=10, a_max=99, b_min=10, b_max=10),
        gen("divide", q_max=20, d_max=5),
        mc("45 × 2 kaç eder?", ["47", "90", "80"], 1),
        mc("84 ÷ 4 kaç eder?", ["21", "24", "80"], 0),
    ]),
    outcome("MAT.3.2.5", lessons=[lesson("Yönergeyi işleme çevir", [
        page("“Bir sayıyı 3 ile çarp, sonra 4 ekle” yönergesini işlem diline çeviririz: 5 × 3 + 4 = 19.", V("text", text="5 × 3 + 4 = 19")),
    ])], cards=[
        mc("6'yı 2 ile çarp, sonra 5 ekle. Sonuç kaç?", ["13", "17", "22"], 1),
        mc("20'den 8 çıkar, sonra 2'ye böl. Sonuç kaç?", ["6", "14", "4"], 0),
        mc("4'e 6 ekle, sonra 10 ile çarp. Sonuç kaç?", ["64", "100", "46"], 1),
        mc("“Bir sayının 3 katı” ifadesinin işlem dili hangisidir?", ["sayı × 3", "sayı + 3", "sayı ÷ 3"], 0),
    ]),
    outcome("MAT.3.2.6", lessons=[lesson("Dört işlemle problem", [
        page("Problemi oku, verilenleri ve isteneni yaz. Sonra hangi işlem gerektiğine karar ver.", V("text", text="📖 ➜ ✏️ ➜ ✅")),
        page("“Her birinde … var, kaç tane var?” çoğu zaman çarpma; “eşit paylaştır” bölmedir.", V("text", text="× ÷")),
    ])], cards=[
        gen("word_mul_div", max=10),
        gen("word_mul_div", max=10),
        gen("word_add_sub", max=100),
        mc("Bir kutuda 6 kalem var. 5 kutuda kaç kalem vardır?", ["11", "30", "56"], 1),
        mc("Bir kitap 12 TL. 3 kitap kaç TL?", ["15 TL", "36 TL", "4 TL"], 1),
    ]),
    outcome("MAT.3.2.7", lessons=[lesson("Problem kuralım", [
        page("“8 × 3 = 24” işlemiyle bir problem kurabiliriz: “8 arkadaşın her birinin 3 kalemi var. Toplam kaç kalem var?”",
             V("text", text="8 × 3 = 24")),
    ])], cards=[
        mc("“5 × 4” işlemiyle çözülen problem hangisidir?", [
            "5 tabağın her birinde 4 elma var. Toplam kaç elma var?",
            "5 elmam vardı, 4 tanesini yedim. Kaç kaldı?",
            "5 elma ile 4 elma toplam kaç eder?"], 0),
        mc("“20 ÷ 4” işlemiyle çözülen problem hangisidir?", [
            "20 ceviz 4 kişiye eşit paylaştırılıyor. Her biri kaç alır?",
            "20 cevize 4 ceviz eklendi. Kaç oldu?",
            "4 kutuda 20'şer ceviz var. Kaç ceviz var?"], 0),
        mc("“30 − 12” işlemiyle çözülen problem hangisidir?", [
            "30 sayfalık kitabın 12 sayfasını okudum. Kaç sayfa kaldı?",
            "30 sayfaya 12 sayfa eklendi. Kaç sayfa oldu?",
            "12 kitabın her biri 30 sayfa. Toplam kaç sayfa?"], 0),
    ]),
    outcome("MAT.3.2.8", lessons=[lesson("Eşitliğin anlamı", [
        page("Eşitlik, iki yanın aynı değerde olduğunu söyler: 4 × 6 = 30 − 6 = 24.", V("text", text="4 × 6 = 30 − 6")),
    ])], cards=[
        gen("equal_sides", max_sum=50),
        mc("3 × 5 = ☐ − 5 Kutuya hangi sayı gelir?", ["10", "15", "20"], 2),
        mc("Hangisi 24'e eşit değildir?", ["6 × 4", "3 × 8", "5 × 5"], 2),
        mc("18 ÷ 2 = 3 × ☐ Kutuya hangi sayı gelir?", ["3", "6", "9"], 0),
    ]),
    outcome("MAT.3.3.1", lessons=[lesson("Köşe, yüz, ayrıt", [
        page("Cisimlerin düz yüzeylerine yüz, iki yüzün birleştiği çizgiye ayrıt, ayrıtların birleştiği noktaya köşe denir.",
             V("emoji", emoji="🎲")),
        page("Küpün 6 yüzü, 12 ayrıtı ve 8 köşesi vardır.", V("text", text="6 yüz · 12 ayrıt · 8 köşe")),
    ])], cards=[
        mc("Küpün kaç köşesi vardır?", ["6", "8", "12"], 1),
        mc("Küpün kaç ayrıtı vardır?", ["6", "8", "12"], 2),
        mc("Kürenin kaç köşesi vardır?", ["0", "1", "2"], 0, visual=V("emoji", emoji="⚽")),
        mc("Silindirin kaç düz yüzü vardır?", ["1", "2", "3"], 1, visual=V("emoji", emoji="🥫")),
    ]),
    outcome("MAT.3.3.2", lessons=[lesson("Kenar sayısına göre şekiller", [
        page("3 kenarlı şekil üçgen, 4 kenarlı şekil dörtgen, 5 kenarlı beşgen, 6 kenarlı altıgendir.",
             V("shapes", items=["ucgen", "kare", "besgen", "altigen"])),
    ])], cards=[
        mc("Bu şeklin kaç kenarı vardır?", ["4", "5", "6"], 1, visual=V("shapes", items=["besgen"])),
        mc("Bu şeklin adı nedir?", ["Beşgen", "Altıgen", "Dörtgen"], 1, visual=V("shapes", items=["altigen"])),
        mc("Kare ve dikdörtgen hangi gruptadır?", ["Üçgenler", "Dörtgenler", "Beşgenler"], 1),
        mc("Bal peteğinin gözleri hangi şekle benzer?", ["Altıgen", "Üçgen", "Daire"], 0),
    ]),
    outcome("MAT.3.3.3", lessons=[lesson("Şekil çizmek", [
        page("Düz çizgi için cetvel, daire için pergel ya da yuvarlak bir kalıp kullanırız. Kareli kâğıt da işimizi kolaylaştırır.",
             V("text", text="📏 ⭕ ✏️")),
    ])], cards=[
        mc("Düz bir çizgi çizmek için hangisini kullanırız?", ["Cetvel", "Silgi", "Makas"], 0),
        mc("Kare çizmek için hangisi en kullanışlıdır?", ["Kareli kâğıt ve cetvel", "Boya kalemi", "Yapıştırıcı"], 0),
        mc("Daire çizmek için hangisini kullanabiliriz?", ["Pergel", "Cetvel", "Silgi"], 0),
    ]),
    outcome("MAT.3.3.4", lessons=[lesson("Çevre uzunluğu", [
        page("Bir şeklin çevresi, bütün kenarlarının toplamıdır.", V("shapes", items=["dikdortgen"])),
        page("Kenarları 5 cm ve 3 cm olan dikdörtgenin çevresi: 5 + 3 + 5 + 3 = 16 cm.", V("text", text="5 + 3 + 5 + 3 = 16")),
    ])], cards=[
        gen("perimeter", max=10),
        gen("perimeter", max=10),
        gen("perimeter", max=20),
        mc("Bir kenarı 6 cm olan karenin çevresi kaç cm?", ["12 cm", "24 cm", "36 cm"], 1),
    ]),
    outcome("MAT.3.3.5", lessons=[lesson("Litre ve mililitre", [
        page("Sıvıları litre ve mililitre ile ölçeriz. 1 litre 1000 mililitredir.", V("text", text="1 L = 1000 mL")),
        page("Bir şişe su genellikle yarım litre (500 mL), bir kova yaklaşık 10 litredir.", V("text", text="🍶 500 mL · 🪣 10 L")),
    ])], cards=[
        gen("unit_convert", kinds=["l_ml"]),
        mc("Bir çay bardağı yaklaşık ne kadar sıvı alır?", ["100 mL", "10 L", "100 L"], 0),
        mc("Bir kova yaklaşık ne kadar su alır?", ["10 mL", "10 L", "1000 L"], 1),
        mc("Yarım litre kaç mililitredir?", ["50", "500", "5000"], 1),
    ]),
    outcome("MAT.3.3.6", lessons=[lesson("Birden çok simetri doğrusu", [
        page("Karenin 4 simetri doğrusu vardır: yatay, dikey ve iki köşegen.", V("shapes", items=["kare"])),
        page("Dikdörtgenin 2 simetri doğrusu vardır. Dairenin ise sayısız simetri doğrusu vardır!", V("shapes", items=["dikdortgen", "daire"])),
    ])], cards=[
        mc("Karenin kaç simetri doğrusu vardır?", ["1", "2", "4"], 2, visual=V("shapes", items=["kare"])),
        mc("Dikdörtgenin kaç simetri doğrusu vardır?", ["1", "2", "4"], 1, visual=V("shapes", items=["dikdortgen"])),
        mc("Hangi şeklin sayısız simetri doğrusu vardır?", ["Daire", "Kare", "Üçgen"], 0),
        mc("Simetri doğrusu şekli nasıl iki parçaya ayırır?", ["Eş iki parçaya", "Farklı iki parçaya"], 0),
    ]),
    outcome("MAT.3.3.7", lessons=[lesson("Simetriği tamamla", [
        page("Simetrik bir şeklin bir yarısını görünce diğer yarısını ayna gibi tamamlarız.", V("text", text="◧ ➜ ⬛")),
        page("Simetri doğrusuna olan uzaklıklar iki tarafta da aynı olmalıdır.", V("text", text="🦋")),
    ])], cards=[
        mc("Bir kelebeğin yarısını çizdik. Diğer yarısı nasıl olmalı?", ["Aynı büyüklükte ve ayna gibi", "Daha küçük", "Farklı renkte ve şekilde"], 0),
        mc("Simetri doğrusuna 3 kare uzaklıktaki noktanın simetriği kaç kare uzakta olur?", ["1", "3", "6"], 1),
        mc("Bir harfin dikey simetriği kendisine eşit olan hangisidir?", ["A", "F", "L"], 0),
    ]),
    outcome("MAT.3.3.8", lessons=[lesson("Kodla simetri", [
        page("Yönergeler: “2 kare sağa, 1 kare yukarı” gibi. Simetriğinde sağ yerine sol yazarız!", V("text", text="➡️➡️⬆️  ↔  ⬅️⬅️⬆️")),
    ])], cards=[
        mc("Dikey simetri doğrusuna göre “3 sağa” hareketinin simetriği nedir?", ["3 sola", "3 yukarı", "3 sağa"], 0),
        mc("Dikey simetride “2 yukarı” hareketi nasıl değişir?", ["Değişmez: 2 yukarı", "2 aşağı olur", "2 sola olur"], 0),
        mc("Yatay simetri doğrusuna göre “1 yukarı” hareketinin simetriği nedir?", ["1 aşağı", "1 sağa", "1 yukarı"], 0),
    ]),
    outcome("MAT.3.4.1", lessons=[lesson("Veri toplama ve grafik", [
        page("Bir soru sorarız, cevapları sayarız ve tabloyla ya da grafikle gösteririz.",
             V("pictograph", rows=[{"label": "Kitap", "emoji": "📚", "count": 7}, {"label": "Oyun", "emoji": "🎲", "count": 5},
                                   {"label": "Spor", "emoji": "⚽", "count": 9}])),
        page("Grafikten en çok ve en az seçileni buluruz, farkı hesaplarız.", V("text", text="9 − 5 = 4")),
    ])], cards=[
        mc("En çok seçilen etkinlik hangisi?", ["Kitap", "Oyun", "Spor"], 2,
           visual=V("pictograph", rows=[{"label": "Kitap", "emoji": "📚", "count": 7}, {"label": "Oyun", "emoji": "🎲", "count": 5},
                                        {"label": "Spor", "emoji": "⚽", "count": 9}])),
        mc("Sporu seçenler oyunu seçenlerden kaç kişi fazla?", ["2", "4", "14"], 1,
           visual=V("pictograph", rows=[{"label": "Kitap", "emoji": "📚", "count": 7}, {"label": "Oyun", "emoji": "🎲", "count": 5},
                                        {"label": "Spor", "emoji": "⚽", "count": 9}])),
        mc("Ankete toplam kaç kişi katılmış?", ["12", "21", "16"], 1,
           visual=V("pictograph", rows=[{"label": "Kitap", "emoji": "📚", "count": 7}, {"label": "Oyun", "emoji": "🎲", "count": 5},
                                        {"label": "Spor", "emoji": "⚽", "count": 9}])),
    ]),
]

PACK = pack("matematik", 3, OUTCOMES)
