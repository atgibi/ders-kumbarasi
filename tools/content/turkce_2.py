"""2. sınıf Türkçe (TYMM T.x.2.x). Metinler özgündür."""

from common import pack, page, mc, act, gen, V
from turkce_common import build, listen, read, T

P = {
    "d1": [
        mc("Bir sunumu izlerken hangisi doğrudur?", ["Konuşmacıya bakıp dinlemek", "Arkadaşla konuşmak"], 0),
        listen("Defne kütüphaneye gitti. Hayvanlarla ilgili bir kitap seçti ve sessizce okudu.",
               "Defne nasıl okudu?", ["Sessizce", "Bağırarak", "Şarkı söyleyerek"], 0),
    ],
    "d2": [
        listen("Emir'in dedesi köyde yaşıyor. Yaz tatilinde Emir dedesinin bahçesinde domates topladı.",
               "Emir domatesleri nerede topladı?", ["Dedesinin bahçesinde", "Markette", "Okulda"], 0),
        listen("Zeynep yeni bir fidan dikti. Her gün suladı. Bir ay sonra fidan büyüdü.",
               "Fidan neden büyüdü?", ["Zeynep onu her gün suladı", "Kimse ilgilenmedi"], 0),
        listen("Mert ödevini bitirmeden oyuna başladı. Akşam yorulunca ödevini yapamadı.",
               "Sence Mert ne yapmalıydı?", ["Önce ödevini bitirmeli", "Hiç ödev yapmamalı"], 0),
    ],
    "d3": [
        listen("Arılar çiçeklerden nektar toplar ve bal yapar. Aynı zamanda çiçekleri tozlaştırırlar.",
               "Bu metnin konusu nedir?", ["Arılar", "Kuşlar", "Kediler"], 0),
        listen("Yağmur yağınca toprak ıslanır, bitkiler su içer. Sonra güneş açar ve gökkuşağı görünür.",
               "Metinde ilk ne oluyor?", ["Yağmur yağıyor", "Gökkuşağı çıkıyor"], 0),
    ],
    "d4": [
        mc("Hangi ortamda dinlemek daha zordur?", ["Gürültülü bir yerde", "Sessiz bir odada"], 0),
        mc("Dikkatini toplamak için ne yapabilirsin?", ["Konuşana bakarım", "Başka şeylerle oynarım"], 0),
    ],
    "d5": [
        act("Bir çocuk şarkısı ya da masal dinleyin. Sonra ailene en sevdiğin bölümü anlat."),
        mc("Dinledikten sonra kendine ne sorarsın?", ["Ne anladım?", "Hiçbir şey"], 0),
    ],
    "k1": [
        mc("Konuşmaya başlarken ne yaparız?", ["Selam verip söz alırız", "Başkasının sözünü keseriz"], 0),
        act("Akşam yemeğinde ailene bugün okulda olan bir şeyi sırayla anlat."),
    ],
    "k2": [
        act("En sevdiğin hayvanı ailene 3 cümleyle anlat: neye benziyor, ne yer, nerede yaşar?"),
        act("Bir resimdeki olayı “önce, sonra, en son” diyerek anlat."),
    ],
    "k3": [
        mc("Konuşurken nasıl bir hız uygundur?", ["Ne çok hızlı ne çok yavaş", "Çok hızlı"], 0),
        act("Bir tekerlemeyi doğru telaffuzla ailene söyle: “Şu köşe yaz köşesi, şu köşe kış köşesi.”"),
    ],
    "k4": [
        mc("Heyecanlandığında konuşmadan önce ne yapabilirsin?", ["Derin nefes alırım", "Hızlıca konuşurum"], 0),
        act("Ailenin önünde 1 dakikalık bir kendini tanıtma konuşması yap."),
    ],
    "k5": [
        act("Konuşmandan sonra ailene sor: “Neyi iyi yaptım, neyi geliştirebilirim?”"),
        mc("Konuşmanda bir hata yaptığını fark edersen ne yaparsın?", ["Düzeltirim", "Saklarım"], 0),
    ],
    "o1_pages": [
        page("Akıcı okumak için sözcükleri doğru, uygun hızda ve noktalama işaretlerine dikkat ederek okuruz.", T("📖 ✨")),
    ],
    "o1": [
        gen("syllables"),
        mc("Soru işaretiyle biten cümleyi nasıl okuruz?", ["Soru sorar gibi", "Bağırarak"], 0),
        act("Ailenin yanında bir sayfa kitap oku. Noktalarda kısa duraklamaya dikkat et."),
    ],
    "o2": [
        read("Kerem'in kumbarası doldu. Biriktirdiği parayla kardeşine bir boyama kitabı aldı.",
             "Kerem parasıyla ne aldı?", ["Boyama kitabı", "Top", "Bisiklet"], 0),
        read("Pınar okul bahçesinde yaralı bir kuş buldu. Hemen öğretmenine haber verdi.",
             "Pınar kuşu bulunca ne yaptı?", ["Öğretmenine haber verdi", "Kuşu bıraktı gitti"], 0),
        gen("word_pair", kind="zit"),
    ],
    "o3": [
        read("Ayşe ile Can aynı topu istiyordu. Kavga etmek yerine sırayla oynadılar ve çok eğlendiler.",
             "Bu metnin ana fikri nedir?", ["Paylaşmak eğlencelidir", "Top oynamak yorucudur"], 0),
        read("Kirpi kışa hazırlanmak için yaprak topladı. Kış gelince sıcacık yuvasında uyudu.",
             "Bu metne en uygun başlık hangisi?", ["Kirpinin Kış Hazırlığı", "Yaz Tatili"], 0),
        gen("word_pair", kind="es"),
    ],
    "o4": [
        mc("Okumayı kolaylaştıran ortam hangisi?", ["Aydınlık ve sessiz", "Karanlık ve gürültülü"], 0),
        mc("Kitabı gözümüzden ne kadar uzakta tutarız?", ["Bir karış kadar", "Burnumuza değecek kadar"], 0),
    ],
    "o5": [
        act("Okuduğun bir hikâyeyi ailene özetle ve en sevdiğin karakteri söyle."),
        mc("Bir metni anlamadığında ne yaparsın?", ["Tekrar okurum", "Bırakırım"], 0),
    ],
    "y1_pages": [
        page("Yazarken sözcükler arasında boşluk bırakır, satır sonunda düzenli yazarız.", T("✏️ Ali okula gitti.")),
    ],
    "y1": [
        act("Bir arkadaşına kısa bir mektup yaz: “Merhaba …” diye başla."),
        act("Dün yaptığın bir şeyi 3 cümleyle defterine yaz ve ailene oku."),
    ],
    "y2": [
        act("Bir resim seç ve onunla ilgili 3 cümlelik kısa bir hikâye yaz."),
        mc("Bir hikâyede olaylar nasıl sıralanır?", ["Oluş sırasına göre", "Karışık"], 0),
    ],
    "y3": [
        mc("Hangisi doğru yazılmıştır?", ["Ankara'ya gittik.", "ankara'ya gittik.", "Ankaraya gittik"], 0),
        mc("“mı, mi” soru eki nasıl yazılır?", ["Ayrı yazılır: Geldin mi?", "Bitişik yazılır: Geldinmi?"], 0),
        mc("Sevinç bildiren cümlenin sonuna ne konur?", ["Ünlem (!)", "Soru işareti (?)"], 0),
        mc("Hangisinde virgül doğru kullanılmıştır?", ["Elma, armut ve kiraz aldık.", "Elma armut, ve kiraz aldık."], 0),
    ],
    "y4": [
        mc("Yazarken en çok hangisi işimizi kolaylaştırır?", ["Ne yazacağımı önceden düşünmek", "Acele etmek"], 0),
        act("Yazmaya başlamadan önce ne yazacağını ailene anlat, sonra yaz."),
    ],
    "y5": [
        act("Yazdığın metni ailenle birlikte oku; büyük harf ve noktalama hatalarını düzelt."),
        mc("Yazımızı kontrol ederken neye bakarız?", ["Yazım ve noktalama", "Kâğıdın rengine"], 0),
    ],
}

PACK = pack("turkce", 2, build(2, P))
