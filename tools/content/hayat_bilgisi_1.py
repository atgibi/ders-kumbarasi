"""1. sınıf Hayat Bilgisi içerik paketi (TYMM HB.1.x.x).

Duygu, paylaşım ve uygulama gerektiren çıktılarda veliyle etkinlik kartları
kullanılır. Pedagojik onay gerekir.
"""

from common import pack, outcome, lesson, page, mc, act, V

E = lambda e: V("emoji", emoji=e)
T = lambda t: V("text", text=t)

OUTCOMES = [
    outcome("HB.1.1.1", lessons=[
        lesson("Merhaba okul!", [
            page("Ocakvadi'de Nine Pelin'in fırınından mis gibi ekmek kokusu geliyor. Bostancık çocukları "
                 "yeni bir arkadaş bekliyor: sen!", T("🏡 🍞 👋")),
            page("Yeni biriyle tanışırken gülümser, “Merhaba, benim adım …” deriz.", T("😊 Merhaba, ben Elif!")),
            page("Sonra onun adını sorarız: “Senin adın ne?” Böylece birbirimizi tanırız.", T("❓ Senin adın ne?")),
            page("Öğretmenimiz bize yol gösterir, bize yardım eder. Bir şey sormak istersek parmak kaldırırız.",
                 E("🙋")),
            page("Anka tanışıyor: “Merhaba, ben Anka! Kaf Dağı'ndan geldim. Senin adın ne? "
                 "Ne oynamayı seversin?”", T("🦉 👋 🧒")),
            page("Dikkat! Utanmak çok doğal. Önce gülümsemek bile iyi bir başlangıçtır.", T("😊 ✓")),
            page("Özet: Gülümse, adını söyle, onun adını sor. Öğretmenine sormak için parmak kaldır.",
                 T("😊 · 👋 · ❓ · 🙋")),
        ]),
        lesson("Tanışma oyunu", [
            page("Arkadaşınla bir top at-tut oyunu oyna: topu atan adını söylesin.", T("⚽ “Ben Can!”")),
            page("Topu tutan da kendi adını ve sevdiği bir şeyi söylesin. İşte tanıştınız!", T("⚽ “Ben Ela, kedileri severim!”")),
        ], alt=True),
    ], cards=[
        mc("Yeni bir arkadaşla tanışırken ne deriz?", ["Merhaba, benim adım …", "Çekil önümden!", "Hiçbir şey demeyiz"], 0,
           why={1: "Bu söz kaba ve arkadaşımızı üzer. “Merhaba, benim adım …” deriz.",
                2: "Hiçbir şey demezsek tanışamayız. Gülümseyip adımızı söyleriz."}),
        mc("Derste bir şey sormak istersen ne yaparsın?", ["Parmak kaldırırım", "Bağırırım", "Sırama vururum"], 0,
           why={1: "Bağırınca dersi böleriz. Parmak kaldırıp sıramızı bekleriz.",
                2: "Sıraya vurmak gürültü yapar. Parmak kaldırırız."}),
        mc("Arkadaşının adını öğrenmek için ne sorarsın?", ["Senin adın ne?", "Kaç yaşındasın?", "Nerede oturuyorsun?"], 0,
           why={1: "Bu soru yaşını öğrenir, adını değil.",
                2: "Bu soru adres sorar. Adını öğrenmek için “Senin adın ne?” deriz."}),
        act("Ailene sınıfındaki iki arkadaşının adını ve sevdikleri bir şeyi anlat."),
    ]),
    outcome("HB.1.1.2", lessons=[
        lesson("Okulumuzu tanıyalım", [
            page("Ocakvadi'nin okulu büyük bir bostanın yanında. Nine Pelin seni okulu gezdirecek.", T("🏫 🌻")),
            page("Sınıfımızda ders yaparız. Her sınıfın bir kapısı ve bir öğretmeni vardır.", T("🏫 👩‍🏫")),
            page("Kütüphanede kitaplar vardır; orada sessizce okuruz.", T("📚 🤫")),
            page("Okul bahçesinde teneffüste oynarız. Kantinden yiyecek alırız. Tuvalette ellerimizi yıkarız.",
                 T("🌳 ⚽ · 🥪 · 🚻 🧼")),
            page("Anka soruyor: “Kitap okumak istiyorum, nereye gideyim?” Kitaplar kütüphanede! "
                 "“Peki top oynamak için?” Bahçeye!", T("📚 · ⚽")),
            page("Dikkat! Kaybolursan olduğun yerde kal ve bir öğretmene ya da okul görevlisine söyle.",
                 T("🙋 öğretmenim!")),
            page("Özet: Her yerin bir işi var: sınıf ders, kütüphane kitap, bahçe oyun, kantin yiyecek.",
                 T("🏫 · 📚 · 🌳 · 🥪")),
        ]),
        lesson("Okul haritası", [
            page("Okulunu bir harita gibi düşün: kapıdan girince sağda ne var, solda ne var?", T("🚪 ⬅️ ➡️")),
            page("Ailenle evde okulunun basit bir resmini çiz. Sınıfını, bahçeni, kütüphaneni işaretle.", T("✏️ 🗺️")),
        ], alt=True),
    ], cards=[
        mc("Okulda kitapların bulunduğu yer neresidir?", ["Kütüphane", "Bahçe", "Kantin"], 0,
           why={1: "Bahçede oyun oynarız. Kitaplar kütüphanededir.",
                2: "Kantinde yiyecek satılır. Kitaplar kütüphanededir."}),
        mc("Teneffüste koşup oynamak için en uygun yer neresidir?", ["Okul bahçesi", "Kütüphane", "Merdiven"], 0,
           why={1: "Kütüphanede sessiz oluruz, koşmayız.",
                2: "Merdivende koşmak tehlikelidir; düşebiliriz."}),
        mc("Okul müdürünün çalıştığı yer neresidir?", ["Müdür odası", "Spor salonu", "Kantin"], 0,
           why={1: "Spor salonunda beden eğitimi yapılır.",
                2: "Kantinde yiyecek satılır. Müdür, müdür odasında çalışır."}),
        mc("Okulda kaybolursan ne yaparsın?", ["Bir öğretmene söylerim", "Okuldan çıkarım", "Saklanırım"], 0,
           why={1: "Okuldan tek başına çıkmak tehlikelidir.",
                2: "Saklanırsak bizi bulamazlar. Bir öğretmene söyleriz."}),
    ]),
    outcome("HB.1.1.3", lessons=[
        lesson("Okul kuralları", [
            page("Ocakvadi'nin pazar yerinde herkes sıraya girer, kimse kimseyi itmez. Böylece herkes ekmeğini alır.",
                 T("🧺 🧍🧍🧍")),
            page("Kurallar hepimizin güvende ve mutlu olması içindir. Okulda da kurallar var.", E("📋")),
            page("Koridorda koşmayız, yavaşça yürürüz. Böylece kimse düşüp yaralanmaz.", T("🚶 ✓  ·  🏃 ✗")),
            page("Sırayla konuşuruz, eşyalarımızı düzenli tutarız, çöplerimizi çöp kutusuna atarız.",
                 T("🙋 · 🎒 · 🗑️")),
            page("Anka düşünüyor: “Kantinde sıra var ama çok acıktım. Öne geçersem önümdekiler üzülür. "
                 "Sıramı bekleyeceğim.”", T("🦉 ⏳")),
            page("Dikkat! Kural bozan bir arkadaşa bağırmayız; nazikçe uyarırız ya da öğretmene söyleriz.",
                 T("🙂 “Burada koşmayalım”")),
            page("Özet: Kurallara uyarsak hepimiz güvende ve mutlu oluruz.", T("📋 ➜ 😊")),
        ]),
        lesson("Kural olmasaydı?", [
            page("Bir oyun düşün: herkes istediği zaman topa elle dokunsun. Oyun bozulur, değil mi?", T("⚽ 🤷")),
            page("Okul da böyle: kurallar herkesin oynayabilmesi, öğrenebilmesi içindir.", T("📋 🤝")),
        ], alt=True),
    ], cards=[
        mc("Koridorda nasıl yürümeliyiz?", ["Yavaşça ve sağdan", "Koşarak", "İterek"], 0,
           why={1: "Koşarken birine çarpıp düşebiliriz.", 2: "İtmek arkadaşımızı yaralayabilir."}),
        mc("Arkadaşın konuşurken ne yapmalısın?", ["Sözünü kesmeden dinlemeliyim", "Araya girmeliyim", "Başka yere bakmalıyım"], 0,
           why={1: "Araya girmek arkadaşımızı üzer. Bitirmesini bekleriz.",
                2: "Başka yere bakarsak onu dinlemediğimizi düşünür."}),
        mc("Çöpümüzü nereye atarız?", ["Çöp kutusuna", "Sıranın altına", "Yere"], 0,
           why={1: "Sıranın altı kirlenir; temizleyen kişiyi düşünelim.", 2: "Yere atılan çöp sınıfı kirletir."}),
        mc("Kantinde sıra varsa ne yaparız?", ["Sıraya gireriz", "Öne geçeriz"], 0,
           why={1: "Öne geçersek bekleyenler üzülür. Sıramızı bekleriz."}),
        mc("Arkadaşın koridorda koşuyor. Ne dersin?", ["“Burada koşmayalım, düşebilirsin”", "“Sen kötüsün!”"], 0,
           why={1: "Kırıcı sözler yerine nazikçe uyarırız."}),
    ]),
    outcome("HB.1.1.4", lessons=[
        lesson("Ben kimim?", [
            page("Bostancık çocukları bir ayna buldu. Herkes aynaya bakıp kendini anlatıyor. Sıra sende!",
                 T("🪞 🧒 👧")),
            page("Her birimiz farklıyız: boyumuz, saçımız, gözlerimiz farklı. Bunlara fiziksel özellik deriz.",
                 T("📏 · 💇 · 👁️")),
            page("Sevdiklerimiz de farklı: kimi resim yapmayı, kimi top oynamayı, kimi şarkı söylemeyi sever.",
                 T("🎨 · ⚽ · 🎵")),
            page("Farklılıklarımız bizi özel yapar. Herkes saygıyı hak eder.", E("🤝")),
            page("Anka anlatıyor: “Benim tüylerim yeşil, gözlüklüyüm, masal okumayı severim. "
                 "Ozan Yaprak uzun boylu, şarkı söylemeyi sever. İkimiz de farklıyız ve arkadaşız!”",
                 T("🦉 🤝 🌳")),
            page("Dikkat! Birinin görünüşüyle alay etmek onu çok üzer. Farklılıklara saygı duyarız.", T("🙅 alay")),
            page("Özet: Herkesin görünüşü ve sevdikleri farklıdır. Farklılıklar bizi zenginleştirir.",
                 T("🧒 👧 👦 = 🤝")),
        ]),
        lesson("Benim kartım", [
            page("Bir kâğıda kendini çiz. Yanına saç rengini, göz rengini ve en sevdiğin şeyi yaz.", T("✏️ 🧒")),
            page("Arkadaşının kartıyla karşılaştır: neler aynı, neler farklı?", T("🧒 ↔ 👧")),
        ], alt=True),
    ], cards=[
        mc("Arkadaşının saç rengi seninkinden farklıysa ne düşünürsün?", ["Herkes farklıdır, bu çok doğal", "O yanlış", "Onunla oynamam"], 0,
           why={1: "Saç rengi doğru ya da yanlış olmaz; herkes farklıdır.",
                2: "Farklı olduğu için birini dışlamak onu üzer."}),
        mc("Hangisi bir fiziksel özelliktir?", ["Göz rengi", "En sevdiğim oyun", "Arkadaşımın adı"], 0,
           why={1: "Sevdiğimiz oyun bir ilgi alanıdır, görünüşümüz değil.",
                2: "Arkadaşımızın adı bizim özelliğimiz değildir."}),
        mc("Hangisi bir ilgi alanıdır?", ["Resim yapmayı sevmek", "Boyunun uzun olması", "Gözlerinin kahverengi olması"], 0,
           why={1: "Boy bir fiziksel özelliktir.", 2: "Göz rengi bir fiziksel özelliktir."}),
        act("Aynaya bakarak kendini ailene anlat: saç rengin, göz rengin ve en sevdiğin şey."),
    ]),
    outcome("HB.1.2.1", lessons=[
        lesson("Sağlıklı büyüyorum", [
            page("Nine Pelin'in bostanında sebzeler kocaman büyüyor. “Onlara su, güneş ve iyi toprak veriyorum,” diyor. "
                 "Biz de büyümek için bakım isteriz.", T("🥕 💧 ☀️")),
            page("Dengeli besleniriz: sebze, meyve, süt, ekmek, et ya da baklagil. Her birinden biraz.",
                 T("🥕 🍎 🥛 🍞 🫘")),
            page("Bol su içeriz. Şekerli içecekler yerine su ya da süt seçeriz.", T("💧 ✓  ·  🥤 ✗")),
            page("Erken yatar, yeterince uyuruz. Her gün koşar, oynar, hareket ederiz.", T("😴 · 🤸")),
            page("Temizlik de sağlıktır: ellerimizi yemekten önce ve tuvaletten sonra sabunla yıkarız; "
                 "dişlerimizi sabah ve akşam fırçalarız.", T("🧼 · 🪥🪥")),
            page("Dikkat! Abur cubur hemen doyurur ama vücudumuza az fayda verir. Ara öğünde meyve seçeriz.",
                 T("🍎 ✓  ·  🍟 ✗")),
            page("Özet: Dengeli beslen, su iç, uyu, hareket et, temiz ol.", T("🥕 · 💧 · 😴 · 🤸 · 🧼")),
        ]),
        lesson("Sağlıklı tabak", [
            page("Tabağını düşün: yarısı sebze ve meyve, bir parçası ekmek, bir parçası et, yumurta ya da fasulye.",
                 T("🍽️ 🥗🍞🥚")),
            page("Yanına bir bardak su ya da süt. İşte sağlıklı bir öğün!", T("🍽️ + 💧")),
        ], alt=True),
    ], cards=[
        mc("Hangisi sağlıklı bir ara öğündür?", ["Elma", "Cips", "Gazlı içecek"], 0,
           why={1: "Cips çok tuzlu ve yağlıdır; arada bir yenir.", 2: "Gazlı içeceklerde çok şeker vardır."}),
        mc("Ellerimizi ne zaman yıkarız?", ["Yemekten önce", "Sadece bayramda", "Hiçbir zaman"], 0,
           why={1: "Ellerimizi her gün, yemekten önce ve tuvaletten sonra yıkarız.",
                2: "Yıkanmayan ellerdeki mikroplar bizi hasta edebilir."}),
        mc("Dişlerimizi günde en az kaç kez fırçalamalıyız?", ["1", "2", "5"], 1,
           why={0: "Bir kez yetmez: sabah ve akşam, günde 2 kez fırçalarız.",
                2: "5 kez gerekmez. Sabah ve akşam, günde 2 kez yeterlidir."}),
        mc("Erken ve yeterince uyumak neden önemlidir?", ["Büyümemize yardım eder", "Hiç önemi yok"], 0,
           why={1: "Uyurken vücudumuz dinlenir ve büyür. Uyku çok önemlidir."}),
        mc("Susadığında hangisini içmek en sağlıklıdır?", ["Su", "Gazlı içecek", "Şekerli meyve suyu"], 0,
           why={1: "Gazlı içeceklerde çok şeker vardır.", 2: "Şekerli içecekler dişlere zarar verir. Su en iyisi."}),
    ]),
    outcome("HB.1.2.2", lessons=[
        lesson("Bedenim bana ait", [
            page("Nine Pelin bostancık çocuklarına önemli bir şey öğretiyor: “Bedeniniz size aittir.”", T("🧒 💛")),
            page("Her birimizin çevresinde görünmez bir baloncuk var. Buna kişisel alan deriz.", T("🫧 🧒 🫧")),
            page("Rahatsız olduğumuz bir dokunuşa “Hayır!” deme hakkımız vardır. Bu, kaba olmak değildir.",
                 E("✋")),
            page("Böyle bir durumda hemen güvendiğimiz bir büyüğe anlatırız: annemize, babamıza, öğretmenimize.",
                 T("🗣️ 👩‍🏫")),
            page("Tanımadığımız biri bizi bir yere götürmek isterse gitmeyiz ve hemen bir büyüğe haber veririz.",
                 T("🙅 ➜ 🗣️")),
            page("Dikkat! “Bu bizim sırrımız” denen ve seni rahatsız eden bir şeyi saklamazsın. "
                 "Güvendiğin bir büyüğe söylersin.", T("🤫 ✗  ·  🗣️ ✓")),
            page("Özet: Bedenin sana ait. Rahatsız olursan “Hayır!” de, uzaklaş ve güvendiğin bir büyüğe anlat.",
                 T("✋ Hayır! · 🏃 · 🗣️")),
        ]),
        lesson("Güvendiğim büyükler", [
            page("Güvendiğin büyükleri düşün: annen, baban, öğretmenin, büyükannen…", T("👩 👨 👩‍🏫 👵")),
            page("Bir sorun olduğunda bu kişilerden birine her zaman anlatabilirsin.", T("🗣️ 💛")),
        ], alt=True),
    ], cards=[
        mc("Biri seni rahatsız eden bir şekilde dokunursa ne yaparsın?", ["“Hayır!” der ve güvendiğim bir büyüğe anlatırım", "Kimseye söylemem"], 0,
           why={1: "Saklamamız gerekmez. Güvendiğimiz bir büyüğe anlatırız; o bize yardım eder."}),
        mc("Tanımadığın biri seni bir yere götürmek isterse?", ["Gitmem ve hemen bir büyüğe haber veririm", "Giderim"], 0,
           why={1: "Tanımadığımız biriyle hiçbir yere gitmeyiz."}),
        mc("Kişisel alan ne demektir?", ["Bedenimizin çevresindeki bize ait alan", "Okulun bahçesi"], 0,
           why={1: "Okul bahçesi herkesin alanıdır. Kişisel alan, bedenimizin çevresindeki görünmez baloncuktur."}),
        mc("Biri “Bu bizim sırrımız” dedi ve bu seni rahatsız etti. Ne yaparsın?",
           ["Güvendiğim bir büyüğe anlatırım", "Kimseye söylemem"], 0,
           why={1: "Seni rahatsız eden sırları saklamazsın. Güvendiğin bir büyüğe anlat."}),
    ]),
    outcome("HB.1.2.3", lessons=[lesson("Trafikte güvenlik", [
        page("Karşıya yaya geçidinden geçeriz. Önce sola, sonra sağa, sonra tekrar sola bakarız.", T("🚸 👀")),
        page("Trafik ışığında kırmızı dur, sarı hazırlan, yeşil geç demektir.", T("🔴 🟡 🟢")),
    ])], cards=[
        mc("Trafik ışığı kırmızı yanarsa ne yaparız?", ["Dururuz", "Koşarak geçeriz", "Zıplarız"], 0, visual=E("🔴")),
        mc("Karşıya nereden geçmeliyiz?", ["Yaya geçidinden", "Arabaların arasından", "Köşe başından koşarak"], 0),
        mc("Arabada nasıl oturmalıyız?", ["Emniyet kemerimi takarak", "Ayakta durarak", "Pencereden sarkarak"], 0),
        mc("Yeşil ışık ne anlama gelir?", ["Geçebiliriz (bakarak)", "Dur", "Hazırlan"], 0, visual=E("🟢")),
    ]),
    outcome("HB.1.2.4", lessons=[lesson("Acil durumlar", [
        page("Yangın, kaza ya da birinin yaralanması acil durumdur. 112'yi arayarak yardım isteriz.", T("☎️ 112")),
        page("Telefonda sakin olur, adresimizi ve ne olduğunu söyleriz.", E("📞")),
    ])], cards=[
        mc("Acil bir durumda hangi numarayı ararız?", ["112", "123", "555"], 0),
        mc("112'yi aradığımızda ne söylemeliyiz?", ["Adresimizi ve ne olduğunu", "Şarkı söylemeliyiz", "Hemen kapatmalıyız"], 0),
        mc("Hangisi acil bir durumdur?", ["Evde yangın çıkması", "Oyuncağın kaybolması", "Yağmur yağması"], 0),
        act("Ailenle birlikte ev adresinizi ezberleyin ve 112'yi aramayı (gerçekten aramadan) canlandırın."),
    ]),
    outcome("HB.1.3.1", lessons=[lesson("Ailem", [
        page("Aile; anne, baba, kardeşler ve bazen dede ile nineden oluşur. Her aile farklıdır.", T("👨‍👩‍👧‍👦")),
        page("Aile bireyleri birbirini sever, korur ve birbirine yardım eder.", E("❤️")),
    ])], cards=[
        mc("Annemizin annesine ne deriz?", ["Anneanne", "Hala", "Teyze"], 0),
        mc("Babamızın kız kardeşine ne deriz?", ["Teyze", "Hala", "Yenge"], 1),
        mc("Annemizin erkek kardeşine ne deriz?", ["Amca", "Dayı", "Enişte"], 1),
        act("Ailenizin bir fotoğrafına bakarak herkesin adını ve sana yakınlığını söyle."),
    ]),
    outcome("HB.1.3.2", lessons=[lesson("Nezaket sözcükleri", [
        page("“Lütfen”, “Teşekkür ederim”, “Özür dilerim”, “Günaydın” nezaket sözcükleridir.", T("🙏 Lütfen · Teşekkürler")),
        page("Sofrada ağzımız kapalı çiğner, büyüklerimiz başlamadan yemeğe başlamayız.", E("🍽️")),
    ])], cards=[
        mc("Biri sana yardım edince ne dersin?", ["Teşekkür ederim", "Hıh", "Sana ne"], 0),
        mc("Bir şey isterken hangi sözcüğü kullanırız?", ["Lütfen", "Hemen", "Ver"], 0),
        mc("Sabah ailemizi nasıl selamlarız?", ["Günaydın", "İyi geceler", "Afiyet olsun"], 0),
        mc("Yanlışlıkla birine çarparsan ne dersin?", ["Özür dilerim", "Dikkat et!", "Hiçbir şey"], 0),
    ]),
    outcome("HB.1.3.3", lessons=[lesson("Evde görevlerim", [
        page("Ailede herkesin görevi vardır. Ben de odamı toplar, sofrayı kurmaya yardım ederim.", T("🧸 🍽️")),
    ])], cards=[
        mc("Hangisi bir çocuğun evde yapabileceği bir görevdir?", ["Oyuncaklarını toplamak", "Araba kullanmak", "Elektrik tamir etmek"], 0),
        mc("Görevimizi yaptığımızda aile nasıl olur?", ["Daha mutlu ve düzenli", "Daha dağınık"], 0),
        act("Bu hafta evde senin olacak bir görev seçin (ör. sofrayı kurmak). Bir gün birlikte yapın."),
    ]),
    outcome("HB.1.4.1", lessons=[lesson("Yaşadığım yer, ülkem", [
        page("Ülkemizin adı Türkiye Cumhuriyeti'dir. Başkentimiz Ankara'dır.", T("🇹🇷 Ankara")),
        page("Her birimiz bir ilde, bir ilçede ve bir mahallede ya da köyde yaşarız.", T("il · ilçe · mahalle")),
    ])], cards=[
        mc("Ülkemizin başkenti neresidir?", ["İstanbul", "Ankara", "İzmir"], 1),
        mc("Ülkemizin adı nedir?", ["Türkiye Cumhuriyeti", "Anadolu Krallığı"], 0),
        act("Ailene yaşadığınız ilin ve mahallenizin adını sor ve birlikte tekrar edin."),
    ]),
    outcome("HB.1.4.2", lessons=[lesson("Bayrağımız ve marşımız", [
        page("Bayrağımız kırmızı zemin üzerinde beyaz ay ve yıldızdan oluşur.", T("🇹🇷")),
        page("İstiklâl Marşı'mızı Mehmet Akif Ersoy yazmıştır. Marşımızı saygıyla, hazırol durumunda okuruz.", E("🎶")),
    ])], cards=[
        mc("Bayrağımızın renkleri nelerdir?", ["Kırmızı ve beyaz", "Mavi ve sarı", "Yeşil ve beyaz"], 0, visual=T("🇹🇷")),
        mc("İstiklâl Marşı'nı kim yazmıştır?", ["Mehmet Akif Ersoy", "Yunus Emre"], 0),
        mc("İstiklâl Marşı okunurken nasıl dururuz?", ["Saygıyla, hazırol durumunda", "Oturarak ve konuşarak"], 0),
    ]),
    outcome("HB.1.4.3", lessons=[lesson("Mustafa Kemal Atatürk", [
        page("Mustafa Kemal 1881'de Selanik'te doğdu. Annesi Zübeyde Hanım, babası Ali Rıza Efendi'dir.", T("1881 · Selanik")),
        page("Atatürk, Türkiye Cumhuriyeti'ni kurdu. Çocukları çok severdi; 23 Nisan'ı çocuklara armağan etti.", E("🎈")),
    ])], cards=[
        mc("Atatürk nerede doğmuştur?", ["Selanik", "Ankara", "İzmir"], 0),
        mc("Atatürk'ün annesinin adı nedir?", ["Zübeyde Hanım", "Makbule Hanım", "Ayşe Hanım"], 0),
        mc("Atatürk hangi bayramı çocuklara armağan etmiştir?", ["23 Nisan", "30 Ağustos", "29 Ekim"], 0),
        mc("Türkiye Cumhuriyeti'nin kurucusu kimdir?", ["Mustafa Kemal Atatürk", "Mehmet Akif Ersoy"], 0),
    ]),
    outcome("HB.1.4.4", lessons=[lesson("Millî bayramlarımız", [
        page("23 Nisan Ulusal Egemenlik ve Çocuk Bayramı, 19 Mayıs Atatürk'ü Anma, Gençlik ve Spor Bayramı, 30 Ağustos Zafer Bayramı ve 29 Ekim Cumhuriyet Bayramı millî bayramlarımızdır.",
             T("23 Nisan · 19 Mayıs · 30 Ağustos · 29 Ekim")),
        page("Bayramlarda okullar ve sokaklar bayraklarla süslenir, sevinçle kutlarız.", T("🇹🇷🎉")),
    ])], cards=[
        mc("Cumhuriyet Bayramı hangi gündür?", ["29 Ekim", "23 Nisan", "19 Mayıs"], 0),
        mc("Çocuk Bayramı hangi gündür?", ["23 Nisan", "30 Ağustos", "29 Ekim"], 0),
        act("Bir millî bayramda neler hissettiğini ve neler yaptığını ailene anlat."),
    ]),
    outcome("HB.1.4.5", lessons=[lesson("Dinî bayramlarımız", [
        page("Ramazan Bayramı ve Kurban Bayramı dinî bayramlarımızdır.", E("🌙")),
        page("Bayramda büyüklerimizi ziyaret eder, el öperiz. Paylaşır, küsleri barıştırırız.", T("🤝 🍬")),
    ])], cards=[
        mc("Hangisi dinî bayramlarımızdandır?", ["Ramazan Bayramı", "Cumhuriyet Bayramı"], 0),
        mc("Bayramlarda ne yaparız?", ["Büyüklerimizi ziyaret ederiz", "Kimseyle konuşmayız"], 0),
        act("Geçen bayramda neler yaptığınızı ve nasıl hissettiğini ailenle konuş."),
    ]),
    outcome("HB.1.5.1", lessons=[lesson("Doğayı gözlemleyelim", [
        page("Doğada canlı ve cansız varlıklar vardır. Bitkiler ve hayvanlar canlıdır; taş ve su cansızdır.", T("🌳 🐦  🪨 💧")),
        page("Canlılar büyür, beslenir ve çoğalır.", E("🌱")),
    ])], cards=[
        mc("Hangisi canlıdır?", ["Ağaç", "Taş", "Bulut"], 0),
        mc("Hangisi cansızdır?", ["Kedi", "Kaya", "Çiçek"], 1),
        act("Ailenle dışarı çıkıp gördüğünüz 3 canlı ve 3 cansız varlığı sayın."),
    ]),
    outcome("HB.1.5.2", lessons=[lesson("Gök cisimleri", [
        page("Güneş bize ışık ve ısı verir. Ay geceleri parlar. Yıldızlar gökyüzünde çok uzaktadır.", T("☀️ 🌙 ⭐")),
        page("Dünya'mız Güneş'in etrafında döner.", T("🌍 ☀️")),
    ])], cards=[
        mc("Bize ışık ve ısı veren gök cismi hangisidir?", ["Güneş", "Ay", "Bulut"], 0),
        mc("Geceleri gökyüzünde parlayan, şekli değişiyor gibi görünen gök cismi hangisidir?", ["Ay", "Güneş"], 0),
        mc("Hangisi daha büyüktür?", ["Güneş", "Dünya"], 0),
    ]),
    outcome("HB.1.5.3", lessons=[lesson("Afetler", [
        page("Deprem, sel, yangın ve heyelan afetlerdir. Hazırlıklı olursak daha güvende oluruz.", T("🌋 🌊 🔥")),
        page("Depremde “Çök, Kapan, Tutun!” yaparız.", T("🧎 🙈 ✊")),
    ])], cards=[
        mc("Depremde ne yaparız?", ["Çök, kapan, tutun", "Merdivenlerden koşarız", "Pencereye gideriz"], 0),
        mc("Hangisi bir afettir?", ["Sel", "Gökkuşağı", "Rüzgârlı hava"], 0),
        act("Ailenle evde depremde güvenli bir köşe belirleyin ve “Çök, Kapan, Tutun” deneyin."),
    ]),
    outcome("HB.1.5.4", lessons=[lesson("Geri dönüşüm", [
        page("Kâğıt, plastik, cam ve metal atıklar geri dönüştürülebilir.", T("📄 🧴 🍾 🥫")),
        page("Atıkları ayrı kutulara atarız: kâğıt maviye, plastik sarıya, cam yeşile, metal griye.", T("🟦 🟨 🟩 ⬜")),
    ])], cards=[
        mc("Gazete hangi geri dönüşüm grubundadır?", ["Kâğıt", "Cam", "Metal"], 0),
        mc("Cam şişe hangi gruptadır?", ["Plastik", "Cam", "Kâğıt"], 1),
        mc("Konserve kutusu hangi gruptadır?", ["Metal", "Kâğıt", "Cam"], 0),
        mc("Su şişesi (pet şişe) hangi gruptadır?", ["Plastik", "Metal", "Kâğıt"], 0),
    ]),
    outcome("HB.1.6.1", lessons=[lesson("Bilim ve merak", [
        page("Bilim, merak edip soru sormakla başlar: “Neden yağmur yağar?”", E("🔍")),
    ])], cards=[
        mc("Bilim insanları işe nasıl başlar?", ["Merak edip soru sorarak", "Hiç düşünmeden"], 0),
        act("Merak ettiğin bir soruyu ailene sor ve cevabını birlikte araştırın."),
    ]),
    outcome("HB.1.6.2", lessons=[lesson("Teknoloji", [
        page("Hayatımızı kolaylaştıran araçlar teknolojidir: telefon, buzdolabı, bilgisayar…", T("📱 🧊 💻")),
    ])], cards=[
        mc("Hangisi bir teknolojik araçtır?", ["Buzdolabı", "Elma", "Taş"], 0),
        mc("Ekran başında ne kadar süre geçirmeliyiz?", ["Ailemin belirlediği kadar", "Bütün gün"], 0),
        act("Evdeki bir teknolojik aracın ne işe yaradığını ailene sor."),
    ]),
    outcome("HB.1.6.3", lessons=[lesson("Sanat", [
        page("Resim, müzik, dans ve tiyatro sanattır. Sanat duygularımızı anlatmamızı sağlar.", T("🎨 🎵 💃 🎭")),
    ])], cards=[
        mc("Hangisi bir sanat dalıdır?", ["Resim", "Uyumak", "Yemek yemek"], 0),
        act("Bugün hissettiğin duyguyu bir resimle çiz ve ailene göster."),
    ]),
]

PACK = pack("hayat_bilgisi", 1, OUTCOMES)
