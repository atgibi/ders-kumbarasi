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
                page("Usta Çark'ın saat kulesinde dişliler karışmış! Kuleyi çalıştırmak için dişlileri saymamız gerek. "
                     "Haydi, birlikte sayalım.", V("emoji", emoji="⚙️"),
                     say="Usta Çark'ın saat kulesinde dişliler karışmış! Kuleyi çalıştırmak için dişlileri saymamız gerek. Haydi, birlikte sayalım."),
                page("Her dişliye bir kez dokun ve bir sayı söyle: bir, iki, üç, dört, beş. "
                     "Son söylediğin sayı, kaç tane olduğunu gösterir: 5 dişli!", V("objects", emoji="⚙️", count=5)),
                page("Kaç tane olduğunu rakamla yazarız. Beş dişliyi 5 rakamıyla gösteririz. "
                     "Rakamlar şunlar: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9.", V("number_line", **{"from": 0, "to": 9, "mark": 5})),
                page("9'dan sonra 10 gelir. 10'dan sonra 11, 12, 13 diye 20'ye kadar sayarız. "
                     "Her adımda bir fazlası gelir.", V("number_line", **{"from": 10, "to": 20})),
                page("Anka sayıyor: “Burada kaç yıldız var? Birine dokunuyorum: bir. Sonrakine: iki… "
                     "Sonuncuya: on iki. Son söylediğim sayı 12, demek ki 12 yıldız var!”",
                     V("objects", emoji="⭐", count=12)),
                page("Dikkat! En sık yapılan hata: aynı nesneyi iki kez saymak ya da birini atlamak. "
                     "Saydığına parmağınla dokun, sonra yanındakine geç.", V("objects", emoji="🍎", count=7)),
                page("Özet: Her nesneye bir kez dokun, bir sayı söyle. Son söylediğin sayı, kaç tane olduğunu gösterir.",
                     V("text", text="⚙️⚙️⚙️ = 3")),
            ]),
            lesson("Parmaklarla saymak", [
                page("Sayarken zorlandıysan ellerini kullan! Bir elinde 5 parmak var.", V("text", text="🖐️ = 5")),
                page("İki elin 10 parmak eder. 10'dan sonrasını saymak için bir arkadaşının ellerini de ekleyebilirsin.",
                     V("text", text="🖐️🖐️ = 10")),
                page("7'yi göstermek için bir elini tam aç, diğer elinden 2 parmak aç: 5 ve 2, 7 eder.",
                     V("objects2", emoji="☝️", a=5, b=2)),
            ], alt=True),
        ],
        cards=[
            gen("count_objects", max=5),
            gen("count_objects", min=4, max=10),
            gen("count_objects", min=8, max=15),
            gen("count_objects", min=11, max=20),
            mc("Hangisi “yedi” sayısıdır?", ["7", "1", "9"], 0, say="Hangisi yedi sayısı?",
               why={1: "1 “bir” demek. Yedi, 7 diye yazılır; üstünde düz bir çizgi vardır.",
                    2: "9 “dokuz” demek. Yedi, 7 diye yazılır."}),
            mc("Hangisi “on iki” sayısıdır?", ["21", "12", "2"], 1, say="Hangisi on iki sayısı?",
               explain="On iki: bir onluk ve iki birlik, 12 diye yazılır.",
               why={0: "21 “yirmi bir” okunur. On iki yazarken önce 1, sonra 2 yazarız: 12.",
                    2: "2 yalnızca “iki” demek. On iki için önce 1 onluk yazarız: 12."}),
            mc("Hangisi “on dokuz” sayısıdır?", ["9", "91", "19"], 2, say="Hangisi on dokuz sayısı?",
               why={0: "9 yalnızca “dokuz”. On dokuzda bir onluk daha var: 19.",
                    1: "91 “doksan bir” okunur. On dokuz yazarken önce 1, sonra 9 gelir: 19."}),
            mc("İki elimizde toplam kaç parmak var?", ["5", "10", "20"], 1,
               visual=V("text", text="🖐️🖐️"), explain="Bir elimizde 5, iki elimizde 10 parmak var.",
               why={0: "5 yalnızca bir elimizdeki parmaklar. İki el var: 5 ve 5, 10 eder.",
                    2: "20 parmak için eller ve ayaklar birlikte sayılır. İki elde 10 parmak var."}),
            mc("Sayı doğrusunda 14'ten hemen sonra hangi sayı gelir?", ["13", "15", "41"], 1,
               visual=V("number_line", **{"from": 10, "to": 20, "mark": 14}),
               say="On dörtten hemen sonra hangi sayı gelir?",
               why={0: "13, 14'ten hemen önce gelir. Sonra gelen bir fazlasıdır: 15.",
                    2: "41 “kırk bir” okunur, rakamlar yer değiştirmiş. 14'ten sonra 15 gelir."}),
            mc("Eksik sayı hangisi?", ["16", "18", "17"], 2,
               visual=V("number_line", **{"from": 13, "to": 19, "missing": 17}),
               say="Sayı doğrusunda bir sayı eksik. Eksik sayı hangisi?",
               why={0: "16 zaten yerinde. 16'dan sonra, 18'den önce gelen sayı 17.",
                    1: "18 zaten yerinde. Eksik olan 16 ile 18 arasındaki sayı: 17."}),
            mc("Usta Çark 3 dişli daha getirdi. Şimdi 10 dişli var. Daha önce kaç dişli vardı?", ["7", "13", "3"], 0,
               visual=V("objects", emoji="⚙️", count=10),
               why={1: "Dişli sayısı arttı, yani önceden daha azdı. 10'dan 3 geri say: 9, 8, 7.",
                    2: "3, getirilen dişliler. Önceden olanları bulmak için 10'dan 3 geri say: 7."}),
        ],
    ),
    outcome(
        "MAT.1.1.2",
        lessons=[
            lesson("Parçalarla saymak", [
                page("Demirdağ'ın madeninde cüceler parlak taşları iki sepete koymuş. Toplam kaç taş olduğunu bulalım!",
                     V("emoji", emoji="⛏️")),
                page("Dağınık duran taşları saymak zordur. Onları gruplara ayırırız: burada 3 taş ve 4 taş var.",
                     V("objects2", emoji="💎", a=3, b=4)),
                page("İki parçayı birlikte sayınca: bir, iki, üç… yedi! 3 ve 4 birlikte 7 eder. "
                     "Parçalar birleşince bütünü buluruz.", V("objects2", emoji="💎", a=3, b=4)),
                page("Aynı 7 taşı başka türlü de ayırabiliriz: 5 ve 2, ya da 6 ve 1. Bütün yine 7'dir.",
                     V("objects2", emoji="💎", a=5, b=2)),
                page("Anka düşünüyor: “Beşerli grup görünce hemen 5 derim, sonra devam ederim: 5… 6, 7. "
                     "Böylece her taşı tek tek saymam gerekmez!”", V("objects2", emoji="⭐", a=5, b=2)),
                page("Dikkat! Bir parçayı sayıp diğerini unutmak sık yapılan bir hata. "
                     "Önce birinci sepeti, sonra ikinci sepeti saydığından emin ol.", V("objects2", emoji="🍐", a=4, b=2)),
                page("Özet: Bir grubu parçalara ayırabiliriz. Parçaları birleştirince bütünü buluruz: 3 ve 4, 7 eder.",
                     V("text", text="3 ve 4 → 7")),
            ]),
            lesson("Bir bütün, birçok parça", [
                page("10 elma düşün. Bunları iki tabağa farklı şekillerde koyabiliriz.", V("objects", emoji="🍎", count=10)),
                page("5 ve 5, 6 ve 4, 7 ve 3, 8 ve 2… Hepsinde toplam 10 elma var.", V("objects2", emoji="🍎", a=7, b=3)),
                page("Bir tabakta kaç elma olduğunu biliyorsan, diğerini 10'a kadar sayarak bulursun: 7… 8, 9, 10. Üç elma!",
                     V("number_line", **{"from": 0, "to": 10, "mark": 7})),
            ], alt=True),
        ],
        cards=[
            gen("add", max_sum=10, carry=False),
            gen("missing_addend", max_sum=10),
            mc("5 ve 3 birlikte kaç eder?", ["8", "7", "9"], 0, visual=V("objects2", emoji="🍐", a=5, b=3),
               why={1: "Bir armudu saymamış olabilir misin? 5'ten devam et: 6, 7, 8.",
                    2: "Bir armudu iki kez saymış olabilir misin? 5'ten devam et: 6, 7, 8."}),
            mc("Toplam 6 top var. 4'ü sepette. Kaç tanesi dışarıda?", ["3", "2", "10"], 1,
               visual=V("objects", emoji="⚽", count=6), explain="4 ve 2 birlikte 6 eder.",
               why={0: "4 ve 3, 7 eder; toplam ise 6. 4'ten 6'ya say: 5, 6. İki top.",
                    2: "10, 4 ile 6'yı toplayınca çıkar. Ama 6 zaten bütün. Dışarıdaki parça: 2."}),
            mc("10 yıldızı iki eşit gruba ayırırsak her grupta kaç yıldız olur?", ["5", "4", "6"], 0,
               visual=V("objects", emoji="⭐", count=10),
               why={1: "4 ve 4, 8 eder. İki grup eşit ve toplam 10 olmalı: 5 ve 5.",
                    2: "6 ve 6, 12 eder. İki grup eşit ve toplam 10 olmalı: 5 ve 5."}),
            mc("Cüce Tapa 8 taşı iki sepete koydu. Birinde 5 taş var. Ötekinde kaç taş var?", ["3", "13", "8"], 0,
               visual=V("objects2", emoji="💎", a=5, b=3),
               why={1: "13, 8 ile 5'i toplayınca çıkar. 8 bütün; bir parça 5, öteki parça 3.",
                    2: "8 bütünün kendisi. Bir parça 5 ise öteki 5'ten 8'e kadar: 6, 7, 8. Üç taş."}),
            mc("Hangisi 7 eder?", ["4 ve 3", "4 ve 4", "2 ve 3"], 0,
               why={1: "4 ve 4, 8 eder. 7 için 4 ve 3 gerekir.",
                    2: "2 ve 3, 5 eder. 7 için 4 ve 3 gerekir."}),
            mc("Hangi iki parça 10 eder?", ["6 ve 4", "6 ve 3", "5 ve 4"], 0,
               why={1: "6 ve 3, 9 eder. 10 için bir eksik.",
                    2: "5 ve 4, 9 eder. 10 için bir eksik."}),
        ],
    ),
    outcome(
        "MAT.1.1.3",
        lessons=[
            lesson("Birinci, ikinci, üçüncü", [
                page("Demirdağ'da kervan yola çıkıyor! Arabalar sıraya girdi. Kim önde, kim arkada?",
                     V("row", items=["🐴", "🛒", "🛒", "🛒"])),
                page("Sıraya girdiğimizde kimin kaçıncı olduğunu söyleriz: birinci, ikinci, üçüncü, dördüncü…",
                     V("row", items=["🐢", "🐇", "🐕", "🐈"])),
                page("Önce nereden saymaya başlayacağımızı seçeriz. Soldan sayalım: kaplumbağa birinci, "
                     "tavşan ikinci, köpek üçüncü, kedi dördüncü.", V("row", items=["🐢", "🐇", "🐕", "🐈"])),
                page("Sıra sayısını rakamla da yazabiliriz: 1., 2., 3. Rakamın yanındaki nokta “-ıncı, -inci” demektir.",
                     V("text", text="1. birinci · 2. ikinci · 3. üçüncü")),
                page("Anka soruyor: “Soldan üçüncü hangisi?” Parmağımla soldan başlıyorum: bir, iki, üç. "
                     "Üçüncü köpek!", V("row", items=["🐢", "🐇", "🐕", "🐈"])),
                page("Dikkat! Sağdan mı soldan mı saydığına bak. Soldan birinci olan, sağdan sonuncudur.",
                     V("row", items=["🐢", "🐇", "🐕", "🐈"])),
                page("Özet: Sıra sayıları kimin kaçıncı olduğunu gösterir: birinci, ikinci, üçüncü. "
                     "Önce nereden başladığını söyle!", V("text", text="1. · 2. · 3. · 4.")),
            ]),
            lesson("Yarışta sıralama", [
                page("Bir koşu yarışı düşün. Bitiş çizgisine ilk gelen birinci olur.", V("emoji", emoji="🏁")),
                page("Ondan sonra gelen ikinci, sonra gelen üçüncü olur. En son gelen sonuncudur.",
                     V("row", items=["🥇", "🥈", "🥉"])),
            ], alt=True),
        ],
        cards=[
            gen("ordinal", max=4),
            gen("ordinal", max=6),
            mc("Yarışta en önce gelen kaçıncı olur?", ["Birinci", "Sonuncu", "İkinci"], 0,
               why={1: "Sonuncu, en son gelendir. En önce gelen birinci olur.",
                    2: "İkinci, birinciden hemen sonra gelir. En önce gelen birincidir."}),
            mc("Üç arkadaş sırada. Ortadaki kaçıncıdır?", ["Birinci", "İkinci", "Üçüncü"], 1,
               visual=V("row", items=["🧒", "👧", "👦"]),
               why={0: "Birinci, en baştaki. Ortadaki, birinciden sonra gelir: ikinci.",
                    2: "Üçüncü, en sondaki. Ortadaki ikincidir."}),
            mc("Soldan birinci olan, sağdan kaçıncıdır?", ["Birinci", "Dördüncü", "İkinci"], 1,
               visual=V("row", items=["🐢", "🐇", "🐕", "🐈"]),
               why={0: "Sağdan saymaya kedinin olduğu taraftan başlarız. Kaplumbağa sağdan dördüncü.",
                    2: "Sağdan say: kedi birinci, köpek ikinci, tavşan üçüncü, kaplumbağa dördüncü."}),
            mc("“3.” nasıl okunur?", ["Üç", "Üçüncü", "Otuz"], 1,
               why={0: "Rakamın yanındaki nokta sıra bildirir. 3. “üçüncü” okunur.",
                    2: "Otuz 30 diye yazılır. 3. ise “üçüncü” okunur."}),
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
