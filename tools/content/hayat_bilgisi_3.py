"""3. sınıf Hayat Bilgisi içerik paketi (TYMM HB.3.x.x). Pedagojik onay gerekir."""

from common import pack, outcome, lesson, page, mc, act, V

E = lambda e: V("emoji", emoji=e)
T = lambda t: V("text", text=t)

OUTCOMES = [
    outcome("HB.3.1.1", lessons=[lesson("Güçlü yanlarım", [
        page("Herkesin güçlü olduğu ve geliştirebileceği alanlar vardır. Belki resimde iyisin, okumayı geliştiriyorsun.", T("💪 🌱")),
        page("Geliştirmek istediğimiz alan için küçük hedefler koyarız: “Her gün 10 sayfa okuyacağım.”", E("🎯")),
    ])], cards=[
        mc("Gelişime açık bir alanın için ne yaparsın?", ["Küçük hedefler koyup çalışırım", "Hiç denemem"], 0),
        mc("Bir konuda zorlanmak ne anlama gelir?", ["O konuyu öğrenmekte olduğumu", "Asla öğrenemeyeceğimi"], 0),
        act("Ailenle güçlü olduğun iki şeyi ve geliştirmek istediğin bir şeyi konuşun."),
    ]),
    outcome("HB.3.1.2", lessons=[lesson("Okulda hak ve sorumluluk", [
        page("Okulda eğitim almak, güvende olmak, oyun oynamak hakkımızdır.", T("📚 🛡️ ⚽")),
        page("Derse hazırlıklı gelmek, kurallara uymak ve okul eşyalarını korumak sorumluluğumuzdur.", T("🎒 📋")),
    ])], cards=[
        mc("Hangisi öğrencinin hakkıdır?", ["Eğitim almak", "Sırayı çizmek"], 0),
        mc("Hangisi öğrencinin sorumluluğudur?", ["Ödevini yapmak", "Okul müdürünü atamak"], 0),
        mc("Okul kitaplarına nasıl davranırız?", ["Özenle kullanırız", "Yırtarız"], 0),
    ]),
    outcome("HB.3.1.3", lessons=[lesson("Çocuk hakları", [
        page("Her çocuğun yaşama, eğitim, sağlık, oyun ve korunma hakkı vardır.", T("🧒 📚 🏥 ⚽ 🛡️")),
        page("Çocuk haklarını başkalarına da anlatabiliriz: afiş yapabilir, sınıfta sunabiliriz.", E("🖼️")),
    ])], cards=[
        mc("Hangisi bir çocuk hakkıdır?", ["Oyun oynamak", "Çocukların çalışması"], 0),
        mc("Hangisi çocuk haklarına aykırıdır?", ["Çocuğun okula gönderilmemesi", "Çocuğun oyun oynaması"], 0),
        act("Ailenle bir çocuk hakkını anlatan küçük bir afiş çizin."),
    ]),
    outcome("HB.3.2.1", lessons=[lesson("Sağlığımı koruyorum", [
        page("Dengeli beslenme, temizlik, uyku ve hareket sağlığımızı korur.", T("🥗 🧼 😴 🚴")),
        page("Hastalanınca ilacı yalnızca doktorun önerdiği ve büyüklerin verdiği şekilde kullanırız.", E("💊")),
    ])], cards=[
        mc("Hasta bir arkadaşın ilacını içmek doğru mudur?", ["Hayır", "Evet"], 0),
        mc("Hangisi sağlığımızı korur?", ["Mevsim meyveleri yemek", "Bütün gün ekran başında oturmak"], 0),
        mc("Hapşırırken ne yaparız?", ["Ağzımızı mendil ya da dirseğimizle kapatırız", "Arkadaşımıza doğru hapşırırız"], 0),
    ]),
    outcome("HB.3.2.2", lessons=[lesson("Tehlikeyi fark et", [
        page("Tanımadığımız biri hediye ya da yardım teklif ederek bizi bir yere çağırırsa gitmeyiz.", E("🚫")),
        page("Kaybolursak güvenlik görevlisine, polise ya da çocuklu bir anneye başvururuz.", T("👮 🛡️")),
    ])], cards=[
        mc("Alışveriş merkezinde kaybolursan kime başvurursun?", ["Güvenlik görevlisine", "Tanımadığım herhangi birine dışarıda"], 0),
        mc("Tanımadığın biri “Annen seni bekliyor, gel” derse ne yaparsın?", ["Gitmem, bir büyüğe haber veririm", "Peşinden giderim"], 0),
        mc("Yerde bulduğun açık ilacı ne yaparsın?", ["Dokunmam, bir büyüğe söylerim", "Tadına bakarım"], 0),
    ]),
    outcome("HB.3.2.3", lessons=[lesson("Trafik kuralları neden önemli?", [
        page("Trafik kuralları hepimizin can güvenliği içindir. Yayalar, sürücüler ve bisikletliler kurallara uyar.", T("🚦 🚲 🚶")),
        page("Bisiklet sürerken kask takarız.", E("🪖")),
    ])], cards=[
        mc("Bisiklet sürerken ne takmalıyız?", ["Kask", "Kulaklık"], 0),
        mc("Trafik kurallarına neden uyarız?", ["Can güvenliğimiz için", "Ceza almamak için sadece"], 0),
        act("Trafik kurallarının önemini anlatan bir slogan bul ve ailene söyle."),
    ]),
    outcome("HB.3.3.1", lessons=[lesson("Aile ve toplum", [
        page("Aileler bir araya gelerek toplumu oluşturur. Ailede öğrendiğimiz saygı ve yardımlaşma topluma da yansır.", T("🏠🏠🏠 → 🏘️")),
    ])], cards=[
        mc("Toplum neyin bir araya gelmesiyle oluşur?", ["Ailelerin", "Sadece okulların"], 0),
        mc("Ailede öğrenilen yardımlaşma topluma nasıl yansır?", ["Komşularımıza yardım ederiz", "Hiç yansımaz"], 0),
    ]),
    outcome("HB.3.3.2", lessons=[lesson("Yardıma ihtiyacı olanlar", [
        page("Engelli, yaşlı ya da hasta bireylerin hayatını kolaylaştırabiliriz: rampa, sesli trafik ışığı, alışverişlerine yardım…", T("♿ 🧓")),
    ])], cards=[
        mc("Görme engelli bireyler için yollarda ne bulunur?", ["Hissedilebilir yürüme yolları", "Daha fazla reklam"], 0),
        mc("Yaşlı komşuna nasıl yardım edebilirsin?", ["Market poşetlerini taşımasına yardım ederek", "Kapısını çalıp kaçarak"], 0),
        act("Ailenle birlikte yardıma ihtiyacı olan birine yapabileceğiniz bir iyilik planlayın."),
    ]),
    outcome("HB.3.3.3", lessons=[lesson("Meslekler", [
        page("Doktor, öğretmen, çiftçi, itfaiyeci, mühendis… Her meslek topluma katkı sağlar.", T("🩺 👩‍🏫 👨‍🌾 🚒")),
    ])], cards=[
        mc("Yangını kim söndürür?", ["İtfaiyeci", "Pilot", "Aşçı"], 0, visual=E("🚒")),
        mc("Ekmeğimizin buğdayını kim yetiştirir?", ["Çiftçi", "Polis", "Doktor"], 0),
        mc("Hasta olduğumuzda kime gideriz?", ["Doktora", "Berbere"], 0),
        act("Ailendeki bir büyüğe mesleğini ve topluma katkısını sor."),
    ]),
    outcome("HB.3.4.1", lessons=[lesson("Mirasımızı koruyalım", [
        page("Tarihî mekânlar ve doğal güzellikler geçmişimizi ve geleceğimizi taşır. Onlara zarar vermeyiz.", T("🏰 🌲")),
    ])], cards=[
        mc("Tarihî bir yapıyı gezerken ne yapmamalıyız?", ["Duvarlarına yazı yazmak", "Rehberi dinlemek"], 0),
        mc("Doğal güzellikleri nasıl koruruz?", ["Çöp bırakmayarak", "Ağaçları keserek"], 0),
    ]),
    outcome("HB.3.4.2", lessons=[lesson("Yönetim şeklimiz", [
        page("Ülkemizin yönetim şekli cumhuriyettir. Halk, seçimle yöneticilerini belirler.", T("🗳️ Cumhuriyet")),
        page("Türkiye Büyük Millet Meclisi kanunları yapar. Cumhurbaşkanı devletin başıdır.", T("🏛️ TBMM")),
    ])], cards=[
        mc("Ülkemizin yönetim şekli nedir?", ["Cumhuriyet", "Krallık"], 0),
        mc("Kanunları kim yapar?", ["Türkiye Büyük Millet Meclisi", "Okul müdürü"], 0),
        mc("Cumhuriyette yöneticiler nasıl belirlenir?", ["Seçimle", "Kurayla"], 0),
    ]),
    outcome("HB.3.4.3", lessons=[lesson("Atatürk'ün kişilik özellikleri", [
        page("Atatürk ileri görüşlü, cesur, kararlı, vatansever ve çalışkandı. Bilime ve sanata önem verirdi.", T("🧭 🦁 📚")),
    ])], cards=[
        mc("Hangisi Atatürk'ün kişilik özelliklerindendir?", ["İleri görüşlülük", "Tembellik"], 0),
        mc("Atatürk neye çok önem verirdi?", ["Bilime ve eğitime", "Hiçbir şeye"], 0),
        mc("Atatürk hangi tarihte vefat etmiştir?", ["10 Kasım 1938", "29 Ekim 1923"], 0),
    ]),
    outcome("HB.3.4.4", lessons=[lesson("Birlik ve beraberlik", [
        page("Bir arada olursak zorlukları daha kolay aşarız. Birlik ve beraberlik ülkemizi güçlü kılar.", T("🤝🇹🇷")),
    ])], cards=[
        mc("Birlik ve beraberlik ülkemize ne kazandırır?", ["Güç ve huzur", "Kavga"], 0),
        mc("Hangisi birlik ve beraberliğe örnektir?", ["Afette herkesin yardıma koşması", "Komşuyla küsmek"], 0),
    ]),
    outcome("HB.3.5.1", lessons=[lesson("Doğa olmadan olmaz", [
        page("Su, hava, toprak, bitkiler ve hayvanlar yaşamımız için gereklidir.", T("💧 🌬️ 🌱 🐝")),
        page("Arılar bitkileri tozlaştırır; ağaçlar temiz hava sağlar.", T("🐝 🌳")),
    ])], cards=[
        mc("Ağaçlar bize ne sağlar?", ["Temiz hava", "Gürültü"], 0),
        mc("Arıların doğadaki görevi nedir?", ["Bitkileri tozlaştırmak", "Hiçbir görevi yok"], 0),
        mc("Hangisi olmadan yaşayamayız?", ["Su", "Oyuncak"], 0),
    ]),
    outcome("HB.3.5.2", lessons=[lesson("Kroki", [
        page("Kroki, bir yerin kuşbakışı basit çizimidir. Okulumuzun ya da odamızın krokisini çizebiliriz.", V("grid", size=5, start=[0, 0], target=[4, 4], start_emoji="🏠", target_emoji="🏫")),
    ])], cards=[
        mc("Kroki nedir?", ["Bir yerin kuşbakışı basit çizimi", "Bir şarkı"], 0),
        mc("Bu krokide ev ile okul arasında kaç kare sağa gitmek gerekir?", ["2", "4", "5"], 1,
           visual=V("grid", size=5, start=[0, 2], target=[4, 2], start_emoji="🏠", target_emoji="🏫")),
        act("Odanın krokisini çiz ve ailene yatağının, masanın yerini göster."),
    ]),
    outcome("HB.3.5.3", lessons=[lesson("Afet öncesi, sırası, sonrası", [
        page("Afetten önce hazırlanır, afet sırasında sakin kalır, afetten sonra güvenli alanda bekleriz.", T("📋 → 🧘 → 📍")),
    ])], cards=[
        mc("Afet çantası hazırlamak ne zaman yapılır?", ["Afetten önce", "Afet sırasında"], 0),
        mc("Deprem sırasında ne yapılır?", ["Çök, kapan, tutun", "Asansöre binilir"], 0),
        mc("Deprem bittikten sonra nereye gideriz?", ["Toplanma alanına", "Hasarlı binaya"], 0),
    ]),
    outcome("HB.3.5.4", lessons=[lesson("Sürdürülebilir çevre", [
        page("Kaynakları dikkatli kullanırsak gelecekte de yeterli olur: geri dönüşüm, tasarruf, ağaç dikimi.", T("♻️ 💡 🌳")),
    ])], cards=[
        mc("Hangisi çevreyi korur?", ["Geri dönüşüm yapmak", "Plastik poşeti çok kullanmak"], 0),
        mc("Alışverişe giderken ne götürebiliriz?", ["Bez çanta", "Her seferinde yeni plastik poşet"], 0),
        act("Ailenle evde geri dönüşüm için ayrı bir kutu hazırlayın."),
    ]),
    outcome("HB.3.6.1", lessons=[lesson("Bilim hayatımızda", [
        page("Aşılar, ilaçlar ve elektrik bilimsel çalışmalar sayesinde hayatımıza girdi.", T("💉 💡")),
    ])], cards=[
        mc("Hastalıklardan korunmamızı sağlayan bilimsel buluş hangisidir?", ["Aşı", "Oyuncak araba"], 0),
        mc("Geceleri evimizi aydınlatan buluş hangisidir?", ["Ampul", "Kalem"], 0),
    ]),
    outcome("HB.3.6.2", lessons=[lesson("Teknoloji: yararları ve dikkat edilecekler", [
        page("Teknoloji bilgiye ulaşmayı kolaylaştırır ama uzun süre ekran başında kalmak gözümüze ve sağlığımıza zarar verir.", T("💻 👀")),
    ])], cards=[
        mc("Teknolojinin bir yararı nedir?", ["Bilgiye kolay ulaşmak", "Hareketsiz kalmak"], 0),
        mc("Uzun süre ekran başında kalmak neye zarar verir?", ["Gözlerimize", "Hiçbir şeye"], 0),
    ]),
    outcome("HB.3.6.3", lessons=[lesson("Sanatçılarımız", [
        page("Mimar Sinan, Selimiye Camii gibi muhteşem yapılar yaptı. Osman Hamdi Bey ünlü bir ressamdır.", T("🕌 🎨")),
    ])], cards=[
        mc("Selimiye Camii'nin mimarı kimdir?", ["Mimar Sinan", "Cahit Arf"], 0),
        mc("Osman Hamdi Bey hangi alanda tanınır?", ["Resim", "Matematik"], 0),
        act("Ailenle sevdiğiniz bir sanatçıyı araştırın ve bir eserini birlikte inceleyin."),
    ]),
]

PACK = pack("hayat_bilgisi", 3, OUTCOMES)
