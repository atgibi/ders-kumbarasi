"""3. sınıf Fen Bilimleri içerik paketi (TYMM FB.3.x.x). Pedagojik onay gerekir."""

from common import pack, outcome, lesson, page, mc, act, V

E = lambda e: V("emoji", emoji=e)
T = lambda t: V("text", text=t)

OUTCOMES = [
    outcome("FB.3.1.1", lessons=[lesson("Bilgiye nasıl ulaşırız?", [
        page("Bilim insanları soru sorar, gözlem yapar, deney yapar ve güvenilir kaynaklardan araştırır.", T("❓ 👀 🧪 📚")),
        page("Bir şeyi merak edersek önce tahmin eder, sonra deneyle kontrol ederiz.", E("🔍")),
    ])], cards=[
        mc("Bitkilerin ışıksız büyüyüp büyümediğini öğrenmenin en iyi yolu hangisidir?", ["Deney yapmak", "Tahmin edip bırakmak", "Arkadaşa sormak"], 0),
        mc("Hangisi bilimsel bilgiye ulaşma yoludur?", ["Gözlem yapmak", "Rüya görmek"], 0),
        mc("Bilimsel bir araştırma neyle başlar?", ["Merak edip soru sormakla", "Sonucu ezberlemekle"], 0),
    ]),
    outcome("FB.3.1.2", lessons=[lesson("Bilim insanları", [
        page("Bilim insanları meraklı, sabırlı, dikkatli ve sorgulayıcıdır. Hata yapınca vazgeçmez, yeniden denerler.", T("🧑‍🔬")),
    ])], cards=[
        mc("Hangisi bilim insanlarının ortak özelliğidir?", ["Merak", "Sabırsızlık"], 0),
        mc("Deneyi başarısız olan bir bilim insanı ne yapar?", ["Hatasını bulup yeniden dener", "Hemen vazgeçer"], 0),
        mc("Bilim insanları kimlerdir?", ["Kadın ve erkek, farklı ülkelerden insanlar", "Sadece yaşlı erkekler"], 0),
    ]),
    outcome("FB.3.2.1", lessons=[lesson("Canlıları gruplayalım", [
        page("Canlıları dört grupta inceleriz: mikroskopla görülebilen canlılar, mantarlar, bitkiler ve hayvanlar.", T("🔬 🍄 🌿 🐾")),
        page("Bazı canlılar o kadar küçüktür ki onları ancak mikroskopla görebiliriz.", E("🔬")),
    ])], cards=[
        mc("Şapkalı mantar hangi gruptadır?", ["Mantarlar", "Bitkiler", "Hayvanlar"], 0, visual=E("🍄")),
        mc("Gül hangi gruptadır?", ["Bitkiler", "Hayvanlar", "Mantarlar"], 0, visual=E("🌹")),
        mc("Gözle göremediğimiz küçük canlıları nasıl görürüz?", ["Mikroskopla", "Dürbünle", "Gözlükle"], 0),
        mc("Kelebek hangi gruptadır?", ["Hayvanlar", "Bitkiler", "Mantarlar"], 0, visual=E("🦋")),
    ]),
    outcome("FB.3.2.2", lessons=[lesson("Çevremizi algılamak", [
        page("Biz çevremizi göz, kulak, burun, dil ve deri ile algılarız.", T("👁️ 👂 👃 👅 ✋")),
        page("Yarasalar sesle yön bulur, kediler bıyıklarıyla dar yerleri algılar, köpeklerin koku alma duyusu çok güçlüdür.", T("🦇 🐱 🐶")),
    ])], cards=[
        mc("Sıcak ile soğuğu hangi organımızla algılarız?", ["Deri", "Kulak", "Göz"], 0),
        mc("Karanlıkta sesle yön bulan hayvan hangisidir?", ["Yarasa", "Tavuk", "İnek"], 0, visual=E("🦇")),
        mc("Kayıp eşyaları bulmada koku duyusundan yararlanılan hayvan hangisidir?", ["Köpek", "Balık", "Kaplumbağa"], 0),
        mc("Yemeğin tadını hangi organımızla alırız?", ["Dil", "Burun", "Göz"], 0),
    ]),
    outcome("FB.3.2.3", lessons=[lesson("Yaşam döngüsü", [
        page("Kelebeğin yaşam döngüsü: yumurta → tırtıl → pupa → kelebek.", T("🥚 → 🐛 → 🛌 → 🦋")),
        page("Kurbağa: yumurta → iribaş → yavru kurbağa → kurbağa. Bitki: tohum → fide → yetişkin bitki.", T("🥚 → 🐸   🌰 → 🌱 → 🌳")),
    ])], cards=[
        mc("Kelebek yumurtadan ilk olarak ne şekilde çıkar?", ["Tırtıl", "Kelebek", "İribaş"], 0),
        mc("Kurbağanın yavrusuna ne denir?", ["İribaş", "Tırtıl", "Civciv"], 0),
        mc("Bitkinin yaşam döngüsü neyle başlar?", ["Tohum", "Çiçek", "Meyve"], 0),
        mc("Canlıların hepsi için ortak olan hangisidir?", ["Doğar, büyür, ürer ve ölürler", "Hiç değişmezler"], 0),
    ]),
    outcome("FB.3.3.1", lessons=[lesson("Kayaçlar ve madenler", [
        page("Yer kabuğunu oluşturan katı parçalara kayaç denir. Kayaçlar minerallerden oluşur.", E("🪨")),
        page("Demir, bakır ve altın madenlerdir. Madenler araç gereç yapımında kullanılır.", T("⛓️ 🪙")),
    ])], cards=[
        mc("Hangisi bir madendir?", ["Demir", "Odun", "Pamuk"], 0),
        mc("Kayaçlar neyden oluşur?", ["Minerallerden", "Plastikten"], 0),
        mc("Elektrik kablolarında kullanılan maden hangisidir?", ["Bakır", "Taş", "Kum"], 0),
    ]),
    outcome("FB.3.3.2", lessons=[lesson("Fosiller", [
        page("Çok eski zamanlarda yaşamış canlıların kalıntıları ya da izleri kayaçlarda korunabilir. Bunlara fosil denir.", T("🦕 🐚")),
        page("Fosiller, geçmişte hangi canlıların yaşadığını öğrenmemizi sağlar.", E("🦴")),
    ])], cards=[
        mc("Fosil nedir?", ["Eski canlıların kayaçlardaki kalıntı ya da izleri", "Yeni bir bitki"], 0),
        mc("Fosiller bize ne anlatır?", ["Geçmişte yaşamış canlıları", "Yarının hava durumunu"], 0),
        mc("Dinozorları nereden öğreniyoruz?", ["Fosillerden", "Hayvanat bahçesinden"], 0),
    ]),
    outcome("FB.3.4.1", lessons=[lesson("Maddenin hâlleri", [
        page("Maddeler katı, sıvı ve gaz hâlinde bulunur. Taş katı, su sıvı, hava gazdır.", T("🪨 💧 💨")),
        page("Katıların belirli bir şekli vardır. Sıvılar konuldukları kabın şeklini alır. Gazlar bulundukları yeri doldurur.", T("🧊 🥛 🎈")),
    ])], cards=[
        mc("Süt hangi hâldedir?", ["Sıvı", "Katı", "Gaz"], 0, visual=E("🥛")),
        mc("Buz hangi hâldedir?", ["Katı", "Sıvı", "Gaz"], 0, visual=E("🧊")),
        mc("Balonun içindeki hava hangi hâldedir?", ["Gaz", "Katı", "Sıvı"], 0, visual=E("🎈")),
        mc("Konulduğu kabın şeklini alan hangisidir?", ["Su", "Tahta", "Taş"], 0),
    ]),
    outcome("FB.3.4.2", lessons=[lesson("Karışımları ayıralım", [
        page("Kum ve demir tozunu mıknatısla, iri ve küçük taneleri elekle, kum ve suyu süzgeç kâğıdıyla ayırırız.", T("🧲 🪣 ☕")),
        page("Tuzlu sudan tuzu suyu buharlaştırarak ayırırız.", T("🧂💧 → 🧂")),
    ])], cards=[
        mc("Kum ile demir tozunu nasıl ayırırız?", ["Mıknatısla", "Elekle", "Suyla"], 0),
        mc("Un içindeki iri parçaları nasıl ayırırız?", ["Eleme", "Mıknatıs", "Buharlaştırma"], 0),
        mc("Tuzlu sudan tuzu nasıl ayırırız?", ["Buharlaştırarak", "Mıknatısla", "Eleyerek"], 0),
        act("Ailenle birlikte un ve küçük taşları bir elekle ayırmayı deneyin."),
    ]),
    outcome("FB.3.4.3", lessons=[lesson("Atıkları ayıralım", [
        page("Atıkları türlerine göre ayırırsak geri dönüştürülür ve doğa korunur.", T("📄 🧴 🍾 🥫 🍌")),
        page("Pil gibi zararlı atıklar ayrı toplama kutularına atılır.", E("🔋")),
    ])], cards=[
        mc("Kullanılmış pilleri nereye atarız?", ["Atık pil kutusuna", "Normal çöpe", "Toprağa"], 0, visual=E("🔋")),
        mc("Muz kabuğu hangi atık türüdür?", ["Organik atık", "Metal", "Cam"], 0),
        mc("Atıkları ayrı toplamanın faydası nedir?", ["Geri dönüşüm ve çevrenin korunması", "Hiçbir faydası yok"], 0),
    ]),
    outcome("FB.3.5.1", lessons=[lesson("Hareket", [
        page("Varlıklar duruyor ya da hareket ediyor olabilir. Hareket edenler hızlı ya da yavaş olabilir.", T("🐢 🐇")),
        page("Hareket çeşitleri: dönme (dönme dolap), sallanma (salıncak), ileri-geri (testere), düzgün (tren).", T("🎡 🪁 🚂")),
    ])], cards=[
        mc("Dönme dolap hangi hareketi yapar?", ["Dönme", "Sallanma", "İleri-geri"], 0, visual=E("🎡")),
        mc("Hangisi daha hızlı hareket eder?", ["Uçak", "Salyangoz"], 0),
        mc("Salıncak hangi hareketi yapar?", ["Sallanma", "Dönme", "Düz gitme"], 0),
    ]),
    outcome("FB.3.5.2", lessons=[lesson("Kuvvet: itme ve çekme", [
        page("Bir varlığı itebilir ya da çekebiliriz. Buna kuvvet denir.", T("🫸 🫷")),
        page("Kuvvet hareket ettirir, durdurur, yönünü değiştirir ya da şeklini değiştirebilir (hamur gibi).", T("⚽ 🛑 ↪️ 🫓")),
    ])], cards=[
        mc("Kapıyı açarken hangi kuvveti uygularız?", ["İtme ya da çekme", "Hiçbir kuvvet"], 0, visual=E("🚪")),
        mc("Oyun hamuruna bastırınca ne olur?", ["Şekli değişir", "Hiçbir şey olmaz"], 0),
        mc("Kale direğine çarpan top ne olur?", ["Yönü değişir", "Havada kalır"], 0, visual=E("⚽")),
        mc("Bir el arabasını ittiğimizde ne yaparız?", ["İtme kuvveti uygularız", "Çekme kuvveti uygularız"], 0),
    ]),
    outcome("FB.3.6.1", lessons=[lesson("Elektrikli araçlar", [
        page("Bazı araçlar şehir elektriğiyle çalışır: buzdolabı, çamaşır makinesi. Bazıları pille çalışır: oyuncak araba, el feneri.", T("🔌 🔋")),
    ])], cards=[
        mc("Hangisi elektrikle çalışır?", ["Buzdolabı", "Bisiklet", "Makas"], 0),
        mc("El feneri genellikle neyle çalışır?", ["Pille", "Suyla"], 0, visual=E("🔦")),
        mc("Hangisi elektrikle çalışmaz?", ["Kalem", "Televizyon", "Ütü"], 0),
    ]),
    outcome("FB.3.6.2", lessons=[lesson("Elektrik güvenliği", [
        page("Prizlere çatal, tel gibi şeyler sokmayız. Elektrikli araçlara ıslak elle dokunmayız.", T("🚫🔌💧")),
        page("Kopuk kablolara dokunmayız; bir büyüğe haber veririz.", E("⚠️")),
    ])], cards=[
        mc("Elektrikli araçlara nasıl dokunmalıyız?", ["Kuru elle", "Islak elle"], 0),
        mc("Prizlere nasıl davranmalıyız?", ["Prize hiçbir şey sokmam; fişi büyükler takar", "Prize tel ya da çatal sokarım"], 0),
        mc("Kopuk bir kablo görürsen ne yaparsın?", ["Dokunmam, bir büyüğe söylerim", "Elimle tutarım"], 0),
    ]),
    outcome("FB.3.6.3", lessons=[lesson("Elektrik tasarrufu", [
        page("Kullanmadığımız ışıkları ve cihazları kapatırız. Tasarruflu ampuller daha az elektrik harcar.", T("💡 🔌")),
    ])], cards=[
        mc("Elektrik tasarrufu için ne yaparız?", ["Odadan çıkarken ışığı kapatırız", "Bütün ışıkları açık bırakırız"], 0),
        mc("Hangisi daha az elektrik harcar?", ["Tasarruflu (LED) ampul", "Eski tip akkor ampul"], 0),
        act("Ailenle evde gereksiz yanan ışıkları ve fişte unutulan şarj aletlerini bulun."),
    ]),
    outcome("FB.3.7.1", lessons=[lesson("Toprak nasıl oluşur?", [
        page("Kayaçlar rüzgâr, su ve sıcaklık değişimiyle çok uzun sürede ufalanır. Bitki ve hayvan kalıntıları karışınca toprak oluşur.", T("🪨 → 🟫")),
        page("Toprakta taş, kum, kil, su, hava ve çürümüş canlı kalıntıları (humus) bulunur.", E("🪱")),
    ])], cards=[
        mc("Toprak neyin ufalanmasıyla oluşur?", ["Kayaçların", "Plastiklerin"], 0),
        mc("Toprakta hangisi bulunur?", ["Hava ve su", "Elektrik"], 0),
        mc("Toprağın oluşması ne kadar sürer?", ["Çok uzun yıllar", "Bir gün"], 0),
    ]),
    outcome("FB.3.7.2", lessons=[lesson("Bitki nasıl yetişir?", [
        page("Bitkinin büyümesi için su, ışık, hava, uygun sıcaklık ve toprak gerekir.", T("💧 ☀️ 💨 🌡️ 🟫")),
    ])], cards=[
        mc("Karanlık bir dolapta bırakılan bitkiye ne olur?", ["Sararır ve zayıflar", "Daha hızlı büyür"], 0),
        mc("Bitkinin büyümesi için hangisi gerekmez?", ["Müzik", "Su", "Işık"], 0),
        act("Ailenle bir saksıya fasulye ekin ve 10 gün boyunca büyümesini gözlemleyin."),
    ]),
    outcome("FB.3.8.1", lessons=[lesson("Yaşam alanları", [
        page("Canlılar orman, çöl, kutup, deniz gibi farklı yaşam alanlarında yaşar.", T("🌲 🏜️ 🧊 🌊")),
        page("Her canlı yaşam alanına uygun özelliklere sahiptir: kutup ayısının kalın kürkü, devenin hörgücü.", T("🐻‍❄️ 🐫")),
    ])], cards=[
        mc("Deve hangi yaşam alanına uygundur?", ["Çöl", "Kutup", "Deniz"], 0, visual=E("🐫")),
        mc("Kutup ayısını soğuktan koruyan nedir?", ["Kalın kürkü ve yağ tabakası", "Uzun kulakları"], 0),
        mc("Yunus nerede yaşar?", ["Denizde", "Çölde"], 0, visual=E("🐬")),
    ]),
    outcome("FB.3.8.2", lessons=[lesson("Canlı çeşitliliği", [
        page("Bir yaşam alanında pek çok farklı canlı yaşar. Bir ormanda ağaçlar, kuşlar, sincaplar, mantarlar bulunur.", T("🌳 🐦 🐿️ 🍄")),
    ])], cards=[
        mc("Bir ormanda hangisi bulunabilir?", ["Sincap", "Penguen", "Köpekbalığı"], 0),
        mc("Bir yaşam alanında çok sayıda farklı canlının bulunmasına ne denir?", ["Canlı çeşitliliği", "Hava durumu"], 0),
        act("Ailenle bir parkta 5 farklı canlı bulup listeleyin."),
    ]),
    outcome("FB.3.8.3", lessons=[lesson("Yaşam alanlarını koruyalım", [
        page("Ormanları korumak, çöp atmamak ve suları kirletmemek canlıların evlerini korur.", T("🌲 🚯 🌊")),
    ])], cards=[
        mc("Hangisi yaşam alanlarına zarar verir?", ["Ormanda ateş yakmak", "Fidan dikmek"], 0),
        mc("Denizlerin kirlenmesi kimi etkiler?", ["Denizde yaşayan canlıları", "Hiç kimseyi"], 0),
        mc("Kuşlara nasıl yardım edebiliriz?", ["Kuş evi asarak", "Yuvalarını bozarak"], 0),
    ]),
]

PACK = pack("fen_bilimleri", 3, OUTCOMES)
