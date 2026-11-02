"""2. sınıf Hayat Bilgisi içerik paketi (TYMM HB.2.x.x). Pedagojik onay gerekir."""

from common import pack, outcome, lesson, page, mc, act, V

E = lambda e: V("emoji", emoji=e)
T = lambda t: V("text", text=t)

OUTCOMES = [
    outcome("HB.2.1.1", lessons=[lesson("Planlı olmak", [
        page("Günümüzü planlarsak işlerimizi zamanında bitirir, oyuna da vakit buluruz.", T("📅 ✅")),
        page("Okul çantamızı akşamdan hazırlamak sabah işimizi kolaylaştırır.", E("🎒")),
    ])], cards=[
        mc("Okul çantanı ne zaman hazırlamak daha iyidir?", ["Akşamdan", "Sabah servise binerken"], 0),
        mc("Planlı olmak bize ne kazandırır?", ["İşlerimizi zamanında bitiririz", "Her şeyi unuturuz"], 0),
        act("Ailenle yarının planını yap: ödev, oyun ve uyku saatlerini birlikte yazın."),
    ]),
    outcome("HB.2.1.2", lessons=[lesson("Güzel iletişim", [
        page("Konuşurken karşımızdakinin gözlerine bakar, sözünü kesmeden dinleriz.", T("👀 👂")),
        page("Kızgın olsak bile kırıcı sözler söylemeyiz; duygumuzu sakin anlatırız: “Buna üzüldüm.”", E("🗣️")),
    ])], cards=[
        mc("Arkadaşın konuşurken ne yaparsın?", ["Dinlerim", "Sözünü keserim", "Başka şeyle ilgilenirim"], 0),
        mc("Bir şeye üzüldüğünde nasıl söylersin?", ["“Buna üzüldüm” derim", "Bağırırım", "Kapıyı çarparım"], 0),
        mc("Öğretmenine bir şey sorarken nasıl başlarsın?", ["“Öğretmenim, sorabilir miyim?”", "“Hey sen!”"], 0),
    ]),
    outcome("HB.2.1.3", lessons=[lesson("Arkadaşlık", [
        page("İyi arkadaş paylaşır, yardım eder ve sözünü tutar.", T("🤝 🍪")),
        page("Arkadaşımızla anlaşamazsak konuşarak çözüm buluruz.", E("💬")),
    ])], cards=[
        mc("Arkadaşınla aynı oyuncağı istiyorsanız ne yaparsınız?", ["Sırayla oynarız", "Kavga ederiz", "Oyuncağı saklarım"], 0),
        mc("İyi bir arkadaş nasıl davranır?", ["Yardım eder", "Alay eder", "Sır saklamaz"], 0),
        mc("Bir arkadaşın oyuna katılamıyor ve üzgünse ne yaparsın?", ["Onu oyuna davet ederim", "Görmezden gelirim"], 0),
    ]),
    outcome("HB.2.1.4", lessons=[lesson("Birlikte karar veriyoruz", [
        page("Sınıfta birlikte karar verirken herkesin fikrini dinler, oylama yaparız.", T("🗳️")),
        page("Çoğunluğun kararına saygı duyarız ama azınlığın fikrini de önemseriz.", E("🤝")),
    ])], cards=[
        mc("Sınıf gezisinin yerine nasıl karar vermek en adildir?", ["Oylama yaparak", "En çok bağıranın dediği gibi"], 0),
        mc("Oylamada fikrin seçilmezse ne yaparsın?", ["Sonuca saygı duyarım", "Küserim"], 0),
        mc("Grup çalışmasında herkes ne yapmalı?", ["Görevini yapmalı", "Sadece izlemeli"], 0),
    ]),
    outcome("HB.2.2.1", lessons=[lesson("Alışkanlıklar ve sağlık", [
        page("İyi alışkanlıklar bizi sağlıklı yapar: su içmek, meyve sebze yemek, spor yapmak.", T("💧 🍎 🏃")),
        page("Çok şeker yemek ve geç yatmak sağlığımıza zarar verir.", T("🍬 🌙")),
    ])], cards=[
        mc("Hangisi sağlıklı bir alışkanlıktır?", ["Her gün su içmek", "Çok şekerli içecek içmek", "Gece geç yatmak"], 0),
        mc("Hangisi dişlerimize zarar verir?", ["Çok şeker yemek", "Süt içmek", "Diş fırçalamak"], 0),
        mc("Spor yapmak bize ne kazandırır?", ["Güçlü bir beden", "Halsizlik"], 0),
        act("Ailenle birlikte bir hafta boyunca her gün 15 dakika yürüyüş ya da oyun yapmayı deneyin."),
    ]),
    outcome("HB.2.2.2", lessons=[lesson("İnternette güvenlik", [
        page("İnternette adımızı, adresimizi, okulumuzu ve fotoğrafımızı tanımadığımız kişilerle paylaşmayız.", E("🔒")),
        page("Bizi rahatsız eden bir şey görürsek hemen ailemize söyleriz.", T("💻 → 👨‍👩‍👧")),
    ])], cards=[
        mc("İnternette tanımadığın biri adresini sorarsa ne yaparsın?", ["Söylemem ve aileme haber veririm", "Hemen söylerim"], 0),
        mc("Hangisini internette paylaşmamalıyız?", ["Ev adresimizi", "En sevdiğimiz rengi"], 0),
        mc("Şifreni kimlerle paylaşabilirsin?", ["Sadece ailemle", "Herkesle"], 0),
    ]),
    outcome("HB.2.2.3", lessons=[lesson("Trafik levhaları", [
        page("Trafik levhaları bize bilgi verir ya da uyarır. Kırmızı sekizgen levha “DUR” demektir.", T("🛑")),
        page("Okul geçidi ve yaya geçidi levhaları sürücülere dikkatli olmalarını söyler.", T("🚸")),
    ])], cards=[
        mc("Bu levha ne anlama gelir?", ["Dur", "Hızlan", "Park et"], 0, visual=E("🛑")),
        mc("Bu levha neyi gösterir?", ["Okul geçidi / çocuklar geçebilir", "Benzinlik", "Hastane"], 0, visual=E("🚸")),
        mc("Bu levha neyi gösterir?", ["Yasak bölge", "Oyun alanı", "Yemek yeri"], 0, visual=E("⛔")),
    ]),
    outcome("HB.2.2.4", lessons=[lesson("Yetkililerle konuşmak", [
        page("Acil durumda 112'yi ararız. Sakin konuşur, adımızı, adresimizi ve ne olduğunu söyleriz.", T("☎️ 112")),
        page("Sorulan sorulara cevap verir, görevli “kapatabilirsin” diyene kadar telefonu kapatmayız.", E("📞")),
    ])], cards=[
        mc("112'yi aradığında önce ne söylersin?", ["Ne olduğunu ve adresimi", "Şaka yaparım"], 0),
        mc("Telefonu ne zaman kapatırsın?", ["Görevli söylediğinde", "Hemen"], 0),
        mc("112'yi şaka için aramak doğru mudur?", ["Hayır, gerçek acil durumları engeller", "Evet, eğlencelidir"], 0),
    ]),
    outcome("HB.2.3.1", lessons=[lesson("Aile neden önemli?", [
        page("Ailemiz bizi sever, korur ve büyütür. Biz de aile bireylerimize sevgi ve saygı gösteririz.", E("🏠")),
    ])], cards=[
        mc("Ailemiz bizim için neden önemlidir?", ["Bizi sever ve korur", "Önemli değildir"], 0),
        mc("Aile bireylerimize nasıl davranırız?", ["Sevgi ve saygıyla", "Kaba"], 0),
        act("Aile büyüklerinden birine çocukluğunu sor ve bir anısını dinle."),
    ]),
    outcome("HB.2.3.2", lessons=[lesson("Toplumda görgü", [
        page("Toplu taşımada yaşlılara ve hamilelere yer veririz. Sırada bekleriz.", T("🚌 🧓")),
        page("Ortak alanlarda yüksek sesle konuşmayız, çöplerimizi yere atmayız.", E("🤫")),
    ])], cards=[
        mc("Otobüse yaşlı bir teyze binerse ne yaparsın?", ["Yerimi veririm", "Görmezden gelirim"], 0),
        mc("Kütüphanede nasıl konuşuruz?", ["Alçak sesle", "Bağırarak"], 0),
        mc("Parkta yediğin yiyeceğin ambalajını ne yaparsın?", ["Çöp kutusuna atarım", "Çimlere bırakırım"], 0),
    ]),
    outcome("HB.2.3.3", lessons=[lesson("Çevremdeki sorumluluklarım", [
        page("Evde, okulda ve mahallede de sorumluluklarımız vardır: düzen, temizlik, yardımlaşma.", T("🏠 🏫 🌳")),
    ])], cards=[
        mc("Sınıfta hangisi senin sorumluluğundur?", ["Sıramı düzenli tutmak", "Okul müdürünü seçmek"], 0),
        mc("Mahallede hangisi hepimizin sorumluluğudur?", ["Çevreyi temiz tutmak", "Duvarlara yazı yazmak"], 0),
        act("Bu hafta mahallende ya da apartmanında yapabileceğin bir iyilik planlayın ve yapın."),
    ]),
    outcome("HB.2.4.1", lessons=[lesson("Tarihî ve doğal güzellikler", [
        page("Camiler, kaleler, köprüler ve eski evler tarihî mekânlardır. Göller, şelaleler ve ormanlar doğal güzelliklerdir.",
             T("🕌 🏰 🌉  🏞️ 🌲")),
    ])], cards=[
        mc("Hangisi tarihî bir mekândır?", ["Eski bir kale", "Yeni bir otopark"], 0),
        mc("Hangisi doğal bir güzelliktir?", ["Şelale", "Alışveriş merkezi"], 0),
        act("Yaşadığınız yerdeki bir tarihî mekânı ya da doğal güzelliği ailenle birlikte araştırın veya ziyaret edin."),
    ]),
    outcome("HB.2.4.2", lessons=[lesson("Yönetim birimleri", [
        page("Ülkemiz illere, iller ilçelere, ilçeler mahalle ve köylere ayrılır.", T("il → ilçe → mahalle/köy")),
        page("İli vali, ilçeyi kaymakam yönetir. Mahalle ve köyün muhtarı vardır.", T("vali · kaymakam · muhtar")),
    ])], cards=[
        mc("İli kim yönetir?", ["Vali", "Muhtar", "Öğretmen"], 0),
        mc("Mahallenin yöneticisi kimdir?", ["Muhtar", "Vali", "Kaymakam"], 0),
        mc("İlçeyi kim yönetir?", ["Kaymakam", "Muhtar", "Müdür"], 0),
    ]),
    outcome("HB.2.4.3", lessons=[lesson("Atatürk'ün öğrencilik yılları", [
        page("Mustafa Kemal önce mahalle mektebine, sonra Şemsi Efendi Okulu'na gitti.", T("📚")),
        page("Askerî Rüştiye'de matematik öğretmeni ona “Kemal” adını verdi. Çok çalışkan bir öğrenciydi.", T("✏️ Kemal")),
    ])], cards=[
        mc("Mustafa Kemal'e “Kemal” adını kim verdi?", ["Matematik öğretmeni", "Babası", "Arkadaşı"], 0),
        mc("Mustafa Kemal hangi derste çok başarılıydı?", ["Matematik", "Hiçbirinde"], 0),
        mc("Atatürk'ün gittiği okullardan biri hangisidir?", ["Şemsi Efendi Okulu", "Galatasaray Lisesi"], 0),
    ]),
    outcome("HB.2.4.4", lessons=[lesson("Millî bayramların önemi", [
        page("29 Ekim 1923'te Cumhuriyet ilan edildi. 30 Ağustos'ta büyük bir zafer kazandık.", T("29 Ekim 1923")),
        page("Bayramlar, bağımsızlığımızı kazanmak için çalışanları hatırlamamızı sağlar.", T("🇹🇷")),
    ])], cards=[
        mc("Cumhuriyet hangi yıl ilan edildi?", ["1923", "1881", "1938"], 0),
        mc("30 Ağustos hangi bayramdır?", ["Zafer Bayramı", "Çocuk Bayramı", "Cumhuriyet Bayramı"], 0),
        mc("19 Mayıs kime armağan edilmiştir?", ["Gençlere", "Yaşlılara", "Askerlere"], 0),
    ]),
    outcome("HB.2.4.5", lessons=[lesson("Dinî bayramların önemi", [
        page("Dinî bayramlar paylaşmayı, yardımlaşmayı ve büyüklere saygıyı güçlendirir.", T("🤲 🍬")),
    ])], cards=[
        mc("Bayramlar hangi duyguları güçlendirir?", ["Paylaşma ve yardımlaşma", "Kıskançlık"], 0),
        mc("Bayramda küs olduğumuz biriyle ne yaparız?", ["Barışırız", "Küs kalırız"], 0),
        act("Ailene bayramlarda en sevdiğin geleneği ve nedenini anlat."),
    ]),
    outcome("HB.2.5.1", lessons=[lesson("Hava ve mevsimler", [
        page("Dört mevsim vardır: ilkbahar, yaz, sonbahar, kış.", T("🌸 ☀️ 🍂 ❄️")),
        page("Kışın kar yağar ve soğuk olur; yazın sıcak olur. Mevsime göre giyiniriz.", T("🧤  🩳")),
    ])], cards=[
        mc("Kar en çok hangi mevsimde yağar?", ["Kış", "Yaz", "İlkbahar"], 0, visual=E("❄️")),
        mc("Yapraklar hangi mevsimde dökülür?", ["Sonbahar", "Yaz", "İlkbahar"], 0, visual=E("🍂")),
        mc("Yazın nasıl giyiniriz?", ["İnce", "Kalın montla"], 0),
        mc("Kaç mevsim vardır?", ["2", "4", "12"], 1),
    ]),
    outcome("HB.2.5.2", lessons=[lesson("Doğada yön bulma", [
        page("Dört ana yön: kuzey, güney, doğu, batı. Güneş doğudan doğar, batıdan batar.", T("⬆️ K · ⬇️ G · ➡️ D · ⬅️ B")),
        page("Sabah güneşe döndüğümüzde yüzümüz doğuya bakar.", E("🌅")),
    ])], cards=[
        mc("Güneş hangi yönden doğar?", ["Doğu", "Batı", "Kuzey"], 0),
        mc("Güneş hangi yönde batar?", ["Batı", "Doğu", "Güney"], 0),
        mc("Kaç ana yön vardır?", ["2", "4", "8"], 1),
    ]),
    outcome("HB.2.5.3", lessons=[lesson("Afetlere hazırlık", [
        page("Afet çantasında su, yiyecek, el feneri, ilk yardım malzemesi ve düdük bulunur.", T("🎒 💧 🔦 🩹")),
        page("Ailemizle buluşma noktası belirleriz. AFAD bize afetlerde yardım eder.", T("📍 AFAD")),
    ])], cards=[
        mc("Afet çantasında hangisi bulunmalı?", ["El feneri", "Oyun konsolu", "Çiçek"], 0),
        mc("Afetlerde yardım eden kurumumuz hangisidir?", ["AFAD", "Kütüphane"], 0),
        act("Ailenle birlikte afet çantanızı gözden geçirin ve bir buluşma noktası belirleyin."),
    ]),
    outcome("HB.2.5.4", lessons=[lesson("Tasarruf", [
        page("Dişlerimizi fırçalarken musluğu kapatırız. Odadan çıkarken ışığı söndürürüz.", T("🚰 💡")),
    ])], cards=[
        mc("Diş fırçalarken su tasarrufu için ne yaparız?", ["Musluğu kapatırız", "Musluğu açık bırakırız"], 0),
        mc("Odadan çıkarken ne yapmalıyız?", ["Işığı söndürmeliyiz", "Bütün ışıkları açmalıyız"], 0),
        act("Bir gün boyunca evde su ve elektrik tasarrufu için 3 şey yapın ve birlikte sayın."),
    ]),
    outcome("HB.2.6.1", lessons=[lesson("Bilim insanları", [
        page("Cahit Arf ünlü bir Türk matematikçisidir. Aziz Sancar kimya alanında Nobel Ödülü aldı.", T("🔢 🧪")),
        page("İbn-i Sina tıp alanında, Uluğ Bey gökbilim alanında önemli çalışmalar yaptı.", T("🩺 🔭")),
    ])], cards=[
        mc("Nobel Ödülü kazanan Türk bilim insanı kimdir?", ["Aziz Sancar", "Mimar Sinan"], 0),
        mc("Cahit Arf hangi alanda çalışmıştır?", ["Matematik", "Müzik"], 0),
        mc("Uluğ Bey hangi alanla ilgilenmiştir?", ["Gökbilim (astronomi)", "Aşçılık"], 0),
    ]),
    outcome("HB.2.6.2", lessons=[lesson("Teknoloji değişir", [
        page("Eskiden mektup yazılırdı, şimdi mesaj gönderiyoruz. Teknoloji değişir ama iletişim ihtiyacı sürer.", T("✉️ → 📱")),
    ])], cards=[
        mc("Eskiden haberleşmek için ne kullanılırdı?", ["Mektup", "Akıllı telefon"], 0),
        mc("Telefonların ileride nasıl olacağını tahmin ederken neye bakarız?", ["Geçmişten bugüne nasıl değiştiklerine", "Hiçbir şeye"], 0),
        act("Ailene küçükken hangi teknolojik araçları kullandıklarını sor ve bugünküyle karşılaştırın."),
    ]),
    outcome("HB.2.6.3", lessons=[lesson("Hayatımızda sanat", [
        page("Evimizdeki halılar, kitap kapakları, şarkılar ve binalar sanatla süslenir.", T("🧶 📕 🎵 🏛️")),
    ])], cards=[
        mc("Hangisinde sanat vardır?", ["Desenli bir halıda", "Boş bir kâğıtta"], 0),
        mc("Bir şarkı söylemek hangi sanat dalıdır?", ["Müzik", "Resim"], 0),
        act("Evinizde sanatla süslenmiş bir eşya bul ve ailene neden güzel olduğunu anlat."),
    ]),
]

PACK = pack("hayat_bilgisi", 2, OUTCOMES)
