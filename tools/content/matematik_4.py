"""4. sınıf Matematik içerik paketi (TYMM MAT.4.x.x).

Not: 4. sınıfta TYMM programı 2027-2028'de uygulanmaya başlar; içerik
yayımlanmış TYMM programına göre hazırlanmıştır. Sabit sorular ve anlatım
metinleri bir sınıf öğretmeninin pedagojik onayından geçmelidir.
"""

from common import pack, outcome, lesson, page, mc, gen, V

PIE = lambda parts, shaded: V("fraction", parts=parts, shaded=shaded)

OUTCOMES = [
    outcome("MAT.4.1.1", lessons=[lesson("Büyük sayılar", [
        page("Binler, on binler ve yüz binlerle altı basamaklı sayılara kadar ulaşırız.", V("text", text="245 318")),
        page("245 318 sayısı “iki yüz kırk beş bin üç yüz on sekiz” diye okunur.", V("text", text="iki yüz kırk beş bin üç yüz on sekiz")),
    ])], cards=[
        gen("number_words", min=1000, max=9999),
        gen("number_words", min=10000, max=99999),
        gen("number_words", min=100000, max=999999),
        mc("Hangisi “yetmiş bin beş”tir?", ["70 005", "70 500", "7005"], 0, say="Hangisi yetmiş bin beş?"),
        mc("Bir milyondan bir eksik olan sayı hangisidir?", ["99 999", "999 999", "100 000"], 1),
    ]),
    outcome("MAT.4.1.2", lessons=[lesson("Basamak ve bölük", [
        page("Sayıları sağdan üçerli gruplara ayırırız: birler bölüğü ve binler bölüğü.", V("text", text="482 | 157")),
        page("482 157 sayısında 4'ün basamak değeri 400 000'dir; sayı değeri ise 4'tür.", V("number_highlight", number=482157, pos=5)),
    ])], cards=[
        gen("place_value", digits=4),
        gen("place_value", digits=5),
        gen("place_value", digits=6),
        mc("35 709 sayısında 5 rakamının basamak değeri kaçtır?", ["5", "500", "5000"], 2),
        mc("Binler bölüğünde kaç basamak vardır?", ["2", "3", "6"], 1),
    ]),
    outcome("MAT.4.1.3", lessons=[lesson("Sıralama ve yuvarlama", [
        page("Basamak sayısı çok olan sayı daha büyüktür. Basamak sayıları eşitse soldan başlayarak karşılaştırırız.", V("text", text="12 450 < 12 504")),
        page("En yakın bine yuvarlarken yüzler basamağına bakarız: 4 680 → 5 000.", V("text", text="4 680 ≈ 5 000")),
    ])], cards=[
        gen("order3", max=999999),
        gen("compare", max=99999),
        gen("round_to", to=10, max=9999),
        gen("round_to", to=100, max=9999),
        mc("8 499 sayısı en yakın bine yuvarlanınca kaç olur?", ["8 000", "8 500", "9 000"], 0),
    ]),
    outcome("MAT.4.1.4", lessons=[lesson("Yüzer ve biner sayma", [
        page("Biner sayarken binler basamağı birer birer artar: 3 000, 4 000, 5 000…", V("text", text="3 000 · 4 000 · 5 000")),
    ])], cards=[
        gen("skip_count", steps=[100]),
        mc("2 500, 3 500, 4 500, ? Sıradaki sayı hangisi?", ["4 600", "5 500", "6 500"], 1),
        mc("9 000, 8 000, 7 000, ? Sıradaki sayı hangisi?", ["6 000", "6 900", "5 000"], 0),
        mc("12 300, 12 400, 12 500, ? Sıradaki sayı hangisi?", ["12 600", "13 500", "12 510"], 0),
    ]),
    outcome("MAT.4.1.5", lessons=[lesson("Örüntüyü genelle", [
        page("Örüntünün kuralını bulursak 10. adımı bile hesaplayabiliriz.", V("text", text="4 · 8 · 12 · 16 …")),
        page("Bu örüntüde her adım, adım sayısının 4 katı: 10. adım 40.", V("text", text="adım × 4")),
    ])], cards=[
        mc("4, 8, 12, 16, … Bu örüntünün 10. adımı kaçtır?", ["20", "40", "44"], 1),
        mc("3, 5, 7, 9, … Bu örüntünün 6. adımı kaçtır?", ["11", "13", "15"], 1),
        mc("100, 90, 80, 70, … Bu örüntünün 8. adımı kaçtır?", ["30", "20", "10"], 0),
        mc("Her adımda 3 kibrit eklenerek üçgenler yapılıyor. 5 üçgen için kaç kibrit gerekir?", ["12", "15", "8"], 1),
    ]),
    outcome("MAT.4.1.6", lessons=[lesson("Kesir çeşitleri", [
        page("Payı paydasından küçük olan kesirler basit kesirdir: 3/5.", PIE(5, 3)),
        page("Payı paydasına eşit ya da büyük olan kesirler bileşik kesirdir: 7/4. Bunu 1 tam 3/4 diye tam sayılı kesir olarak da yazabiliriz.",
             V("text", text="7/4 = 1 3/4")),
    ])], cards=[
        mc("Hangisi basit kesirdir?", ["3/5", "5/3", "4/4"], 0),
        mc("Hangisi bileşik kesirdir?", ["2/7", "9/4", "1/3"], 1),
        mc("5/2 kesri tam sayılı kesir olarak nasıl yazılır?", ["2 tam 1/2", "1 tam 2/5", "5 tam 1/2"], 0),
        mc("1 tam 1/4 hangi bileşik kesre eşittir?", ["5/4", "4/5", "2/4"], 0),
        gen("fraction_read", parts=[3, 4, 5, 6, 8]),
    ]),
    outcome("MAT.4.1.7", lessons=[lesson("Denk kesirler", [
        page("1/2 ile 2/4 aynı büyüklüktedir. Bunlara denk kesirler denir.", PIE(4, 2)),
        page("Pay ve paydayı aynı sayıyla çarparsak denk kesir buluruz: 1/3 = 2/6 = 3/9.", V("text", text="1/3 = 2/6 = 3/9")),
    ])], cards=[
        mc("1/2 kesrine denk olan hangisidir?", ["2/4", "2/3", "1/4"], 0),
        mc("2/3 kesrine denk olan hangisidir?", ["4/6", "3/2", "2/6"], 0),
        mc("3/4 = ☐/8 Kutuya hangi sayı gelir?", ["3", "6", "4"], 1),
        mc("Hangisi 1/5 kesrine denk değildir?", ["2/10", "3/15", "5/10"], 2),
    ]),
    outcome("MAT.4.1.8", lessons=[lesson("Birim kesirleri karşılaştırma", [
        page("Payı 1 olan kesirlerde payda büyüdükçe parça küçülür: 1/2 > 1/4 > 1/8.", PIE(8, 1)),
    ])], cards=[
        gen("fraction_compare", unit=True),
        gen("fraction_compare", unit=True),
        mc("Küçükten büyüğe sıralı olan hangisidir?", ["1/9, 1/5, 1/2", "1/2, 1/5, 1/9", "1/5, 1/2, 1/9"], 0),
    ]),
    outcome("MAT.4.1.9", lessons=[lesson("Paydaları eşit kesirler", [
        page("Paydaları eşit kesirlerde payı büyük olan daha büyüktür: 5/8 > 3/8.", PIE(8, 5)),
    ])], cards=[
        gen("fraction_compare"),
        gen("fraction_compare"),
        mc("Büyükten küçüğe sıralı olan hangisidir?", ["7/10, 4/10, 1/10", "1/10, 4/10, 7/10"], 0),
    ]),
    outcome("MAT.4.1.10", lessons=[lesson("Bir çokluğun kesri", [
        page("12 şekerin 1/3'ünü bulmak için 12'yi 3 eş gruba ayırırız: her grupta 4 şeker.", V("groups", emoji="🍬", groups=3, each=4)),
        page("12'nin 2/3'ü ise iki grup eder: 8 şeker.", V("text", text="12 ÷ 3 × 2 = 8")),
    ])], cards=[
        gen("fraction_of_set", unit=True),
        gen("fraction_of_set"),
        gen("fraction_of_set", d_max=10, k_max=10),
        mc("Bir sınıfın 1/4'ü 6 kişi ise sınıf mevcudu kaçtır?", ["10", "24", "30"], 1),
        mc("40 sayfalık kitabın 3/4'ünü okudum. Kaç sayfa okudum?", ["10", "30", "34"], 1),
    ]),
    outcome("MAT.4.1.11", lessons=[lesson("Kesirlerle toplama ve çıkarma", [
        page("Paydaları eşit kesirleri toplarken payları toplarız, paydayı aynen yazarız: 2/7 + 3/7 = 5/7.", V("text", text="2/7 + 3/7 = 5/7")),
        page("Çıkarırken de payları çıkarırız: 6/9 − 2/9 = 4/9.", V("text", text="6/9 − 2/9 = 4/9")),
    ])], cards=[
        gen("fraction_add_same"),
        gen("fraction_add_same"),
        gen("fraction_add_same", d_max=8),
        mc("3/5 + 2/5 kaç eder?", ["5/5, yani 1 bütün", "5/10", "1/5"], 0),
    ]),
    outcome("MAT.4.1.12", lessons=[lesson("Kesir problemleri", [
        page("Pastanın 2/8'ini Ali, 3/8'ini Ayşe yedi. Toplam 5/8'ini yediler; geriye 3/8 kaldı.", PIE(8, 5)),
    ])], cards=[
        mc("Bir pizzanın 3/8'ini sen, 2/8'ini kardeşin yedi. Toplam ne kadarını yediniz?", ["5/8", "5/16", "1/8"], 0, visual=PIE(8, 5)),
        mc("Bir şişe suyun 4/6'sını içtim. Ne kadarı kaldı?", ["2/6", "4/6", "1/6"], 0),
        mc("Bir yolun 2/5'ini sabah, 1/5'ini öğlen yürüdüm. Ne kadarı kaldı?", ["2/5", "3/5", "1/5"], 0),
    ]),
    outcome("MAT.4.1.13", lessons=[lesson("Birim dönüşümleri", [
        page("km → m → cm: 1 km = 1000 m, 1 m = 100 cm. Büyük birimden küçüğe geçerken çarparız.", V("text", text="× 1000   × 100")),
        page("kg → g: 1 kg = 1000 g. Küçükten büyüğe geçerken böleriz: 3000 g = 3 kg.", V("text", text="3000 g ÷ 1000 = 3 kg")),
    ])], cards=[
        gen("unit_convert", kinds=["m_cm", "km_m", "kg_g", "ton_kg"]),
        gen("unit_convert", kinds=["m_cm", "km_m", "kg_g", "ton_kg"]),
        mc("2500 m kaç km'dir?", ["2 km 500 m", "25 km", "250 km"], 0),
        mc("4000 g kaç kg'dır?", ["4 kg", "40 kg", "400 kg"], 0),
        mc("3 m 25 cm kaç cm'dir?", ["325 cm", "3025 cm", "28 cm"], 0),
    ]),
    outcome("MAT.4.2.1", lessons=[lesson("Zihinden toplama ve çıkarma", [
        page("Sayıları uygun parçalara ayırırız: 398 + 245 → 400 + 245 − 2 = 643.", V("text", text="398 + 245 = 643")),
    ])], cards=[
        gen("add", min=100, max_sum=1000, carry=False),
        gen("sub", max=1000, borrow=False),
        mc("499 + 300 kaç eder?", ["799", "800", "789"], 0),
        mc("1000 − 250 kaç eder?", ["750", "850", "650"], 0),
    ]),
    outcome("MAT.4.2.2", lessons=[lesson("Dört basamaklı sayılarla işlem", [
        page("Toplama ve çıkarmada basamakları alt alta yazar, birlerden başlarız. Elde ve onluk bozmayı unutmayız.",
             V("text", text="2 457 + 1 386 = 3 843")),
    ])], cards=[
        gen("add", min=1000, max_sum=9999),
        gen("add", min=100, max_sum=9999),
        gen("sub", max=9999),
        gen("sub", max=9999),
        gen("fact_family", max_sum=9999),
    ]),
    outcome("MAT.4.2.3", lessons=[lesson("Sonucu tahmin et", [
        page("48 × 5 yaklaşık 50 × 5 = 250 eder. Gerçek sonuç 240; tahminimiz yakın!", V("text", text="48 × 5 ≈ 250")),
    ])], cards=[
        mc("39 × 4 yaklaşık kaç eder?", ["Yaklaşık 120", "Yaklaşık 160", "Yaklaşık 400"], 1),
        mc("298 ÷ 3 yaklaşık kaç eder?", ["Yaklaşık 10", "Yaklaşık 100", "Yaklaşık 1000"], 1),
        mc("61 × 9 yaklaşık kaç eder?", ["Yaklaşık 540", "Yaklaşık 54", "Yaklaşık 5400"], 0),
    ]),
    outcome("MAT.4.2.4", lessons=[lesson("Kısa yollar", [
        page("10 ile çarparken sağa bir sıfır, 100 ile çarparken iki sıfır ekleriz: 37 × 100 = 3 700.", V("text", text="37 × 100 = 3 700")),
        page("Sonu sıfır olan sayıyı 10'a bölerken bir sıfır sileriz: 450 ÷ 10 = 45.", V("text", text="450 ÷ 10 = 45")),
    ])], cards=[
        gen("multiply", a_min=10, a_max=99, b_min=10, b_max=10),
        gen("multiply", a_min=2, a_max=99, b_min=100, b_max=100),
        mc("620 ÷ 10 kaç eder?", ["62", "6 200", "602"], 0),
        mc("5 × 4 × 25 işlemini kolay yoldan yaparsak sonuç kaç olur?", ["500", "250", "100"], 0, hint="4 × 25 = 100"),
    ]),
    outcome("MAT.4.2.5", lessons=[lesson("Çarpma ve bölme işlemi", [
        page("İki basamaklı sayılarla çarparken önce birlerle, sonra onlarla çarpar, sonuçları toplarız: 23 × 14 = 92 + 230 = 322.",
             V("text", text="23 × 14 = 322")),
        page("Bölmenin sağlaması: bölüm × bölen + kalan = bölünen.", V("text", text="17 ÷ 5 = 3 kalan 2 → 3 × 5 + 2 = 17")),
    ])], cards=[
        gen("multiply", a_min=10, a_max=99, b_min=2, b_max=9),
        gen("multiply", a_min=11, a_max=50, b_min=11, b_max=20),
        gen("divide", q_max=50, d_max=9),
        mc("17 ÷ 5 işleminde kalan kaçtır?", ["2", "3", "5"], 0),
    ]),
    outcome("MAT.4.2.6", lessons=[lesson("Yönerge oluştur", [
        page("“Sayıyı 2 ile çarp, 5 çıkar” gibi yönergeler bir işlem makinesine benzer.", V("text", text="⚙️ × 2 − 5")),
    ])], cards=[
        mc("Makine: “3 ile çarp, sonra 4 çıkar”. 6 girerse ne çıkar?", ["14", "22", "10"], 0),
        mc("Makine: “10 ekle, sonra 2'ye böl”. 20 girerse ne çıkar?", ["15", "20", "12"], 0),
        mc("5 girince 15, 7 girince 21 çıkan makinenin kuralı nedir?", ["3 ile çarp", "10 ekle", "14 ekle"], 0),
    ]),
    outcome("MAT.4.2.7", lessons=[lesson("Dört işlem problemleri", [
        page("Bazı problemler iki adımlıdır: önce bir işlem, sonra başka bir işlem gerekir.", V("text", text="1️⃣ ➜ 2️⃣")),
    ])], cards=[
        gen("word_mul_div", max=12),
        gen("word_mul_div", max=12),
        mc("Tanesi 25 TL olan 3 defter alıp 100 TL verdim. Kaç TL para üstü alırım?", ["25 TL", "75 TL", "50 TL"], 0),
        mc("Bir çiftlikte 120 tavuk var. Bunların yarısı beyaz. Kaç tavuk beyaz değildir?", ["60", "120", "40"], 0),
    ]),
    outcome("MAT.4.2.8", lessons=[lesson("Problem kur", [
        page("Bir işlemden bir hikâye kurabiliriz: 4 × 15 = 60 → “4 sınıfın her birinde 15 öğrenci var…”", V("text", text="4 × 15 = 60")),
    ])], cards=[
        mc("“48 ÷ 6” işlemiyle çözülen problem hangisidir?", [
            "48 kalem 6 kutuya eşit dağıtılıyor. Her kutuda kaç kalem olur?",
            "48 kaleme 6 kalem eklendi. Kaç kalem oldu?",
            "6 kutuda 48'er kalem var. Toplam kaç kalem var?"], 0),
        mc("“250 + 175” işlemiyle çözülen problem hangisidir?", [
            "Kumbaramda 250 TL vardı, 175 TL daha attım. Kaç TL oldu?",
            "250 TL'nin 175 TL'sini harcadım. Kaç TL kaldı?",
            "175 kişiye 250'şer TL verildi. Toplam kaç TL?"], 0),
        mc("“12 × 30” işlemiyle çözülen problem hangisidir?", [
            "Bir yılın her ayında 30 gün olsaydı bir yıl kaç gün olurdu?",
            "30 günün 12'sini tatilde geçirdim. Kaç gün kaldı?",
            "12 kitaba 30 kitap eklendi. Kaç kitap oldu?"], 0),
    ]),
    outcome("MAT.4.2.9", lessons=[lesson("Eşitlik", [
        page("Eşitlik bir terazi gibidir: iki kefe de aynı olmalıdır. 6 × 5 = 40 − 10.", V("text", text="⚖️ 6 × 5 = 40 − 10")),
    ])], cards=[
        gen("equal_sides", max_sum=100),
        mc("8 × 3 = 30 − ☐ Kutuya hangi sayı gelir?", ["6", "24", "8"], 0),
        mc("100 ÷ 4 = 5 × ☐ Kutuya hangi sayı gelir?", ["5", "20", "25"], 0),
        mc("Hangisi doğru bir eşitliktir?", ["7 × 6 = 50 − 8", "7 × 6 = 50 − 9", "7 × 6 = 40 + 1"], 0),
    ]),
    outcome("MAT.4.3.1", lessons=[lesson("Cisimlerin açınımı", [
        page("Bir küp kutuyu kenarlarından açıp düzlediğimizde 6 eş kareden oluşan bir açınım elde ederiz.", V("text", text="⬜⬜⬜⬜\n  ⬜\n  ⬜")),
        page("Kare prizmanın açınımında 2 kare ve 4 dikdörtgen bulunur.", V("shapes", items=["kare", "dikdortgen"])),
    ])], cards=[
        mc("Küpün açınımında kaç kare vardır?", ["4", "6", "8"], 1),
        mc("Silindirin açınımında hangi şekiller bulunur?", ["2 daire ve 1 dikdörtgen", "6 kare", "3 üçgen"], 0),
        mc("Bir ayakkabı kutusunun açınımında hangi şekiller bulunur?", ["Dikdörtgenler", "Daireler", "Üçgenler"], 0),
    ]),
    outcome("MAT.4.3.2", lessons=[lesson("Üçgen, kare, dikdörtgen", [
        page("Kenarlarına göre üçgenler: üç kenarı eşit olan eşkenar, iki kenarı eşit olan ikizkenar, hiçbir kenarı eşit olmayan çeşitkenar üçgendir.",
             V("shapes", items=["ucgen"])),
        page("Karenin tüm kenarları eşittir. Dikdörtgenin karşılıklı kenarları eşittir. İkisinin de 4 dik açısı vardır.",
             V("shapes", items=["kare", "dikdortgen"])),
    ])], cards=[
        mc("Kenarları 5 cm, 5 cm, 5 cm olan üçgen hangisidir?", ["Eşkenar", "İkizkenar", "Çeşitkenar"], 0),
        mc("Kenarları 4 cm, 4 cm, 6 cm olan üçgen hangisidir?", ["Eşkenar", "İkizkenar", "Çeşitkenar"], 1),
        mc("Kenarları 3 cm, 4 cm, 5 cm olan üçgen hangisidir?", ["Eşkenar", "İkizkenar", "Çeşitkenar"], 2),
        mc("Dikdörtgenin karşılıklı kenarları için ne söylenir?", ["Eşittir", "Hepsi farklıdır"], 0),
    ]),
    outcome("MAT.4.3.3", lessons=[lesson("Çevreyi ölç", [
        page("Cetvelle her kenarı ölçer, sonra toplarız. Kare ve dikdörtgende kısa yol kullanabiliriz.", V("text", text="Kare: 4 × kenar")),
    ])], cards=[
        gen("perimeter", max=20),
        gen("perimeter", max=30),
        mc("Çevresi 20 cm olan karenin bir kenarı kaç cm'dir?", ["4", "5", "10"], 1),
        mc("Kısa kenarı 3 cm, uzun kenarı 7 cm olan dikdörtgenin çevresi kaç cm'dir?", ["10", "20", "21"], 1),
    ]),
    outcome("MAT.4.3.4", lessons=[lesson("Alan nedir?", [
        page("Bir yüzeyi kaplamak için kaç birim kare gerektiğine o yüzeyin alanı denir.", V("area", w=4, h=3)),
        page("Bu dikdörtgeni 3 sıra, her sırada 4 kare kaplıyor: 12 birim kare.", V("area", w=4, h=3)),
    ])], cards=[
        gen("area_count", max=5),
        gen("area_count", max=6),
        mc("Bir masayı defterlerle kaplamak istiyoruz. Ne bulmuş oluruz?", ["Masanın alanını", "Masanın ağırlığını", "Masanın yaşını"], 0),
    ]),
    outcome("MAT.4.3.5", lessons=[lesson("Açı ve dönme", [
        page("Kapıyı açarken, saatin yelkovanı dönerken açı oluşur. Açı bir dönme miktarıdır.", V("angle", deg=60)),
        page("Yelkovan 12'den 3'e dönünce çeyrek tur, yani dik açı kadar döner.", V("clock", h=12, m=15)),
    ])], cards=[
        mc("Yelkovan 12'den 6'ya dönerse ne kadar döner?", ["Çeyrek tur", "Yarım tur", "Tam tur"], 1),
        mc("Yelkovan 12'den 3'e dönerse hangi açıyı oluşturur?", ["Dar açı", "Dik açı", "Geniş açı"], 1),
        mc("Hangisinde açı oluşur?", ["Makasın iki kolu", "Düz bir ip"], 0),
    ]),
    outcome("MAT.4.3.6", lessons=[lesson("Açıyı ölçmek", [
        page("Açıları kâğıt köşesiyle karşılaştırabiliriz ama herkes aynı sonucu bulsun diye iletki kullanırız. Birimi derecedir.",
             V("text", text="📐 90°")),
    ])], cards=[
        mc("Açı ölçmek için hangi araç kullanılır?", ["İletki", "Terazi", "Saat"], 0),
        mc("Açının ölçü birimi nedir?", ["Derece", "Metre", "Gram"], 0),
        mc("Dik açı kaç derecedir?", ["45", "90", "180"], 1),
    ]),
    outcome("MAT.4.3.7", lessons=[lesson("Dar, dik, geniş açı", [
        page("Dik açı kitabın köşesi gibidir (90°).", V("angle", deg=90)),
        page("Dik açıdan küçük açılar dar açı, büyük açılar geniş açıdır.", V("angle", deg=40)),
    ])], cards=[
        gen("angle_type"),
        gen("angle_type"),
        gen("angle_type"),
        mc("Saat 3'te akrep ile yelkovan arasındaki açı hangi türdendir?", ["Dar", "Dik", "Geniş"], 1, visual=V("clock", h=3, m=0)),
    ]),
    outcome("MAT.4.3.8", lessons=[lesson("Ayna ve simetri", [
        page("Aynada gördüğümüz görüntü, nesnenin simetriğidir. Sağ elimiz aynada sol el gibi görünür.", V("text", text="🙋 | 🙋")),
        page("Simetri doğrusu bir ayna gibidir; iki taraf ona eşit uzaklıktadır.", V("text", text="🦋")),
    ])], cards=[
        mc("Aynada sağ elini kaldıran çocuğun görüntüsü hangi elini kaldırmış gibi görünür?", ["Sol", "Sağ"], 0),
        mc("Simetri doğrusu neye benzer?", ["Aynaya", "Cetvele", "Saate"], 0),
        mc("Hangi harfin yatay simetri doğrusu vardır?", ["B", "F", "G"], 0),
    ]),
    outcome("MAT.4.3.9", lessons=[lesson("Simetriğini çiz", [
        page("Her köşenin simetri doğrusuna uzaklığını sayar, diğer tarafa aynı uzaklıkta işaretleriz.", V("text", text="3 kare ← | → 3 kare")),
    ])], cards=[
        mc("Simetri doğrusuna 4 birim uzaklıktaki noktanın simetriği doğruya kaç birim uzaktadır?", ["2", "4", "8"], 1),
        mc("Bir nokta ile simetriği arasındaki uzaklık 10 birimse nokta doğruya kaç birim uzaktadır?", ["5", "10", "20"], 0),
        mc("Simetri doğrusunun üzerindeki bir noktanın simetriği nerededir?", ["Kendisi", "Çok uzakta", "Hiçbir yerde"], 0),
    ]),
    outcome("MAT.4.3.10", lessons=[lesson("Kodlarla şekil", [
        page("“3 ileri, sağa dön, 3 ileri, sağa dön…” komutlarını 4 kez tekrarlarsak bir kare çizeriz!", V("shapes", items=["kare"])),
    ])], cards=[
        mc("“4 ileri, sağa dön” komutunu 4 kez tekrarlarsak hangi şekil oluşur?", ["Kare", "Üçgen", "Daire"], 0),
        mc("“5 ileri, sağa dön, 2 ileri, sağa dön” komutunu 2 kez tekrarlarsak hangi şekil oluşur?", ["Kare", "Dikdörtgen", "Üçgen"], 1),
        mc("Bir kare çizmek için “sağa dön” komutu kaç kez kullanılır?", ["3", "4", "5"], 1),
    ]),
    outcome("MAT.4.4.1", lessons=[lesson("İmkânsız, olabilir, kesin", [
        page("Yarın güneşin doğması kesindir. Yarın yağmur yağması olabilir. Bir kedinin uçması imkânsızdır.", V("text", text="☀️ kesin · 🌧️ olabilir · 🐱✈️ imkânsız")),
        page("İçinde yalnız kırmızı top olan torbadan kırmızı top çekmek kesindir; mavi top çekmek imkânsızdır.",
             V("text", text="🔴🔴🔴")),
    ])], cards=[
        mc("Bir zar attığımızda 7 gelmesi?", ["İmkânsız", "Olabilir", "Kesin"], 0, visual=V("emoji", emoji="🎲")),
        mc("Bir zar attığımızda 3 gelmesi?", ["İmkânsız", "Olabilir", "Kesin"], 1, visual=V("emoji", emoji="🎲")),
        mc("Pazartesiden sonra salının gelmesi?", ["İmkânsız", "Olabilir", "Kesin"], 2),
        mc("Torbada yalnız mavi toplar var. Kırmızı top çekmek?", ["İmkânsız", "Olabilir", "Kesin"], 0, visual=V("text", text="🔵🔵🔵🔵")),
        mc("Para atınca yazı gelmesi?", ["İmkânsız", "Olabilir", "Kesin"], 1),
    ]),
    outcome("MAT.4.4.2", lessons=[lesson("İki grup veriyi karşılaştır", [
        page("4-A ve 4-B sınıflarında okunan kitap sayılarını grafikte karşılaştırabiliriz.",
             V("pictograph", rows=[{"label": "4-A", "emoji": "📚", "count": 8}, {"label": "4-B", "emoji": "📚", "count": 6}])),
    ])], cards=[
        mc("Hangi sınıf daha çok kitap okumuş?", ["4-A", "4-B"], 0,
           visual=V("pictograph", rows=[{"label": "4-A", "emoji": "📚", "count": 8}, {"label": "4-B", "emoji": "📚", "count": 6}])),
        mc("İki sınıf toplam kaç kitap okumuş?", ["2", "14", "48"], 1,
           visual=V("pictograph", rows=[{"label": "4-A", "emoji": "📚", "count": 8}, {"label": "4-B", "emoji": "📚", "count": 6}])),
        mc("Her 📚 2 kitabı gösteriyorsa 4-A kaç kitap okumuştur?", ["8", "10", "16"], 2,
           visual=V("pictograph", rows=[{"label": "4-A", "emoji": "📚", "count": 8}, {"label": "4-B", "emoji": "📚", "count": 6}])),
    ]),
]

PACK = pack("matematik", 4, OUTCOMES)
