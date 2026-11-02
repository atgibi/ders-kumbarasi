"""4. sınıf Sosyal Bilgiler içerik paketi (TYMM SB.4.x.x). Pedagojik onay gerekir."""

from common import pack, outcome, lesson, page, mc, act, V

E = lambda e: V("emoji", emoji=e)
T = lambda t: V("text", text=t)

OUTCOMES = [
    outcome("SB.4.1.1", lessons=[lesson("Sosyal bilgiler neden önemli?", [
        page("Sosyal bilgiler; insanları, toplumu, geçmişi, yaşadığımız yeri ve haklarımızı öğrenmemizi sağlar.", T("👥 🗺️ 🏛️")),
        page("Bu bilgiler iyi bir vatandaş olmamıza ve doğru kararlar vermemize yardım eder.", E("🤝")),
    ])], cards=[
        mc("Sosyal bilgiler dersi bize ne kazandırır?", ["Toplumu ve çevremizi tanımayı", "Sadece hesap yapmayı"], 0),
        mc("Harita okumayı hangi derste öğreniriz?", ["Sosyal bilgiler", "Müzik"], 0),
    ]),
    outcome("SB.4.1.2", lessons=[lesson("Farklılıklara saygı", [
        page("Her bireyin görünüşü, ilgi alanı ve yetenekleri farklıdır. Farklılıklara saygı duyarız.", T("🧑🏻 🧑🏽 🧑🏿")),
    ])], cards=[
        mc("Arkadaşın farklı bir oyun seviyorsa ne düşünürsün?", ["Herkesin ilgisi farklı olabilir", "O yanlış"], 0),
        mc("Hangisi saygılı bir davranıştır?", ["Farklı aksanla konuşan arkadaşla alay etmemek", "Lakap takmak"], 0),
        act("Ailendeki her bireyin farklı bir özelliğini ve bu özelliğin aileye katkısını konuşun."),
    ]),
    outcome("SB.4.1.3", lessons=[lesson("Toplumsal birlik", [
        page("Aile, sınıf ve okulda birlik olursak sorunları birlikte çözeriz.", T("🏠 🏫 🤝")),
    ])], cards=[
        mc("Sınıfta birliği güçlendiren davranış hangisidir?", ["Yardımlaşmak", "Grup oluşturup dışlamak"], 0),
        mc("Sınıf panosunu hazırlarken en iyi yol hangisidir?", ["Herkes bir görev alır", "Bir kişi her şeyi yapar"], 0),
        act("Sınıfında birliği güçlendirecek bir fikir bul ve ailene anlat."),
    ]),
    outcome("SB.4.2.1", lessons=[lesson("Harita okuma", [
        page("Haritalarda kuzey genellikle yukarıdadır. Yön oku ve lejant (açıklama) haritayı okumamızı sağlar.", T("🧭 K ⬆️")),
        page("Lejantta mavi su, yeşil ova, kahverengi dağ gibi renklerin ne anlama geldiği yazar.", T("🟦 🟩 🟫")),
    ])], cards=[
        mc("Haritada kuzey genellikle nerede gösterilir?", ["Yukarıda", "Aşağıda"], 0),
        mc("Haritadaki renk ve işaretlerin anlamı nerede yazar?", ["Lejantta", "Başlıkta"], 0),
        mc("Haritada mavi renk genellikle neyi gösterir?", ["Su (deniz, göl, akarsu)", "Dağları"], 0),
        mc("Kuzeye bakan birinin sağ tarafı hangi yöndür?", ["Doğu", "Batı"], 0),
    ]),
    outcome("SB.4.2.2", lessons=[lesson("Doğa ve insan", [
        page("İnsanlar doğadan yararlanır: tarım, hayvancılık, balıkçılık. Ama doğayı korumak da bizim sorumluluğumuz.", T("🌾 🐄 🎣")),
    ])], cards=[
        mc("Deniz kıyısında yaşayan insanlar hangi işi daha çok yapar?", ["Balıkçılık", "Madencilik"], 0),
        mc("Ormanları kesmek doğayı nasıl etkiler?", ["Zarar verir", "Hiç etkilemez"], 0),
        mc("Verimli ovalarda hangi iş daha çok yapılır?", ["Tarım", "Balıkçılık"], 0),
    ]),
    outcome("SB.4.2.3", lessons=[lesson("Afetlerin etkisini azaltmak", [
        page("Depreme dayanıklı binalar yapmak, afet çantası hazırlamak ve tatbikat yapmak afetlerin etkisini azaltır.", T("🏢 🎒 🔔")),
    ])], cards=[
        mc("Depremin zararını azaltmak için ne yapılır?", ["Dayanıklı binalar yapılır", "Hiçbir şey yapılmaz"], 0),
        mc("Sel riskini azaltmak için ne yapılmalı?", ["Dere yataklarına ev yapılmamalı", "Derelere çöp atılmalı"], 0),
        act("Ailenle afetlerde neler yapılacağını anlatan küçük bir broşür hazırlayın."),
    ]),
    outcome("SB.4.3.1", lessons=[lesson("Oyunlar ve oyuncaklar", [
        page("Eskiden çocuklar çelik çomak, saklambaç, seksek oynar; tahta ve bezden oyuncaklar yaparlardı.", T("🪵 🪁 🧸")),
        page("Bugün dijital oyunlar var ama geleneksel oyunlar hâlâ çok eğlenceli!", T("🎮 🪁")),
    ])], cards=[
        mc("Hangisi geleneksel bir çocuk oyunudur?", ["Seksek", "Bilgisayar oyunu"], 0),
        mc("Eskiden oyuncaklar genellikle neyden yapılırdı?", ["Tahta ve bezden", "Plastikten"], 0),
        act("Büyüklerine çocukken oynadıkları bir oyunu sor ve birlikte oynayın."),
    ]),
    outcome("SB.4.3.2", lessons=[lesson("Aile tarihim", [
        page("Aile ağacı; anne, baba, dede, nine ve diğer akrabalarımızı gösterir.", T("🌳 👴👵 👨👩 🧒")),
    ])], cards=[
        mc("Aile ağacında annemizin annesi nerede bulunur?", ["Anneanne olarak üst sırada", "Kardeşimizin yanında"], 0),
        mc("Aile tarihimizi öğrenmek için kime başvurabiliriz?", ["Büyüklerimize", "Hiç kimseye"], 0),
        act("Ailenle birlikte üç kuşaklık bir aile ağacı çizin."),
    ]),
    outcome("SB.4.3.3", lessons=[lesson("Ortak mirasımız", [
        page("Türkülerimiz, yemeklerimiz, el sanatlarımız ve tarihî yapılarımız ortak mirasımızdır.", T("🎶 🍲 🧶 🕌")),
    ])], cards=[
        mc("Hangisi ortak mirasımızdır?", ["Geleneksel el sanatları", "Yeni bir otopark"], 0),
        mc("Ortak mirasımızı neden koruruz?", ["Geleceğe aktarmak için", "Gereksiz olduğu için"], 0),
        act("Yaşadığınız yöreye ait bir yemeği, türküyü ya da el sanatını ailenle araştırın."),
    ]),
    outcome("SB.4.4.1", lessons=[lesson("Millî Mücadele", [
        page("Mustafa Kemal 19 Mayıs 1919'da Samsun'a çıktı ve Millî Mücadele'yi başlattı.", T("19 Mayıs 1919 · Samsun")),
        page("23 Nisan 1920'de Türkiye Büyük Millet Meclisi açıldı. 30 Ağustos 1922'de Büyük Zafer kazanıldı. Kadınlar, çocuklar herkes fedakârlık yaptı.", T("23 Nisan 1920 · 30 Ağustos 1922")),
    ])], cards=[
        mc("Mustafa Kemal Samsun'a hangi tarihte çıktı?", ["19 Mayıs 1919", "29 Ekim 1923"], 0),
        mc("TBMM hangi tarihte açıldı?", ["23 Nisan 1920", "30 Ağustos 1922"], 0),
        mc("Millî Mücadele'de kimler fedakârlık yaptı?", ["Kadın, erkek, çocuk bütün millet", "Sadece askerler"], 0),
    ]),
    outcome("SB.4.4.2", lessons=[lesson("Cumhuriyetin getirdikleri", [
        page("Cumhuriyet 29 Ekim 1923'te ilan edildi. Yeni Türk harfleri kabul edildi, okuma yazma kolaylaştı.", T("🔤 1928")),
        page("Kadınlara seçme ve seçilme hakkı verildi; herkes soyadı aldı.", T("🗳️ 1934")),
    ])], cards=[
        mc("Cumhuriyet hangi tarihte ilan edildi?", ["29 Ekim 1923", "23 Nisan 1920"], 0),
        mc("Yeni Türk harflerinin kabulü neyi kolaylaştırdı?", ["Okuma yazma öğrenmeyi", "Uzun yolculuğu"], 0),
        mc("Kadınlara seçme ve seçilme hakkı hangi yönetim döneminde verildi?", ["Cumhuriyet döneminde", "Hiç verilmedi"], 0),
    ]),
    outcome("SB.4.4.3", lessons=[lesson("Okulda demokrasi", [
        page("Okul meclisi seçimlerinde aday olabilir, oy verebiliriz. Kararlar birlikte alınır.", T("🗳️ 🏫")),
    ])], cards=[
        mc("Sınıf başkanı nasıl seçilir?", ["Gizli oylamayla", "Öğretmenin rastgele seçmesiyle"], 0),
        mc("Seçimde oy vermek neden önemlidir?", ["Fikrimizi söylememizi sağlar", "Önemsizdir"], 0),
        act("Okulunda çözülmesini istediğin bir sorunu ve önerini ailene anlat; nasıl oylanabileceğini konuşun."),
    ]),
    outcome("SB.4.5.1", lessons=[lesson("Grafik okuma", [
        page("Grafikler bir ailenin ya da şehrin ne kadar su, elektrik harcadığını gösterebilir.",
             V("pictograph", rows=[{"label": "Ocak", "emoji": "💧", "count": 6}, {"label": "Şubat", "emoji": "💧", "count": 4}])),
    ])], cards=[
        mc("Grafiğe göre hangi ay daha çok su harcanmış?", ["Ocak", "Şubat"], 0,
           visual=V("pictograph", rows=[{"label": "Ocak", "emoji": "💧", "count": 6}, {"label": "Şubat", "emoji": "💧", "count": 4}])),
        mc("Şubatta su tüketimi azalmış. Bunun nedeni hangisi olabilir?", ["Musluklar kapalı tutuldu", "Musluklar açık bırakıldı"], 0),
        mc("Her 💡 10 birim elektriği gösteriyorsa Mart'ta kaç birim harcanmış?", ["3", "30", "300"], 1,
           visual=V("pictograph", rows=[{"label": "Mart", "emoji": "💡", "count": 3}])),
    ]),
    outcome("SB.4.5.2", lessons=[lesson("İstek ve ihtiyaç", [
        page("İhtiyaçlar yaşamak için gereklidir: yiyecek, su, barınak, giysi. İstekler olmasa da yaşayabileceğimiz şeylerdir: yeni oyuncak.", T("🍞 🏠  |  🎮")),
        page("Paramızı önce ihtiyaçlarımız için harcarız; kalanını biriktiririz.", T("💰 → 🍞 → 🌰")),
    ])], cards=[
        mc("Hangisi bir ihtiyaçtır?", ["Su", "Yeni oyun konsolu"], 0),
        mc("Hangisi bir istektir?", ["Pahalı bir oyuncak", "Kışlık mont"], 0),
        mc("Harçlığını nasıl kullanmak daha bilinçlidir?", ["Önce ihtiyaçlar, sonra birikim", "Hepsini hemen istediklerime harcamak"], 0),
        act("Ailenle bu hafta alınacakları istek ve ihtiyaç olarak iki listeye ayırın."),
    ]),
    outcome("SB.4.5.3", lessons=[lesson("Üretim, dağıtım, tüketim", [
        page("Ekmek: çiftçi buğdayı üretir, değirmende un olur, fırında ekmek yapılır, markete dağıtılır, biz tüketiriz.", T("🌾 → 🏭 → 🥖 → 🚚 → 🏪 → 🧒")),
    ])], cards=[
        mc("Ekmeğin yolculuğu nereden başlar?", ["Tarlada buğdaydan", "Marketten"], 0),
        mc("Ürünleri marketlere ulaştırmaya ne denir?", ["Dağıtım", "Üretim", "Tüketim"], 0),
        mc("Ekmeği satın alıp yememize ne denir?", ["Tüketim", "Üretim"], 0),
    ]),
    outcome("SB.4.6.1", lessons=[lesson("Çevrim içi güvenlik", [
        page("Güçlü şifre kullanırız ve kimseyle paylaşmayız. Tanımadığımız bağlantılara tıklamayız.", T("🔐 🚫🔗")),
        page("Çevrim içi ortamda da nazik oluruz; kimseye zorbalık yapmayız.", E("💬")),
    ])], cards=[
        mc("Hangisi güçlü bir şifredir?", ["Uzun, harf ve rakam karışık", "1234"], 0),
        mc("Tanımadığın birinden gelen bağlantıya ne yaparsın?", ["Tıklamam, aileme söylerim", "Hemen tıklarım"], 0),
        mc("Çevrim içi oyunda biri arkadaşına kötü sözler söylüyorsa?", ["Bir büyüğe haber veririm", "Ben de katılırım"], 0),
    ]),
    outcome("SB.4.6.2", lessons=[lesson("Bilim insanlarının çocukluğu", [
        page("Aziz Sancar Mardin'de doğdu; çocukken çok kitap okurdu. Bilim insanları da bizim gibi meraklı çocuklardı.", T("📚 🧒")),
    ])], cards=[
        mc("Bilim insanlarının çocukluğunda en sık görülen özellik hangisidir?", ["Merak ve okuma sevgisi", "Hiç soru sormamak"], 0),
        mc("Nobel Ödüllü Aziz Sancar nerede doğmuştur?", ["Mardin", "İzmir"], 0),
        act("Bir bilim insanının çocukluğunu ailenle araştırın ve senin çocukluğunla benzer yönlerini bulun."),
    ]),
]

PACK = pack("sosyal_bilgiler", 4, OUTCOMES)
