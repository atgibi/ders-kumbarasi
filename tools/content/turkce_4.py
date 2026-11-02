"""4. sınıf Türkçe (TYMM T.x.4.x). Metinler özgündür."""

from common import pack, page, mc, act, gen, V
from turkce_common import build, listen, read, T

P = {
    "d1": [
        mc("Bir haber programını izlerken neye dikkat ederiz?", ["Bilginin kaynağına", "Sadece müziğe"], 0),
        listen("Kütüphanemiz cumartesi günleri de açık olacak. Çocuklar için masal saati de düzenlenecek.",
               "Kütüphane hangi gün de açık olacak?", ["Cumartesi", "Pazartesi", "Çarşamba"], 0),
    ],
    "d2": [
        listen("Denizcilik kulübündeki çocuklar kıyıdaki plastik atıkları topladı. Topladıkları şişelerden bir sera yaptılar.",
               "Çocuklar şişelerden ne yaptı?", ["Sera", "Gemi", "Oyuncak"], 0),
        listen("Deniz feneri, gece karanlığında gemilere kıyının nerede olduğunu gösterir. Böylece gemiler kayalara çarpmaz.",
               "Deniz fenerinin görevi nedir?", ["Gemilere yol göstermek", "Balık tutmak"], 0),
    ],
    "d3": [
        listen("Göçmen kuşlar binlerce kilometre yol alır. Yön bulmak için Güneş'i, yıldızları ve Dünya'nın manyetik alanını kullanırlar.",
               "Metne göre kuşlar yönlerini neyle bulur?", ["Güneş, yıldızlar ve manyetik alanla", "Haritayla"], 0),
        listen("Ali bisikletini her gün kask takarak sürerdi. Bir gün düştü ama kaskı sayesinde başı yaralanmadı.",
               "Metnin ana fikri nedir?", ["Güvenlik önlemleri bizi korur", "Bisiklet sürmek tehlikelidir"], 0),
    ],
    "d4": [
        mc("Dinlediğin bir reklamın amacını düşünmek neden önemlidir?", ["Her söylenene hemen inanmamak için", "Önemli değildir"], 0),
        mc("Dinlemeyi kolaylaştıran durum hangisidir?", ["Konuya ilgi duymak", "Uykusuz olmak"], 0),
    ],
    "d5": [
        act("Ailenle bir belgesel izleyin; öğrendiğiniz üç bilgiyi ve merak ettiğin bir soruyu yazın."),
        mc("Dinlediğin bilgiyle ilgili sorular sormak ne sağlar?", ["Daha iyi anlamamı", "Hiçbir şey"], 0),
    ],
    "k1": [
        mc("Bir tartışmada fikrine katılmadığın birine nasıl cevap verirsin?", ["Saygılı bir dille gerekçemi söylerim", "Alay ederim"], 0),
        act("Ailenle bir konuda fikir tartışması yapın; herkes sırayla konuşsun."),
    ],
    "k2": [
        act("Okulunda değiştirmek istediğin bir şeyi gerekçeleriyle ailene sun."),
        act("Bir deyim seçin ve ne anlama geldiğini örnekle anlatın: “Göz atmak”, “Kulak vermek” gibi."),
    ],
    "k3": [
        mc("“Kulak vermek” deyimi ne anlama gelir?", ["Dikkatle dinlemek", "Kulağını göstermek"], 0),
        mc("Resmî bir konuşmada hangi ifade daha uygundur?", ["“Değerli öğretmenlerim…”", "“Hey millet!”"], 0),
    ],
    "k4": [
        mc("Sunum yaparken görsel kullanmak ne sağlar?", ["Anlatılanın daha iyi anlaşılmasını", "Hiçbir şey"], 0),
        act("Bir konuyu anlatmak için bir afiş hazırla ve afişi kullanarak ailene sunum yap."),
    ],
    "k5": [
        act("Sunumundan sonra ailenden iki güçlü yönünü ve bir önerisini dinle."),
        mc("Konuşmamı değerlendirmek için hangi soru uygundur?", ["Ana fikrimi anlatabildim mi?", "Ne giydim?"], 0),
    ],
    "o1_pages": [
        page("Farklı metinleri farklı okuruz: şiiri duygusuyla, bilgilendirici metni dikkatle, hikâyeyi karakterleriyle.", T("📜 📘 📖")),
    ],
    "o1": [
        mc("Bilgilendirici bir metni nasıl okuruz?", ["Dikkatle, gerekirse not alarak", "Hızla atlayarak"], 0),
        act("Ailenle bir şiiri duygusuna uygun tonlamayla sesli okuyun."),
        gen("word_pair"),
    ],
    "o2": [
        read("Sarıkamış'ta yaşayan Zehra, kışın okula kayak takımıyla gidiyordu. Yollar karla kapanınca kayakla gitmek daha kolaydı.",
             "Zehra okula neden kayakla gidiyordu?", ["Yollar karla kapanıyordu", "Kayağı çok seviyordu"], 0),
        read("Bilim fuarında Arda, limondan elektrik üreten bir düzenek kurdu. Küçük bir ampul yandığında herkes alkışladı.",
             "Arda düzeneğinde ne kullandı?", ["Limon", "Rüzgâr", "Su"], 0),
        read("Mahalledeki boş arsa, çocukların önerisiyle bir bahçeye dönüştü. Herkes bir fide dikti ve sulama nöbeti tuttu.",
             "Arsa neye dönüştü?", ["Bahçeye", "Otoparka", "Oyun salonuna"], 0),
    ],
    "o3": [
        read("Yaşlı çınar ağacı köyün meydanında yüzlerce yıldır duruyordu. Köylüler gölgesinde dinlenir, dertleşirdi. Ağaç, köyün hafızası gibiydi.",
             "Metinde ağaç neye benzetilmiştir?", ["Köyün hafızasına", "Bir eve", "Bir dağa"], 0),
        read("Defne, sınıf seçiminde kazanamadı. Üzüldü ama seçilen arkadaşını tebrik etti ve ona yardım etmeye karar verdi.",
             "Metnin ana fikri nedir?", ["Sonuca saygı ve iş birliği önemlidir", "Seçimler gereksizdir"], 0),
        gen("word_pair", kind="zit"),
    ],
    "o4": [
        mc("Bir metni anlamamızı en çok ne kolaylaştırır?", ["Konuyla ilgili ön bilgimiz", "Metnin yazı rengi"], 0),
        mc("Bilmediğimiz bir sözcükle karşılaşınca ne yaparız?", ["Sözlükten anlamına bakarız", "Atlar ve unuturuz"], 0),
    ],
    "o5": [
        act("Bu ay okuduğun kitapları listele; en çok etkilendiğin kitabı ailene nedeniyle anlat."),
        mc("Okumamı geliştirmek için ne yapabilirim?", ["Her gün düzenli okurum", "Sadece tatilde okurum"], 0),
    ],
    "y1_pages": [
        page("Farklı türlerde yazarız: hikâye, mektup, bilgilendirici metin, şiir. Her türün kendine özgü bir planı vardır.", T("📝 ✉️ 📘 📜")),
    ],
    "y1": [
        act("Uzaktaki bir akrabana mektup ya da e-posta yaz: hitap, ana bölüm ve kapanış olsun."),
        mc("Mektubun başında ne bulunur?", ["Hitap (Sevgili …)", "İmza"], 0),
    ],
    "y2": [
        act("Yaşadığın şehri tanıtan bilgilendirici bir paragraf yaz; en az iki bilgi ver."),
        act("İçinde bir deyim ya da atasözü geçen kısa bir hikâye yaz."),
    ],
    "y3": [
        mc("Hangisinde iki nokta (:) doğru kullanılmıştır?", ["Pazardan şunları aldık: elma, armut, kiraz.", "Pazardan: şunları aldık elma."], 0),
        mc("Tırnak işareti (“ ”) ne için kullanılır?", ["Başkasının sözünü aynen aktarmak için", "Sayıları ayırmak için"], 0),
        mc("Hangisi doğru yazılmıştır?", ["23 Nisan'da tören yaptık.", "23 nisanda tören yaptık."], 0),
        mc("Hangisinde “de” bağlacı doğru yazılmıştır?", ["Ben de geleceğim.", "Bende geleceğim."], 0),
    ],
    "y4": [
        mc("Yazmadan önce plan yapmak ne sağlar?", ["Düzenli ve anlaşılır bir metin", "Daha çok hata"], 0),
        act("Yazacağın bir hikâye için önce bir plan yap: karakterler, yer, olay, sonuç."),
    ],
    "y5": [
        act("Yazdığın metni ailenle değerlendirin: ana fikir açık mı, paragraflar düzenli mi, yazım kuralları doğru mu?"),
        mc("Metnimizi geliştirmek için en iyi yol hangisi?", ["Geri bildirim alıp düzeltmek", "Hiç okumadan teslim etmek"], 0),
    ],
}

PACK = pack("turkce", 4, build(4, P))
