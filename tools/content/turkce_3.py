"""3. sınıf Türkçe (TYMM T.x.3.x). Metinler özgündür."""

from common import pack, page, mc, act, gen, V
from turkce_common import build, listen, read, T

P = {
    "d1": [
        mc("Bir belgeseli izlerken not almak neye yarar?", ["Önemli bilgileri unutmamamıza", "Hiçbir işe"], 0),
        listen("Kaplumbağalar çok uzun yaşar. Bazıları yüz yıldan fazla yaşayabilir.",
               "Kaplumbağalar hakkında hangisi doğrudur?", ["Çok uzun yaşarlar", "Çok hızlı koşarlar"], 0),
    ],
    "d2": [
        listen("Selin sabah otobüsü kaçırdı çünkü alarmı çalmamıştı. O günden sonra akşamdan alarmını kontrol etti.",
               "Selin neden otobüsü kaçırdı?", ["Alarmı çalmadı", "Otobüs gelmedi"], 0),
        listen("Yaşlı balıkçı her sabah denize açılır, tuttuğu balıkların küçüklerini denize geri bırakırdı.",
               "Balıkçı neden küçük balıkları geri bırakıyordu?", ["Büyüyüp çoğalsınlar diye", "Sevmediği için"], 0),
    ],
    "d3": [
        listen("Su döngüsünde güneş suyu ısıtır, su buharlaşır, bulutlar oluşur ve yağmur yağar. Bu döngü hiç durmaz.",
               "Metnin konusu nedir?", ["Su döngüsü", "Rüzgâr", "Depremler"], 0),
        listen("Burak kaybolan köpeğini bulmak için afişler astı. Komşuları da yardım etti ve köpek bulundu.",
               "Metnin ana fikri nedir?", ["Yardımlaşmak sorunları çözer", "Köpekler kaybolmaz"], 0),
    ],
    "d4": [
        mc("Dinlediğin şeyi daha iyi anlamak için ne yapabilirsin?", ["Önemli yerleri not alırım", "Gözümü kaparım ve uyurum"], 0),
        mc("Dinlemeyi zorlaştıran durum hangisidir?", ["Yorgun olmak", "Dinlenmiş olmak"], 0),
    ],
    "d5": [
        act("Bir radyo ya da podcast programını ailenle dinleyin; öğrendiğiniz iki bilgiyi konuşun."),
        mc("Dinlediğin bilginin doğru olup olmadığını nasıl anlarsın?", ["Başka kaynaklardan kontrol ederim", "Hemen inanırım"], 0),
    ],
    "k1": [
        mc("Sınıfta söz almak için ne yaparız?", ["Parmak kaldırırız", "Bağırırız"], 0),
        act("Ailene en sevdiğin kitabı 1 dakikada tanıt."),
    ],
    "k2": [
        act("Bir konuda fikrini söyle ve nedenini açıkla: “Bence … çünkü …”"),
        act("Ailene bir atasözü söyleyin ve ne anlama geldiğini birlikte konuşun."),
    ],
    "k3": [
        mc("Konuşmada beden dilini nasıl kullanırız?", ["Söylediklerimize uygun hareketlerle", "Hiç kıpırdamadan"], 0),
        mc("“Damlaya damlaya göl olur” ne anlatır?", ["Küçük birikimler büyür", "Yağmur çok yağar"], 0),
    ],
    "k4": [
        mc("Kalabalığın önünde konuşurken heyecanı azaltmak için ne yaparsın?", ["Önceden prova yaparım", "Hiç hazırlanmam"], 0),
        act("Kısa bir konuşma hazırlayıp ailenin önünde prova yap."),
    ],
    "k5": [
        act("Konuşmanı ailenin kaydetmesini iste; dinleyip neyi geliştirebileceğini birlikte bulun."),
        mc("Konuşmamı nasıl değerlendiririm?", ["Anlaşılır ve düzenli miydi diye düşünürüm", "Hiç düşünmem"], 0),
    ],
    "o1_pages": [
        page("Okurken vurgu ve tonlamaya dikkat ederiz. Konuşma çizgisinden sonra karakter gibi okuruz.", T("— Merhaba! dedi tavşan.")),
    ],
    "o1": [
        mc("Ünlemle biten cümleyi nasıl okuruz?", ["Duyguyu belli ederek", "Düz bir sesle"], 0),
        act("Ailenle bir hikâyeyi karakterlere bölünerek sesli okuyun."),
        gen("word_pair"),
    ],
    "o2": [
        read("Ege, büyükannesinden örgü örmeyi öğrendi. İlk atkısını kışın soğuktan üşüyen kardeşine hediye etti.",
             "Ege ilk atkısını kime verdi?", ["Kardeşine", "Büyükannesine", "Öğretmenine"], 0),
        read("Ormandaki yangını ilk fark eden bekçi hemen 112'yi aradı. İtfaiye geldi ve yangın büyümeden söndürüldü.",
             "Yangın neden büyümeden söndürüldü?", ["Bekçi hemen haber verdi", "Yağmur yağdı"], 0),
        read("Melis'in akvaryumundaki balıklar her gün aynı saatte yem bekliyordu. Melis bir gün unutunca balıklar camın önünde toplandı.",
             "Balıklar neden camın önünde toplandı?", ["Yem bekliyorlardı", "Uyuyorlardı"], 0),
    ],
    "o3": [
        read("Karınca yaz boyunca çalıştı, ağustos böceği ise şarkı söyledi. Kış gelince karıncanın yiyeceği vardı.",
             "Metnin ana fikri nedir?", ["Geleceği düşünüp çalışmak önemlidir", "Şarkı söylemek zararlıdır"], 0),
        read("Yusuf her gün 10 sayfa kitap okudu. Bir yılın sonunda tam 20 kitap bitirmişti.",
             "Bu metne en uygun başlık hangisi?", ["Her Gün Biraz", "Tatil Günü"], 0),
        gen("word_pair", kind="es"),
    ],
    "o4": [
        mc("Okurken dikkatimizi dağıtan hangisidir?", ["Televizyonun açık olması", "Sessiz bir oda"], 0),
        mc("Uzun bir metni okumadan önce ne yapmak faydalıdır?", ["Başlığa ve resimlere bakıp tahmin etmek", "Son satırı okumak"], 0),
    ],
    "o5": [
        act("Okuduğun bir kitabın konusunu, ana karakterini ve sevdiğin bölümü ailene anlat."),
        mc("Okuduğunu anladığını nasıl kontrol edersin?", ["Kendime sorular sorarım", "Hızlıca bitiririm"], 0),
    ],
    "y1_pages": [
        page("Yazılarımızda giriş, gelişme ve sonuç bölümleri olur.", T("giriş · gelişme · sonuç")),
    ],
    "y1": [
        act("Bir tatil gününü giriş, gelişme ve sonuç bölümleriyle yaz."),
        mc("Bir hikâyenin sonuç bölümünde ne anlatılır?", ["Olayın nasıl bittiği", "Karakterlerin tanıtımı"], 0),
    ],
    "y2": [
        act("Sevdiğin bir hayvanı anlatan bir paragraf yaz; benzetme kullan: “… gibi”."),
        mc("Hangisinde benzetme vardır?", ["Gözleri yıldız gibi parlıyordu.", "Gözleri kahverengiydi."], 0),
    ],
    "y3": [
        mc("Hangisinde büyük harf doğru kullanılmıştır?", ["Van Gölü çok büyüktür.", "van gölü çok büyüktür."], 0),
        mc("Hangisinde kesme işareti doğru kullanılmıştır?", ["Ayşe'nin kalemi", "Ayşenin kalemi", "Ayşe'n'in kalemi"], 0),
        mc("Konuşma çizgisi (—) nerede kullanılır?", ["Karşılıklı konuşmalarda", "Sayılarda"], 0),
        mc("Hangisi doğru yazılmıştır?", ["Sen de gel.", "Sende gel."], 0),
    ],
    "y4": [
        mc("Yazarken sık sık kalkıp oynamak yazımızı nasıl etkiler?", ["Dikkatimiz dağılır", "Daha güzel olur"], 0),
        act("Yazmak için sessiz bir köşe hazırlayıp 10 dakika boyunca bir anını yaz."),
    ],
    "y5": [
        act("Yazdığın metni ailenle kontrol listesiyle değerlendir: başlık, büyük harf, noktalama, paragraf."),
        mc("Yazdığımızı kontrol etmek neden önemlidir?", ["Hataları düzeltmek için", "Önemli değildir"], 0),
    ],
}

PACK = pack("turkce", 3, build(3, P))
