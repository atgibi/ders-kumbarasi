"""2. sınıf Matematik içerik paketi (TYMM MAT.2.x.x).

Not: Sabit sorular ve anlatım metinleri bir sınıf öğretmeninin pedagojik
onayından geçmelidir.
"""

from common import pack, outcome, lesson, page, mc, gen, V

PIE = lambda parts, shaded: V("fraction", parts=parts, shaded=shaded)

OUTCOMES = [
    outcome("MAT.2.1.1", lessons=[lesson("100'e kadar sayılar", [
        page("Onluk bloklarla büyük sayıları gösterebiliriz. Her uzun blok 10 birimdir.", V("blocks", tens=3, ones=4)),
        page("3 onluk ve 4 birlik 34 eder. Otuz dört diye okunur.", V("text", text="34 = otuz dört")),
        page("100'e kadar her sayıyı böyle yazar ve okuruz: 58 elli sekiz, 91 doksan bir.", V("text", text="58 · 91")),
    ])], cards=[
        gen("tens_ones", max=99),
        gen("number_words", min=11, max=99),
        gen("number_words", min=20, max=100),
        gen("count_objects", min=20, max=40),
        mc("Hangisi “seksen altı”dır?", ["68", "86", "806"], 1, say="Hangisi seksen altı?"),
        mc("Yüz sayısı nasıl yazılır?", ["10", "100", "1000"], 1),
    ]),
    outcome("MAT.2.1.2", lessons=[lesson("Basamaklar", [
        page("İki basamaklı sayılarda soldaki rakam onlar, sağdaki rakam birler basamağındadır.",
             V("number_highlight", number=47, pos=1)),
        page("47 sayısında 4 onlar basamağında. Basamak değeri 40'tır. 7 birler basamağında, değeri 7'dir.",
             V("blocks", tens=4, ones=7)),
    ])], cards=[
        gen("place_value", digits=2),
        gen("tens_ones", max=99),
        mc("63 sayısında 6 rakamının basamak değeri kaçtır?", ["6", "60", "63"], 1),
        mc("85 sayısında kaç onluk var?", ["8", "5", "85"], 0, visual=V("blocks", tens=8, ones=5)),
        mc("29 sayısında birler basamağındaki rakam hangisi?", ["2", "9", "20"], 1),
        mc("4 onluk 0 birlik kaç eder?", ["4", "40", "400"], 1),
    ]),
    outcome("MAT.2.1.3", lessons=[lesson("Sayıları sıralamak", [
        page("Sayıları küçükten büyüğe ya da büyükten küçüğe sıralayabiliriz.", V("text", text="12 < 35 < 70")),
        page("Önce onlar basamağına bakarız. Onlar aynıysa birlere bakarız: 46 < 49.", V("text", text="46 < 49")),
    ])], cards=[
        gen("order3", max=100),
        gen("order3", max=100),
        gen("compare", max=100),
        mc("Küçükten büyüğe doğru sıralı olan hangisi?", ["15, 51, 50", "15, 50, 51", "51, 50, 15"], 1),
        mc("Hangisi büyükten küçüğe doğru sıralı?", ["90, 72, 27", "27, 72, 90", "72, 90, 27"], 0),
    ]),
    outcome("MAT.2.1.4", lessons=[lesson("Ritmik sayma", [
        page("İkişer, üçer, dörder ve beşer sayabiliriz. Yüzlük tabloda bir örüntü oluşur!", V("text", text="5 · 10 · 15 · 20 · 25")),
        page("Geriye doğru da sayarız: 40, 36, 32, 28… Her seferinde 4 azalır.", V("text", text="40 · 36 · 32 · 28")),
    ])], cards=[
        gen("skip_count", steps=[2]),
        gen("skip_count", steps=[3]),
        gen("skip_count", steps=[4]),
        gen("skip_count", steps=[5]),
        mc("30, 27, 24, 21, ? Sıradaki sayı hangisi?", ["20", "18", "19"], 1, explain="Her seferinde 3 azalıyor."),
        mc("100, 95, 90, 85, ? Sıradaki sayı hangisi?", ["80", "75", "84"], 0),
    ]),
    outcome("MAT.2.1.5", lessons=[lesson("Şekil ve sayı örüntüleri", [
        page("Her adımda bir kare ekleniyor: 1, 2, 3… Örüntünün kuralını bulursak devamını tahmin ederiz.",
             V("text", text="🟧  🟧🟧  🟧🟧🟧")),
        page("Bu örüntüde her adımda 2 yıldız ekleniyor: 2, 4, 6…", V("text", text="⭐⭐  ⭐⭐⭐⭐  ⭐⭐⭐⭐⭐⭐")),
    ])], cards=[
        mc("🟧 · 🟧🟧 · 🟧🟧🟧 · ? Sonraki adımda kaç kare olur?", ["3", "4", "5"], 1),
        mc("⭐⭐ · ⭐⭐⭐⭐ · ⭐⭐⭐⭐⭐⭐ · ? Sonraki adımda kaç yıldız olur?", ["7", "8", "10"], 1),
        mc("3, 6, 9, 12, ? Kural nedir?", ["Her seferinde 3 ekle", "Her seferinde 2 ekle", "Her seferinde 3 çıkar"], 0),
        gen("skip_count", steps=[2, 3, 4, 5]),
        mc("50, 45, 40, 35, ? Kural nedir?", ["5 ekle", "5 çıkar", "10 çıkar"], 1),
    ]),
    outcome("MAT.2.1.6", lessons=[lesson("50'ye kadar tahmin", [
        page("Çok sayıda nesne varken önce 10'luk bir grubu görürüz, sonra kaç grup olduğunu tahmin ederiz.",
             V("objects", emoji="🌼", count=30)),
        page("Burada yaklaşık 3 tane onluk grup var; yani yaklaşık 30 çiçek!", V("objects", emoji="🌼", count=30)),
    ])], cards=[
        mc("Saymadan tahmin et: yaklaşık kaç tane var?", ["Yaklaşık 10", "Yaklaşık 30", "Yaklaşık 50"], 1,
           visual=V("objects", emoji="🍎", count=31)),
        mc("Saymadan tahmin et: yaklaşık kaç tane var?", ["Yaklaşık 20", "Yaklaşık 40", "Yaklaşık 50"], 0,
           visual=V("objects", emoji="⭐", count=19)),
        mc("Saymadan tahmin et: yaklaşık kaç tane var?", ["Yaklaşık 10", "Yaklaşık 25", "Yaklaşık 50"], 2,
           visual=V("objects", emoji="🎈", count=48)),
        mc("Bir kavanozda yaklaşık kaç şeker olabilir?", ["Yaklaşık 40", "Yaklaşık 4000"], 0),
    ]),
    outcome("MAT.2.1.7", lessons=[lesson("Bütün, yarım, çeyrek", [
        page("Bir bütün pizzayı iki eş parçaya bölersek her parça yarımdır.", PIE(2, 1)),
        page("Dört eş parçaya bölersek her parça çeyrektir.", PIE(4, 1)),
        page("İki yarım bir bütün eder. Dört çeyrek de bir bütün eder. İki çeyrek bir yarım eder.", PIE(4, 2)),
    ])], cards=[
        mc("Boyalı kısım bütünün ne kadarı?", ["Yarım", "Çeyrek", "Bütün"], 0, visual=PIE(2, 1)),
        mc("Boyalı kısım bütünün ne kadarı?", ["Yarım", "Çeyrek", "Bütün"], 1, visual=PIE(4, 1)),
        mc("Boyalı kısım bütünün ne kadarı?", ["Yarım", "Çeyrek", "Bütün"], 2, visual=PIE(4, 4)),
        mc("Kaç yarım bir bütün eder?", ["1", "2", "4"], 1),
        mc("Kaç çeyrek bir bütün eder?", ["2", "3", "4"], 2),
        mc("İki çeyrek neye eşittir?", ["Bir yarım", "Bir bütün", "Bir çeyrek"], 0, visual=PIE(4, 2)),
    ]),
    outcome("MAT.2.1.8", lessons=[lesson("Lira ve kuruş", [
        page("Paramızın birimi Türk lirasıdır. 1 lira 100 kuruştur.", V("money", values=[1])),
        page("Madenî paralar: 5, 10, 25, 50 kuruş ve 1 lira. İki tane 50 kuruş 1 lira eder.",
             V("text", text="50 kr + 50 kr = 1 TL")),
    ])], cards=[
        mc("1 lira kaç kuruştur?", ["10", "50", "100"], 2),
        mc("İki tane 50 kuruş kaç lira eder?", ["1 lira", "2 lira", "50 lira"], 0),
        mc("Dört tane 25 kuruş kaç lira eder?", ["1 lira", "4 lira", "25 lira"], 0),
        mc("Hangisi madenî paradır?", ["50 kuruş", "20 TL", "100 TL"], 0),
        mc("10 TL ile 5 TL toplam kaç TL eder?", ["15 TL", "50 TL", "105 TL"], 0, visual=V("money", values=[10, 5])),
    ]),
    outcome("MAT.2.1.9", lessons=[lesson("Saati okuyalım", [
        page("Saatte iki kol vardır: kısa kol akrep saati, uzun kol yelkovan dakikayı gösterir.", V("clock", h=3, m=0)),
        page("Yelkovan 12'deyse saat tamdır. Bu saat 3.", V("clock", h=3, m=0)),
        page("Yelkovan 6'daysa saat buçuktur. Bu saat 3 buçuk.", V("clock", h=3, m=30)),
        page("1 saat 60 dakikadır. 1 gün 24 saattir. 1 hafta 7 gündür.", V("text", text="⏰ 60 dk = 1 saat")),
    ])], cards=[
        gen("clock_read", minutes=[0]),
        gen("clock_read", minutes=[0, 30]),
        gen("clock_read", minutes=[0, 30]),
        mc("1 saat kaç dakikadır?", ["30", "60", "100"], 1),
        mc("1 hafta kaç gündür?", ["5", "7", "10"], 1),
        mc("Pazartesiden sonra hangi gün gelir?", ["Pazar", "Salı", "Cuma"], 1),
        mc("1 yıl kaç aydır?", ["10", "12", "24"], 1),
    ]),
    outcome("MAT.2.1.10", lessons=[lesson("Neden cetvel kullanırız?", [
        page("Senin karışın ile öğretmeninin karışı farklıdır. Bu yüzden aynı masa farklı ölçülür.", V("text", text="✋ ≠ ✋")),
        page("Herkes aynı sonucu bulsun diye cetvel, metre ve terazi kullanırız. Uzunluk birimi metre ve santimetre, ağırlık birimi kilogramdır.",
             V("text", text="📏 ⚖️")),
    ])], cards=[
        mc("Uzunluğu herkesin aynı ölçmesi için ne kullanırız?", ["Karış", "Cetvel", "Adım"], 1),
        mc("Kütleyi ölçmek için hangisini kullanırız?", ["Terazi", "Cetvel", "Saat"], 0),
        mc("İki çocuk aynı masayı karışla ölçtü, farklı sonuç buldu. Neden?", ["Karışları farklı", "Masa küçüldü", "Saymayı bilmiyorlar"], 0),
        mc("Hangisi uzunluk birimidir?", ["Kilogram", "Metre", "Saat"], 1),
    ]),
    outcome("MAT.2.1.11", lessons=[lesson("Metre, santimetre, kilogram", [
        page("1 metre 100 santimetredir. Kapının yüksekliği yaklaşık 2 metredir.", V("text", text="1 m = 100 cm")),
        page("Bir silgi birkaç santimetre, bir karpuz birkaç kilogram gelir.", V("text", text="📏 cm   🍉 kg")),
    ])], cards=[
        mc("1 metre kaç santimetredir?", ["10", "100", "1000"], 1),
        mc("Bir kalemin uzunluğu yaklaşık ne kadardır?", ["15 cm", "15 m", "150 m"], 0),
        mc("Sınıfın kapısı yaklaşık ne kadar yüksektir?", ["2 cm", "2 m", "20 m"], 1),
        mc("Bir karpuz yaklaşık kaç kilogram gelir?", ["5 kg", "500 kg", "5000 kg"], 0),
        mc("Bir çocuğun boyu yaklaşık ne kadardır?", ["120 cm", "12 cm", "1200 cm"], 0),
    ]),
    outcome("MAT.2.2.1", lessons=[lesson("Problem çözelim", [
        page("Problemi dikkatlice dinle: Ne biliyoruz? Ne soruluyor?", V("text", text="❓ ➜ ✏️ ➜ ✅")),
        page("“Toplam”, “hepsi”, “daha geldi” dersek toplarız. “Kaldı”, “fark”, “gitti” dersek çıkarırız.", V("text", text="➕   ➖")),
    ])], cards=[
        gen("word_add_sub", max=20),
        gen("word_add_sub", max=50),
        gen("word_add_sub", max=100),
        mc("Sınıfta 14 kız, 12 erkek var. Sınıfta toplam kaç öğrenci var?", ["2", "26", "24"], 1),
        mc("Otobüste 35 kişi vardı. 10 kişi indi. Kaç kişi kaldı?", ["25", "45", "15"], 0),
    ]),
    outcome("MAT.2.2.2", lessons=[lesson("Zihinden işlem", [
        page("Onlukları ve birlikleri ayrı ayrı toplayabiliriz: 23 + 14 → 20 + 10 = 30, 3 + 4 = 7, sonuç 37!",
             V("text", text="23 + 14 = 37")),
        page("Önce tahmin et: 48 + 31 yaklaşık 50 + 30 = 80. Gerçek sonuç 79. Tahminimiz çok yakın!",
             V("text", text="48 + 31 ≈ 80")),
    ])], cards=[
        gen("add", max_sum=100, carry=False),
        gen("add", min=10, max_sum=100),
        gen("sub", max=100, borrow=False),
        gen("sub", max=100),
        gen("missing_addend", max_sum=20),
    ]),
    outcome("MAT.2.2.3", lessons=[lesson("Toplama ve çıkarma ilişkisi", [
        page("25 + 13 = 38 ise 38 − 13 = 25 ve 38 − 25 = 13 olur.", V("text", text="25 + 13 = 38")),
        page("Çıkarmanın sağlamasını toplama ile yaparız!", V("text", text="38 − 13 = 25  ✓ 25 + 13 = 38")),
    ])], cards=[
        gen("fact_family", max_sum=50),
        gen("fact_family", max_sum=100),
        mc("42 − 17 = 25 işleminin sağlaması hangisidir?", ["25 + 17 = 42", "42 + 17 = 59", "25 − 17 = 8"], 0),
    ]),
    outcome("MAT.2.2.4", lessons=[lesson("Çarpma ve bölme nedir?", [
        page("3 tabakta 2'şer çilek var. 2 + 2 + 2 = 6. Bunu kısaca 3 × 2 = 6 diye yazarız.",
             V("groups", emoji="🍓", groups=3, each=2)),
        page("Bölme paylaştırmaktır: 6 çileği 3 kişiye eşit paylaştırırsak her biri 2 tane alır. 6 ÷ 3 = 2.",
             V("groups", emoji="🍓", groups=3, each=2)),
    ])], cards=[
        gen("multiply_as_add", a_max=5, b_max=5),
        gen("multiply_as_add", a_max=5, b_max=5),
        gen("multiply", a_max=5, b_max=5),
        mc("8 elmayı 2 arkadaş eşit paylaşırsa her biri kaç elma alır?", ["4", "6", "10"], 0, visual=V("objects", emoji="🍎", count=8)),
        mc("12 kalemden 3'er kalemlik demetler yaparsak kaç demet olur?", ["3", "4", "9"], 1),
    ]),
    outcome("MAT.2.2.5", lessons=[lesson("Çarpım tablosu", [
        page("2 ile, 3 ile, 4 ile, 5 ile çarpmayı ezberlemek işlerimizi hızlandırır.", V("text", text="5 × 4 = 20")),
        page("Çarpma işleminde sayıların yeri değişince sonuç değişmez: 3 × 4 = 4 × 3 = 12.", V("text", text="3 × 4 = 4 × 3")),
    ])], cards=[
        gen("multiply", a_max=5, b_max=5),
        gen("multiply", a_min=2, a_max=5, b_min=2, b_max=10),
        gen("divide", q_max=5, d_max=5),
        mc("4 × 5 ile hangisi aynı sonucu verir?", ["5 × 4", "4 + 5", "5 + 5"], 0),
    ]),
    outcome("MAT.2.2.6", lessons=[lesson("Eşitliğin anlamı", [
        page("Eşittir işareti iki yanın aynı değerde olduğunu gösterir: 2 × 5 = 10 = 5 + 5.", V("text", text="2 × 5 = 5 + 5")),
        page("Aynı sonucu farklı işlemlerle bulabiliriz: 12 = 6 + 6 = 3 × 4 = 15 − 3.", V("text", text="12")),
    ])], cards=[
        gen("equal_sides", max_sum=20),
        mc("Hangisi 10'a eşit değildir?", ["5 + 5", "2 × 5", "12 − 3"], 2),
        mc("3 × 2 = ☐ + 1 Kutuya hangi sayı gelir?", ["5", "6", "7"], 0),
        mc("Hangisi doğrudur?", ["4 × 2 = 6 + 2", "4 × 2 = 6 + 3", "4 × 2 = 4 + 3"], 0),
    ]),
    outcome("MAT.2.3.1", lessons=[lesson("Geometrik cisimler", [
        page("Zar bir küptür. Top bir küredir. Konserve kutusu bir silindirdir. Dondurma külahı bir konidir.",
             V("text", text="🎲 ⚽ 🥫 🍦")),
        page("Kürenin köşesi yoktur, yuvarlanır. Küpün 6 yüzü vardır.", V("text", text="⚽   🎲")),
    ])], cards=[
        mc("Zar hangi cisme benzer?", ["Küp", "Küre", "Koni"], 0, visual=V("emoji", emoji="🎲")),
        mc("Top hangi cisme benzer?", ["Silindir", "Küre", "Küp"], 1, visual=V("emoji", emoji="⚽")),
        mc("Konserve kutusu hangi cisme benzer?", ["Silindir", "Koni", "Küre"], 0, visual=V("emoji", emoji="🥫")),
        mc("Küpün kaç yüzü vardır?", ["4", "6", "8"], 1),
        mc("Hangisi yuvarlanabilir?", ["Küre", "Küp", "Kare prizma"], 0),
    ]),
    outcome("MAT.2.3.2", lessons=[lesson("Cisimlerle yapı", [
        page("Küpleri üst üste koyarak kule yapabiliriz. Silindir ve koni ile bir roket yapabiliriz!",
             V("text", text="🧱🧱🧱   🚀")),
    ])], cards=[
        mc("Bir kule yapmak için en uygun cisim hangisi?", ["Küp", "Küre", "Koni"], 0),
        mc("Roketin ucu hangi cisme benzer?", ["Koni", "Küp", "Küre"], 0, visual=V("emoji", emoji="🚀")),
        mc("Kardan adam hangi cisimlerden oluşur?", ["Kürelerden", "Küplerden", "Silindirlerden"], 0, visual=V("emoji", emoji="⛄")),
    ]),
    outcome("MAT.2.3.3", lessons=[lesson("Şekillerle model", [
        page("Bir kare ve bir üçgeni birleştirerek ev çizebiliriz.", V("shapes", items=["ucgen", "kare"])),
        page("İki üçgen birleşince bir kare de oluşturabilir!", V("shapes", items=["ucgen", "ucgen"])),
    ])], cards=[
        mc("Ev çizmek için hangi iki şekil yeterlidir?", ["Kare ve üçgen", "Daire ve daire", "Üçgen ve daire"], 0),
        mc("Bir arabanın tekerlekleri hangi şekle benzer?", ["Daire", "Kare", "Üçgen"], 0, visual=V("emoji", emoji="🚗")),
        mc("Hangi şekillerden bir dondurma çizebiliriz?", ["Üçgen ve daire", "Kare ve kare", "Dikdörtgen ve kare"], 0, visual=V("emoji", emoji="🍦")),
    ]),
    outcome("MAT.2.3.4", lessons=[lesson("Döndürsek de değişmez", [
        page("Bir üçgeni çevirsek de, büyütsek de yine üçgendir. Köşe ve kenar sayısı değişmez.",
             V("shapes", items=["ucgen", "ucgen"])),
    ])], cards=[
        mc("Bir kareyi yan çevirirsek ne olur?", ["Yine karedir", "Üçgen olur", "Daire olur"], 0),
        mc("Büyük bir daire ile küçük bir daire için ne söylenebilir?", ["İkisi de dairedir", "Küçük olan kare olur", "Büyük olan üçgen olur"], 0),
        mc("Ters çevrilen üçgenin kaç köşesi olur?", ["2", "3", "4"], 1),
    ]),
    outcome("MAT.2.3.5", lessons=[lesson("Sıvıları ölçmek", [
        page("Sıvıları bardak, kâse ya da sürahi ile ölçebiliriz.", V("text", text="🥛 🫖 🪣")),
        page("Kova bardağa göre çok daha fazla su alır. Önce tahmin et, sonra ölçerek kontrol et!", V("text", text="🪣 > 🥛")),
    ])], cards=[
        mc("Hangisi daha fazla su alır?", ["Bardak", "Kova"], 1),
        mc("Bir sürahi su yaklaşık kaç bardak eder?", ["Yaklaşık 4 bardak", "Yaklaşık 400 bardak"], 0),
        mc("Akvaryumu bardakla doldurmak mı daha kolay, kovayla mı?", ["Bardakla", "Kovayla"], 1),
    ]),
    outcome("MAT.2.3.6", lessons=[lesson("En kısa yol", [
        page("Hedefe giden birden çok yol olabilir. Adımları sayarak en kısa yolu seçeriz.",
             V("grid", size=5, start=[0, 4], target=[3, 1])),
        page("Kedi önce 3 adım sağa, sonra 3 adım yukarı giderse mamaya ulaşır: toplam 6 adım.",
             V("grid", size=5, start=[0, 4], target=[3, 1])),
    ])], cards=[
        mc("Kedi mamaya en az kaç adımda ulaşır? (sağ, sol, yukarı, aşağı)", ["4", "6", "8"], 1,
           visual=V("grid", size=5, start=[0, 4], target=[3, 1])),
        mc("Kedi mamaya en az kaç adımda ulaşır?", ["3", "5", "7"], 1,
           visual=V("grid", size=5, start=[1, 1], target=[4, 3])),
        mc("Kedi mamaya en az kaç adımda ulaşır?", ["2", "4", "6"], 1,
           visual=V("grid", size=5, start=[2, 0], target=[0, 2])),
    ]),
    outcome("MAT.2.3.7", lessons=[lesson("Simetri", [
        page("Bir şekli ortadan katladığımızda iki yarısı tam üst üste geliyorsa şekil simetriktir.",
             V("text", text="🦋")),
        page("Kelebek, kalp ve yıldız simetriktir.", V("text", text="🦋 ❤️ ⭐")),
    ])], cards=[
        mc("Hangisi simetriktir?", ["🦋", "🦶", "🐌"], 0),
        mc("Hangisi simetriktir?", ["❤️", "🐌", "🦒"], 0),
        mc("Kare simetrik midir?", ["Evet", "Hayır"], 0, visual=V("shapes", items=["kare"])),
        mc("Bir şeklin simetrik olup olmadığını nasıl anlarız?", ["Ortadan katlarız", "Boyarız", "Sayarız"], 0),
    ]),
    outcome("MAT.2.4.1", lessons=[lesson("İki veri grubu", [
        page("Sınıfta kızlara ve erkeklere en sevdikleri meyveyi sorduk. Sonuçları tabloya yazdık.",
             V("pictograph", rows=[{"label": "Kızlar 🍎", "emoji": "🍎", "count": 6},
                                   {"label": "Erkekler 🍎", "emoji": "🍎", "count": 4}])),
        page("Grafiğe bakarak karşılaştırırız: Elmayı seven kızlar, erkeklerden 2 kişi fazla.",
             V("text", text="6 − 4 = 2")),
    ])], cards=[
        mc("Elmayı seven kız sayısı kaçtır?", ["4", "6", "10"], 1,
           visual=V("pictograph", rows=[{"label": "Kızlar", "emoji": "🍎", "count": 6},
                                        {"label": "Erkekler", "emoji": "🍎", "count": 4}])),
        mc("Kızlar erkeklerden kaç kişi fazla?", ["2", "4", "10"], 0,
           visual=V("pictograph", rows=[{"label": "Kızlar", "emoji": "🍎", "count": 6},
                                        {"label": "Erkekler", "emoji": "🍎", "count": 4}])),
        mc("Toplam kaç öğrenci futbolu seçmiş?", ["5", "8", "3"], 1,
           visual=V("pictograph", rows=[{"label": "2-A", "emoji": "⚽", "count": 5},
                                        {"label": "2-B", "emoji": "⚽", "count": 3}])),
        mc("Hangi sınıfta futbolu seçen daha az?", ["2-A", "2-B"], 1,
           visual=V("pictograph", rows=[{"label": "2-A", "emoji": "⚽", "count": 5},
                                        {"label": "2-B", "emoji": "⚽", "count": 3}])),
    ]),
]

PACK = pack("matematik", 2, OUTCOMES)
