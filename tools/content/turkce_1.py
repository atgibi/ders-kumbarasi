"""1. sınıf Türkçe (TYMM T.x.1.x). İlk okuma yazma harf grupları programdaki
sırayla: 1) a n e t i l  2) o k u r ı m  3) ü s ö y d z  4) ç b g c ş  5) p h v ğ f j
"""

from common import pack, page, mc, act, gen, V
from turkce_common import build, listen, read, T

G1 = ["a", "n", "e", "t", "i", "l"]
G2 = ["o", "k", "u", "r", "ı", "m"]
G3 = ["ü", "s", "ö", "y", "d", "z"]
G45 = ["ç", "b", "g", "c", "ş", "p", "h", "v", "f", "j"]

P = {
    "d1": [
        gen("first_letter", letters=G1),
        gen("first_letter", letters=G2),
        mc("Öğretmen konuşurken ne yaparız?", ["Dinleriz", "Konuşuruz", "Oyun oynarız"], 0),
    ],
    "d2": [
        listen("Ela bahçede bir kedi gördü. Kedi çok acıkmıştı. Ela ona su ve mama verdi.",
               "Ela bahçede ne gördü?", ["Kedi", "Köpek", "Kuş"], 0),
        listen("Ali sabah erkenden kalktı. Elini yüzünü yıkadı, kahvaltı yaptı ve okula gitti.",
               "Ali kahvaltıdan sonra nereye gitti?", ["Okula", "Parka", "Markete"], 0),
        gen("first_letter", letters=G3),
    ],
    "d3": [
        listen("Kuşlar sonbaharda sıcak ülkelere göç eder. İlkbaharda yuvalarına geri dönerler.",
               "Bu metin ne hakkında?", ["Kuşların göçü", "Deniz", "Okul"], 0),
        mc("Hangi ses kedi sesidir?", ["Miyav", "Hav hav", "Mö"], 0, visual=V("emoji", emoji="🐱")),
        gen("first_letter", letters=G45),
    ],
    "d4": [
        mc("Dinlerken bir şeyi anlamadıysan ne yaparsın?", ["Sırası gelince sorarım", "Hiçbir şey yapmam"], 0),
        act("Ailenden biri sana kısa bir masal okusun. Sonra masalı ona sen anlat."),
    ],
    "k1": [
        mc("Sabah sınıfa girince ne deriz?", ["Günaydın", "İyi geceler", "Afiyet olsun"], 0),
        act("Ailene “Günaydın”, “Teşekkür ederim” ve “Lütfen” sözcüklerini kullanarak bir istekte bulun."),
    ],
    "k2": [
        act("Bugün yaşadığın bir şeyi “önce, sonra, en son” diyerek ailene anlat."),
        act("Ailen sana bir resim göstersin. Resimde gördüklerini anlat."),
        mc("Kendini tanıtırken ne söylersin?", ["Adımı ve yaşımı", "Arkadaşımın adresini"], 0),
    ],
    "k3": [
        mc("Konuşurken sesimiz nasıl olmalı?", ["Herkesin duyacağı kadar", "Bağırarak", "Fısıltıyla"], 0),
        act("Bir tekerlemeyi yavaşça ve her sözcüğü doğru söyleyerek ailene söyle."),
    ],
    "k4": [
        act("Bir şey anlattıktan sonra ailene “Beni anladınız mı?” diye sor; anlaşılmayan yeri tekrar anlat."),
        mc("Konuşurken bir sözcüğü yanlış söylersen ne yaparsın?", ["Düzeltip devam ederim", "Konuşmayı bırakırım"], 0),
    ],
    "o1_pages": [
        page("Önce harflerin seslerini öğreniriz. Sesleri birleştirince hece, heceleri birleştirince sözcük oluşur.", T("a + l = al")),
        page("a, n, e, t, i, l harfleriyle “at, el, net, tel, ateş”… gibi sözcükler okuyabiliriz.", T("at · el · tel")),
    ],
    "o1": [
        gen("syllables"),
        gen("syllables"),
        mc("Hangi sözcük “a” ve “l” seslerinden oluşur?", ["al", "el", "il"], 0),
        mc("“e + l” birleşince hangi sözcük olur?", ["el", "al", "ol"], 0),
    ],
    "o2": [
        read("Ela topu attı. Top ağaca takıldı.", "Top nereye takıldı?", ["Ağaca", "Eve", "Okula"], 0),
        read("Can elma aldı. Elmayı annesine verdi.", "Can elmayı kime verdi?", ["Annesine", "Babasına", "Öğretmenine"], 0),
    ],
    "o3": [
        read("Kedi minik ve tüylüydü. Bütün gün oynadı, akşam uyudu.", "Metin ne hakkında?", ["Bir kedi", "Bir araba", "Bir okul"], 0),
        read("Lale yağmurda şemsiyesini açtı. Islanmadan eve vardı.", "Lale neden ıslanmadı?", ["Şemsiyesi vardı", "Yağmur durdu"], 0),
    ],
    "o4": [
        mc("Okumak için hangi ortam daha uygundur?", ["Aydınlık ve sessiz bir oda", "Karanlık ve gürültülü bir yer"], 0),
        mc("Kitap okurken nasıl otururuz?", ["Dik", "Yatarak, kitabı gözümüze yaklaştırarak"], 0),
    ],
    "o5": [
        act("Ailenin yanında kısa bir metni sesli oku. Takıldığın sözcükleri birlikte tekrar edin."),
        mc("Okurken bir sözcüğü yanlış okursan ne yaparsın?", ["Durup doğrusunu tekrar okurum", "Hiç umursamam"], 0),
    ],
    "y1_pages": [
        page("Kalemi doğru tutarız: başparmak ve işaret parmağıyla, orta parmağa dayayarak.", T("✏️")),
        page("Önce çizgi çalışmaları yapar, sonra harfleri doğru yönden yazmayı öğreniriz.", T("〰️ ➜ a")),
    ],
    "y1": [
        act("Bu haftaki harflerden birini defterine 5 kez, doğru yönden yaz ve ailene göster."),
        act("Kendi adını defterine yaz ve süsle."),
        mc("Kalemi hangi parmaklarımızla tutarız?", ["Başparmak ve işaret parmağı", "Serçe parmak"], 0),
    ],
    "y2": [
        act("Bir resim çiz ve altına onu anlatan bir sözcük yaz."),
        mc("“At” sözcüğünü yazmak için hangi harfler gerekir?", ["a ve t", "e ve l", "i ve n"], 0),
    ],
    "y3": [
        mc("Cümle hangi harfle başlar?", ["Büyük harfle", "Küçük harfle"], 0),
        mc("Hangi cümle doğru yazılmıştır?", ["Ali eve geldi.", "ali eve geldi", "Ali eve geldi"], 0),
        mc("Kişi adları nasıl yazılır?", ["Büyük harfle başlar", "Hep küçük harfle"], 0),
        mc("Soru soran cümlenin sonuna ne koyarız?", ["Soru işareti (?)", "Nokta (.)"], 0),
    ],
    "y4": [
        act("Yazdığın bir cümleyi ailenle birlikte kontrol et: büyük harf ve nokta doğru mu?"),
        mc("Sözcükler arasına ne bırakırız?", ["Boşluk", "Hiçbir şey"], 0),
    ],
}

PACK = pack("turkce", 1, build(1, P))
